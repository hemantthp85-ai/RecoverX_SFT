// ============================================================
// RecoverX — Edit Profile Modal Sheet
// Provides interactive form inputs for updating user profile fields.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_profile.dart';
import '../../../widgets/common/rx_gradient_button.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _sportController;
  late TextEditingController _emergencyController;

  late String _selectedTrainingLevel;
  late String _selectedRecoveryGoal;

  static const List<String> _trainingLevels = [
    'Elite / Advanced',
    'Professional Athlete',
    'Intermediate',
    'Recreational / Fitness Enthusiast',
  ];

  static const List<String> _recoveryGoals = [
    'HRV & Muscle Recovery',
    'Accelerated Healing',
    'Pain Relief & Fatigue Reduction',
    'Daily Performance Readiness',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _ageController = TextEditingController(text: widget.profile.age);
    _genderController = TextEditingController(text: widget.profile.gender);
    _heightController = TextEditingController(text: widget.profile.height);
    _weightController = TextEditingController(text: widget.profile.weight);
    _sportController = TextEditingController(text: widget.profile.sport);
    _emergencyController = TextEditingController(text: widget.profile.emergencyContact);

    _selectedTrainingLevel = _trainingLevels.contains(widget.profile.trainingLevel)
        ? widget.profile.trainingLevel
        : _trainingLevels.first;

    _selectedRecoveryGoal = _recoveryGoals.contains(widget.profile.recoveryGoal)
        ? widget.profile.recoveryGoal
        : _recoveryGoals.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _sportController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.profile.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        age: _ageController.text.trim(),
        gender: _genderController.text.trim(),
        height: _heightController.text.trim(),
        weight: _weightController.text.trim(),
        sport: _sportController.text.trim(),
        emergencyContact: _emergencyController.text.trim(),
        trainingLevel: _selectedTrainingLevel,
        recoveryGoal: _selectedRecoveryGoal,
      );
      widget.onSave(updated);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppConstants.spaceLG,
        right: AppConstants.spaceLG,
        top: AppConstants.spaceMD,
        bottom: AppConstants.spaceLG + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Profile Details',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppConstants.spaceSM),

          // Form fields
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMD),
                        Expanded(
                          child: _buildTextField(
                            controller: _genderController,
                            label: 'Gender',
                            icon: Icons.wc_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: 'Height',
                            icon: Icons.height_outlined,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMD),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Weight',
                            icon: Icons.fitness_center_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    _buildTextField(
                      controller: _sportController,
                      label: 'Primary Sport / Activity',
                      icon: Icons.directions_run_outlined,
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    _buildTextField(
                      controller: _emergencyController,
                      label: 'Emergency Contact',
                      icon: Icons.contact_phone_outlined,
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    _buildDropdown(
                      label: 'Training Level',
                      icon: Icons.military_tech_outlined,
                      value: _selectedTrainingLevel,
                      items: _trainingLevels,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTrainingLevel = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    _buildDropdown(
                      label: 'Preferred Recovery Goal',
                      icon: Icons.track_changes_outlined,
                      value: _selectedRecoveryGoal,
                      items: _recoveryGoals,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRecoveryGoal = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceLG),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),
          RxGradientButton(
            label: 'Save Changes',
            onPressed: _handleSave,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: AppTextStyles.bodyMedium),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
