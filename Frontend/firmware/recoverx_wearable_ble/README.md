# RecoverX ESP32-C3 Wearable Firmware (v2.0.0)

## 1. Overview
This firmware runs on the **ESP32-C3 Mini / Super Mini** microcontroller board inside the RecoverX smart recovery wearable device.
It acquires real-time physical sensor data, computes **autonomous local therapy decisions** on-chip, controls the **Peltier thermoelectric module via L298N Channel B**, enforces **multi-level thermal safety protections**, and broadcasts live telemetry via **Bluetooth Low Energy (BLE)** to the RecoverX application.

---

## 2. Hardware Pinout & Wiring Table (ESP32-C3)

| Component | Pin Function | ESP32-C3 Pin | Notes |
| --- | --- | --- | --- |
| **DS18B20** | Data | `GPIO 10` | 4.7kΩ pull-up resistor to 3.3V. **DO NOT use GPIO 2.** |
| **MAX30102** | SDA | `GPIO 8` | I2C Data line |
| **MAX30102** | SCL | `GPIO 9` | I2C Clock line |
| **L298N Channel B** | ENB | `GPIO 6` | Enable Peltier power |
| **L298N Channel B** | IN3 | `GPIO 4` | Direction polarity A |
| **L298N Channel B** | IN4 | `GPIO 5` | Direction polarity B |
| **FSR402** | Analog Out | `GPIO 0` | Physical pressure sensor (Telemetry monitoring only; **NEVER** used in therapy logic) |

---

## 3. L298N / Peltier Control States

| State | ENB (GPIO 6) | IN3 (GPIO 4) | IN4 (GPIO 5) | Physical Action |
| --- | --- | --- | --- | --- |
| **OFF** | `LOW` | `LOW` | `LOW` | Peltier completely powered off |
| **HEAT** | `HIGH` | `HIGH` | `LOW` | Forward polarity heating mode |
| **COOL** | `HIGH` | `LOW` | `HIGH` | Reverse polarity cooling mode |

---

## 4. Autonomous Local Therapy Decision Logic

The therapy decision operates **100% locally on the ESP32-C3**. It does **not** depend on phone BLE, Flutter, backend, or cloud connectivity.

### MAX30102 Infrared (IR) Thresholds:
- **IR < 1000**: Finger NOT detected $\rightarrow$ **Therapy OFF**
- **1000 $\le$ IR < 90000**: **THERAPY CONDITION**
- **90000 $\le$ IR < 150000**: **NORMAL** $\rightarrow$ **Therapy OFF**
- **IR $\ge$ 150000**: **THERAPY CONDITION**

### Temperature Thresholds:
- **Temperature < 27°C**: **HEAT**
- **Temperature 27°C to 31°C**: **NORMAL** $\rightarrow$ **Therapy OFF**
- **Temperature > 31°C**: **COOL**

### Combined Decision Matrix:
```
IF IR < 1000:
    Therapy OFF
ELSE IF 90000 <= IR < 150000:
    Therapy OFF
ELSE IF therapy condition AND temperature < 27°C:
    HEAT
ELSE IF therapy condition AND temperature > 31°C:
    COOL
ELSE:
    Therapy OFF
```

---

## 5. Built-in Safety Engine

1. **Direction Reversal Deadband Delay**:
   - The Peltier is **never rapidly flipped** between HEAT and COOL.
   - When changing direction, the firmware forces the Peltier **OFF** for a minimum of **2000 ms** before activating the opposite polarity.
2. **Temperature Sensor Failure Auto-Cutoff**:
   - If the DS18B20 disconnects or returns invalid values ($-999^\circ\text{C}$ or outside $10^\circ\text{C} - 45^\circ\text{C}$ safe skin bounds), the Peltier is immediately forced **OFF**.
3. **Maximum Therapy Continuous Runtime Cutoff**:
   - Continuous active therapy is capped at **15 minutes (900,000 ms)** max, followed by a mandatory **2-minute cooldown**.
4. **Thermal Hysteresis**:
   - $0.5^\circ\text{C}$ hysteresis prevents high-frequency relay/MOSFET chatter around the $27^\circ\text{C}$ and $31^\circ\text{C}$ boundaries.

---

## 6. BLE Configuration & Telemetry Format

- **Device Name**: `RecoverX_Wearable`
- **Service UUID**: `19b10000-e8f2-537e-4f6c-d104768a1214`
- **Telemetry Characteristic UUID**: `19b10001-e8f2-537e-4f6c-d104768a1214`
- **BLE MTU**: Set to `512` bytes
- **Notification Interval**: 1 second (1 Hz)

### Exact Telemetry JSON Contract:
```json
{
  "device_id": "RecoverX_Wearable",
  "timestamp": 12345,
  "temperature_c": 29.4,
  "max_ir": 45231,
  "max_red": 38210,
  "finger_detected": true,
  "therapy_requested": false,
  "therapy_status": "OFF",
  "therapy_direction": "NORMAL"
}
```

---

## 7. Required Arduino Libraries
- **OneWire** (`PaulStoffregen/OneWire`)
- **DallasTemperature** (`MilesBurton/Arduino-Temperature-Control-Library`)
- **SparkFun MAX3010x** (`MAX30105`)
- **ArduinoJson** v6 or v7 (`bblanchon/ArduinoJson`)
- **ESP32 BLE Arduino** (Included with ESP32 board support package)
