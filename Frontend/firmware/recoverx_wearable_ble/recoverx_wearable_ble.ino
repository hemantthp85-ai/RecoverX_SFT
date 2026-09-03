/*
 * ============================================================
 * RecoverX — Smart Wearable Recovery System
 * Firmware Version: 2.0.0
 * Microcontroller: ESP32-C3 Mini / Super Mini
 *
 * SENSORS & ACTUATORS:
 *  - Temperature Sensor: DS18B20 (OneWire DATA = GPIO 10)
 *  - Optical Sensor: MAX30102 (I2C SDA = GPIO 8, SCL = GPIO 9)
 *  - Thermoelectric Actuator: Peltier via L298N Channel B
 *      - ENB = GPIO 6
 *      - IN3 = GPIO 4
 *      - IN4 = GPIO 5
 *  - Physical FSR: GPIO 0 (Analog ADC - Telemetry monitoring only; NEVER used for therapy)
 *
 * PIN SAFETY RULES:
 *  - DS18B20 DATA is on GPIO 10 (DO NOT use GPIO 2).
 *  - GPIO 10 is reserved exclusively for DS18B20.
 *
 * AUTONOMOUS THERAPY RULES:
 *  - Therapy decision is calculated 100% LOCALLY on ESP32-C3.
 *  - Does NOT depend on BLE, Phone, Flutter, React, Python backend or Internet.
 *  - Operates continuously even if phone disconnects.
 *
 * SAFETY ENGINE:
 *  - Never rapidly reverse Peltier polarity.
 *  - Turn Peltier OFF before changing direction.
 *  - 2000 ms deadband delay between direction reversals.
 *  - Temperature hysteresis to avoid chatter.
 *  - Sensor failure auto-cutoff: If DS18B20 disconnects or values out of bounds, Peltier shuts OFF.
 *  - Maximum continuous therapy duration protection (15 min active limit followed by cooldown).
 * ============================================================
 */

#include <Wire.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <MAX30105.h>
#include <ArduinoJson.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// ── Hardware Pin Configuration ─────────────────────────────────────────
#define I2C_SDA_PIN                 8   // MAX30102 I2C SDA
#define I2C_SCL_PIN                 9   // MAX30102 I2C SCL
#define DS18B20_DATA_PIN            10  // DS18B20 OneWire DATA (MUST BE GPIO 10, NOT GPIO 2)

// L298N Channel B Pins for Peltier Control
#define L298N_ENB_PIN               6   // L298N Channel B Enable
#define L298N_IN3_PIN               4   // L298N Channel B IN3
#define L298N_IN4_PIN               5   // L298N Channel B IN4

// Physical FSR Sensor (ADC GPIO 0) — Telemetry only, NEVER used in therapy logic
#define FSR_ANALOG_PIN              0

// ── BLE Identification & Contracts ────────────────────────────────────
#define DEVICE_NAME                 "RecoverX_Wearable"
#define SERVICE_UUID                "19b10000-e8f2-537e-4f6c-d104768a1214"
#define TELEMETRY_CHARACTERISTIC    "19b10001-e8f2-537e-4f6c-d104768a1214"
#define TELEMETRY_INTERVAL_MS       1000  // 1 Hz telemetry notification rate

// ── Safety & Thermal Protection Constants ──────────────────────────────
#define PELTIER_DEADBAND_DELAY_MS   2000    // Minimum 2000 ms OFF deadband before direction switch
#define MAX_ACTIVE_RUNTIME_MS       900000  // Max 15 minutes continuous active therapy cutoff
#define MANDATORY_COOLDOWN_MS       120000  // 2 minutes mandatory cooldown after max runtime
#define TEMP_SENSOR_MIN_SAFE_C      10.0    // Minimum skin contact safe boundary (°C)
#define TEMP_SENSOR_MAX_SAFE_C      45.0    // Maximum skin contact safe boundary (°C)
#define TEMP_HYSTERESIS_C           0.5     // Thermal switching hysteresis (°C)

// ── Sensor Objects ────────────────────────────────────────────────────
OneWire oneWire(DS18B20_DATA_PIN);
DallasTemperature ds18b20(&oneWire);
MAX30105 max30102;

// ── BLE State Variables ───────────────────────────────────────────────
BLEServer* pServer = nullptr;
BLECharacteristic* pTelemetryChar = nullptr;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// ── Therapy & Actuator States ─────────────────────────────────────────
enum PeltierState {
  STATE_OFF,
  STATE_HEAT,
  STATE_COOL
};

