// ============================================================
// RecoverX — User Profile Model
// Encapsulates user profile details and app settings.
// Identity fields (userId, email) are sourced from UserSession.
// Extended attributes & settings are persisted locally via SharedPreferences.
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_session.dart';

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.sport,
    required this.emergencyContact,
    required this.trainingLevel,
    required this.recoveryGoal,
    required this.notificationsEnabled,
    required this.useMetricUnits,
    required this.dataSyncEnabled,
  });

  final String userId;
  final String email;
  final String fullName;
  final String phone;
  final String age;
  final String gender;
  final String height;
  final String weight;
  final String sport;
  final String emergencyContact;
  final String trainingLevel;
  final String recoveryGoal;
  final bool notificationsEnabled;
  final bool useMetricUnits;
  final bool dataSyncEnabled;

  // Storage keys
  static const String _keyFullName = 'profile_full_name';
  static const String _keyPhone = 'profile_phone';
  static const String _keyAge = 'profile_age';
  static const String _keyGender = 'profile_gender';
  static const String _keyHeight = 'profile_height';
  static const String _keyWeight = 'profile_weight';
  static const String _keySport = 'profile_sport';
  static const String _keyEmergencyContact = 'profile_emergency_contact';
  static const String _keyTrainingLevel = 'profile_training_level';
  static const String _keyRecoveryGoal = 'profile_recovery_goal';
  static const String _keyNotifications = 'profile_notifications_enabled';
  static const String _keyUnits = 'profile_unit_metric';
  static const String _keyDataSync = 'profile_data_sync';

  /// Default profile instance combined with current UserSession identity
  static UserProfile defaultProfile() {
    final session = UserSession.instance;
    return UserProfile(
      userId: session.effectiveUserId,
      email: session.userEmail ?? 'alex.morgan@recoverx.io',
      fullName: 'Alex Morgan',
      phone: '+1 (555) 234-5678',
      age: '26',
      gender: 'Female',
      height: '175 cm',
      weight: '68 kg',
      sport: 'Track & Field',
      emergencyContact: 'Sarah Morgan (+1 555-987-6543)',
      trainingLevel: 'Elite / Advanced',
      recoveryGoal: 'HRV & Muscle Recovery',
      notificationsEnabled: true,
      useMetricUnits: true,
      dataSyncEnabled: true,
    );
  }

  /// Load profile from SharedPreferences combined with UserSession identity
  static Future<UserProfile> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final session = UserSession.instance;
    final defaults = defaultProfile();

    return UserProfile(
      userId: session.effectiveUserId,
      email: session.userEmail ?? defaults.email,
      fullName: prefs.getString(_keyFullName) ?? defaults.fullName,
      phone: prefs.getString(_keyPhone) ?? defaults.phone,
      age: prefs.getString(_keyAge) ?? defaults.age,
      gender: prefs.getString(_keyGender) ?? defaults.gender,
      height: prefs.getString(_keyHeight) ?? defaults.height,
      weight: prefs.getString(_keyWeight) ?? defaults.weight,
      sport: prefs.getString(_keySport) ?? defaults.sport,
      emergencyContact: prefs.getString(_keyEmergencyContact) ?? defaults.emergencyContact,
      trainingLevel: prefs.getString(_keyTrainingLevel) ?? defaults.trainingLevel,
      recoveryGoal: prefs.getString(_keyRecoveryGoal) ?? defaults.recoveryGoal,
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? defaults.notificationsEnabled,
      useMetricUnits: prefs.getBool(_keyUnits) ?? defaults.useMetricUnits,
      dataSyncEnabled: prefs.getBool(_keyDataSync) ?? defaults.dataSyncEnabled,
    );
  }

  /// Save profile changes to SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyAge, age);
    await prefs.setString(_keyGender, gender);
    await prefs.setString(_keyHeight, height);
    await prefs.setString(_keyWeight, weight);
    await prefs.setString(_keySport, sport);
    await prefs.setString(_keyEmergencyContact, emergencyContact);
    await prefs.setString(_keyTrainingLevel, trainingLevel);
    await prefs.setString(_keyRecoveryGoal, recoveryGoal);
    await prefs.setBool(_keyNotifications, notificationsEnabled);
    await prefs.setBool(_keyUnits, useMetricUnits);
    await prefs.setBool(_keyDataSync, dataSyncEnabled);
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    String? age,
    String? gender,
    String? height,
    String? weight,
    String? sport,
    String? emergencyContact,
    String? trainingLevel,
    String? recoveryGoal,
    bool? notificationsEnabled,
    bool? useMetricUnits,
    bool? dataSyncEnabled,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      sport: sport ?? this.sport,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      trainingLevel: trainingLevel ?? this.trainingLevel,
      recoveryGoal: recoveryGoal ?? this.recoveryGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      useMetricUnits: useMetricUnits ?? this.useMetricUnits,
      dataSyncEnabled: dataSyncEnabled ?? this.dataSyncEnabled,
    );
  }
}