PeltierState currentPeltierState = STATE_OFF;
PeltierState pendingPeltierState = STATE_OFF;

unsigned long stateLastChangedTime = 0;
unsigned long continuousActiveStartTime = 0;
bool isThermalCooldownActive = false;
unsigned long cooldownStartTime = 0;
unsigned long lastTelemetryTxTime = 0;

// ── BLE Server Callbacks ──────────────────────────────────────────────
class RecoverXServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
    Serial.println("[BLE] Client CONNECTED to RecoverX_Wearable!");
  }

  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    Serial.println("[BLE] Client DISCONNECTED from RecoverX_Wearable!");
    // Local therapy logic continues running independently on ESP32!
  }
};

// ── Hardware Control: Low-level Peltier Actuation ──────────────────────
void hardwareSetPeltierOff() {
  digitalWrite(L298N_ENB_PIN, LOW);
  digitalWrite(L298N_IN3_PIN, LOW);
  digitalWrite(L298N_IN4_PIN, LOW);
  currentPeltierState = STATE_OFF;
}

void hardwareSetPeltierHeat() {
  digitalWrite(L298N_IN3_PIN, HIGH);
  digitalWrite(L298N_IN4_PIN, LOW);
  digitalWrite(L298N_ENB_PIN, HIGH);
  currentPeltierState = STATE_HEAT;
}

void hardwareSetPeltierCool() {
  digitalWrite(L298N_IN3_PIN, LOW);
  digitalWrite(L298N_IN4_PIN, HIGH);
  digitalWrite(L298N_ENB_PIN, HIGH);
  currentPeltierState = STATE_COOL;
}

// ── Safety Engine: High-Level Actuator Manager ─────────────────────────
void applyPeltierSafetyControl(PeltierState requestedState, float currentTempC, bool sensorValid) {
  unsigned long now = millis();

  // 1. Safety Check: If temperature sensor failed or values invalid, immediate forced OFF
  if (!sensorValid || currentTempC < TEMP_SENSOR_MIN_SAFE_C || currentTempC > TEMP_SENSOR_MAX_SAFE_C) {
    if (currentPeltierState != STATE_OFF) {
      hardwareSetPeltierOff();
      stateLastChangedTime = now;
      Serial.println("[SAFETY] Temperature sensor invalid/disconnected! Peltier forced OFF immediately.");
    }
    return;
  }

  // 2. Safety Check: Maximum continuous runtime cutoff
  if (currentPeltierState != STATE_OFF) {
    if (now - continuousActiveStartTime >= MAX_ACTIVE_RUNTIME_MS) {
      hardwareSetPeltierOff();
      isThermalCooldownActive = true;
      cooldownStartTime = now;
      stateLastChangedTime = now;
      Serial.println("[SAFETY] Max 15-minute continuous therapy limit reached. Entering mandatory cooldown.");
      return;
    }
  }

  // 3. Safety Check: Mandatory cooldown in progress
  if (isThermalCooldownActive) {
    if (now - cooldownStartTime < MANDATORY_COOLDOWN_MS) {
      hardwareSetPeltierOff();
      return;
    } else {
      isThermalCooldownActive = false;
      Serial.println("[SAFETY] Mandatory cooldown elapsed. Normal operation resumed.");
    }
  }

  // 4. State Transition & Direction Reversal Deadband Protection
  if (requestedState == currentPeltierState) {
    return; // Already in target state, maintain
  }

  // If transitioning between HEAT and COOL (or turning on from OFF):
  // ALWAYS force Peltier OFF first and ensure deadband delay before switching direction!
  if (currentPeltierState != STATE_OFF) {
    hardwareSetPeltierOff();
    stateLastChangedTime = now;
    pendingPeltierState = requestedState;
    Serial.println("[SAFETY] Direction change requested. Switching to OFF deadband for safety delay.");
    return;
  }

  // Currently OFF, waiting for deadband delay before activating new direction
  if (now - stateLastChangedTime < PELTIER_DEADBAND_DELAY_MS) {
    // Waiting for deadband delay to elapse
    return;
  }

  // Deadband delay satisfied, apply requested state
  if (requestedState == STATE_HEAT) {
    hardwareSetPeltierHeat();
    continuousActiveStartTime = now;
    stateLastChangedTime = now;
    Serial.println("[PELTIER] State changed to HEAT (ENB=HIGH, IN3=HIGH, IN4=LOW)");
  } else if (requestedState == STATE_COOL) {
    hardwareSetPeltierCool();
    continuousActiveStartTime = now;
    stateLastChangedTime = now;
    Serial.println("[PELTIER] State changed to COOL (ENB=HIGH, IN3=LOW, IN4=HIGH)");
  } else {
    hardwareSetPeltierOff();
    stateLastChangedTime = now;
    Serial.println("[PELTIER] State changed to OFF (ENB=LOW, IN3=LOW, IN4=LOW)");
  }
}

// ── Sensor Reading Functions ──────────────────────────────────────────
float readDS18B20Temperature(bool &valid) {
  ds18b20.requestTemperatures();
  float tempC = ds18b20.getTempCByIndex(0);
  if (tempC == DEVICE_DISCONNECTED_C || tempC < -50.0 || tempC > 125.0) {
    valid = false;
    return -999.0;
  }
  valid = true;
  return tempC;
}

// ── Setup Initialization ──────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("==================================================");
  Serial.println("  RecoverX Autonomous Wearable Firmware (ESP32-C3)");
  Serial.println("==================================================");

  // 1. Initialize L298N Control Pins (MUST START IN SAFE OFF STATE)
  pinMode(L298N_ENB_PIN, OUTPUT);
  pinMode(L298N_IN3_PIN, OUTPUT);
  pinMode(L298N_IN4_PIN, OUTPUT);
  hardwareSetPeltierOff();
  Serial.println("[ACTUATOR] L298N Channel B pins initialized: OFF (ENB=6, IN3=4, IN4=5)");

  // 2. Initialize I2C Bus for MAX30102
  Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);
  Serial.println("[I2C] Bus initialized: SDA=GPIO 8, SCL=GPIO 9");

  // 3. Initialize DS18B20 Temperature Sensor
  ds18b20.begin();
  Serial.println("[DS18B20] OneWire bus initialized on GPIO 10 (DO NOT use GPIO 2)");

  // 4. Initialize MAX30102 Pulse Oximeter / PPG Sensor
  if (!max30102.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("[MAX30102] WARNING: MAX30102 sensor not detected on I2C bus!");
  } else {
    max30102.setup();
    max30102.setPulseAmplitudeRed(0x1F);
    max30102.setPulseAmplitudeIR(0x1F);
    max30102.setPulseAmplitudeGreen(0);
    Serial.println("[MAX30102] Sensor initialized successfully.");
  }

  // 5. Initialize BLE Device & Services
  BLEDevice::init(DEVICE_NAME);
  BLEDevice::setMTU(512); // Support full JSON payloads without truncation

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new RecoverXServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);

  pTelemetryChar = pService->createCharacteristic(
      TELEMETRY_CHARACTERISTIC,
      BLECharacteristic::PROPERTY_READ   |
      BLECharacteristic::PROPERTY_WRITE  |
      BLECharacteristic::PROPERTY_NOTIFY |
      BLECharacteristic::PROPERTY_INDICATE
  );
  pTelemetryChar->addDescriptor(new BLE2902());

  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("[BLE] Advertising as: " DEVICE_NAME);
  Serial.println("[BLE] Service UUID:   " SERVICE_UUID);
  Serial.println("[BLE] Telemetry UUID: " TELEMETRY_CHARACTERISTIC);
  Serial.println("[SYSTEM] System initialization complete. Autonomous therapy active.");
}

// ── Main Execution Loop ───────────────────────────────────────────────
void loop() {
  unsigned long now = millis();

  // ── BLE Re-advertising on Disconnect ────────────────────────────────
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);
    pServer->startAdvertising();
    Serial.println("[BLE] Device disconnected. Restarted advertising.");
    oldDeviceConnected = deviceConnected;
  }
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }

  // ── 1. Read Sensors ─────────────────────────────────────────────────
  bool tempSensorValid = false;
  float currentTempC = readDS18B20Temperature(tempSensorValid);

  uint32_t irValue = 0;
  uint32_t redValue = 0;
  if (max30102.begin(Wire, I2C_SPEED_FAST)) {
    irValue = max30102.getIR();
    redValue = max30102.getRed();
  }

  // ── 2. Autonomous Local Therapy Decision Engine ─────────────────────
  // Evaluated locally on ESP32-C3 regardless of BLE or phone connection.
  // FSR exists physically on GPIO 0 but MUST NOT be used for therapy logic.
  bool fingerDetected = (irValue >= 1000);
  bool therapyCondition = fingerDetected && ((irValue >= 1000 && irValue < 90000) || (irValue >= 150000));

  bool therapyRequested = false;
  String therapyStatus = "OFF";
  String therapyDirection = "NORMAL";
  PeltierState requestedPeltierState = STATE_OFF;

  if (!fingerDetected) {
    // IR < 1000: Finger NOT detected -> Therapy OFF
    therapyRequested = false;
    therapyStatus = "OFF";
    therapyDirection = "OFF";
    requestedPeltierState = STATE_OFF;
  } else if (irValue >= 90000 && irValue < 150000) {
    // 90000 <= IR < 150000: Normal condition -> Therapy OFF
    therapyRequested = false;
    therapyStatus = "OFF";
    therapyDirection = "NORMAL";
    requestedPeltierState = STATE_OFF;
  } else if (therapyCondition && tempSensorValid) {
    // Therapy condition met and temperature sensor valid:
    if (currentTempC < (27.0 - TEMP_HYSTERESIS_C) ||
        (currentPeltierState == STATE_HEAT && currentTempC < 27.0)) {
      // Temperature < 27°C -> HEAT
      therapyRequested = true;
      therapyStatus = "ON";
      therapyDirection = "HEAT";
      requestedPeltierState = STATE_HEAT;
    } else if (currentTempC > (31.0 + TEMP_HYSTERESIS_C) ||
               (currentPeltierState == STATE_COOL && currentTempC > 31.0)) {
      // Temperature > 31°C -> COOL
      therapyRequested = true;
      therapyStatus = "ON";
      therapyDirection = "COOL";
      requestedPeltierState = STATE_COOL;
    } else {
      // Temperature 27°C to 31°C -> NORMAL -> Therapy OFF
      therapyRequested = false;
      therapyStatus = "OFF";
      therapyDirection = "NORMAL";
      requestedPeltierState = STATE_OFF;
    }
  } else {
    // Sensor failure or condition not met -> Therapy OFF
    therapyRequested = false;
    therapyStatus = "OFF";
    therapyDirection = "OFF";
    requestedPeltierState = STATE_OFF;
  }

  // ── 3. Apply Local Actuation with Safety Engine ──────────────────────
  applyPeltierSafetyControl(requestedPeltierState, currentTempC, tempSensorValid);

  // Sync actual running status with telemetry output
  if (currentPeltierState == STATE_HEAT) {
    therapyStatus = "ON";
    therapyDirection = "HEAT";
  } else if (currentPeltierState == STATE_COOL) {
    therapyStatus = "ON";
    therapyDirection = "COOL";
  } else {
    therapyStatus = "OFF";
    if (fingerDetected && (irValue >= 90000 && irValue < 150000)) {
      therapyDirection = "NORMAL";
    }
  }

  // ── 4. BLE Telemetry Construction & Transmission (1 Hz) ─────────────
  if (now - lastTelemetryTxTime >= TELEMETRY_INTERVAL_MS) {
    lastTelemetryTxTime = now;

    // Create JSON document matching exact RecoverX telemetry schema
    StaticJsonDocument<512> doc;

    doc["device_id"] = DEVICE_NAME;
    doc["timestamp"] = now;

    if (tempSensorValid) {
      doc["temperature_c"] = serialized(String(currentTempC, 1));
    } else {
      doc["temperature_c"] = nullptr;
    }

    doc["max_ir"] = irValue;
    doc["max_red"] = redValue;
    doc["finger_detected"] = fingerDetected;
    doc["therapy_requested"] = therapyRequested;
    doc["therapy_status"] = therapyStatus;
    doc["therapy_direction"] = therapyDirection;

    String jsonPayload;
    serializeJson(doc, jsonPayload);

    // Output to Serial Monitor
    Serial.print("[TELEMETRY] ");
    Serial.println(jsonPayload);

    // Notify connected BLE client
    if (deviceConnected && pTelemetryChar != nullptr) {
      pTelemetryChar->setValue(jsonPayload.c_str());
      pTelemetryChar->notify();
    }
  }
}
