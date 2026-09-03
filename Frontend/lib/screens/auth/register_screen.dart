// ============================================================
// RecoverX — Register Screen
// Full registration form that maps to the backend RegisterRequest.
// On success: auto-logs in and navigates to the dashboard.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_session.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/rx_card.dart';
import '../../widgets/common/rx_gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _sportController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Dropdowns
  String? _selectedGender;
  String? _selectedSportLevel;
  String? _selectedDominantSide;

  static const _genders = ['male', 'female', 'other', 'prefer_not_to_say'];
  static const _sportLevels = ['beginner', 'amateur', 'semi-pro', 'professional', 'elite'];
  static const _sides = ['right', 'left', 'ambidextrous'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _sportController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isSubmitting) return;
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Register the user
      await _authService.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        age: int.parse(_ageController.text.trim()),
        heightCm: double.parse(_heightController.text.trim()),
        weightKg: double.parse(_weightController.text.trim()),
        gender: _selectedGender,
        sport: _sportController.text.trim(),
        sportLevel: _selectedSportLevel,
        dominantSide: _selectedDominantSide,
      );

      // 2. Auto-login after successful registration
      final token = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 3. Save session
      await UserSession.instance.setSession(
        userId: _emailController.text.trim(),
        email: _emailController.text.trim(),
        authToken: token,
      );

      if (!mounted) return;

      // 4. Navigate to dashboard
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.shell,
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Could not connect to server. Check your connection.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Account',
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLG,
            vertical: AppConstants.spaceMD,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Error Banner ──────────────────────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: AppConstants.spaceSM),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMD),
                ],

                // ── Account Details Card ──────────────────────────────────
                RxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Account Details', Icons.person_outline_rounded),
                      const SizedBox(height: AppConstants.spaceMD),
                      _buildField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'e.g. Rahul R',
                        icon: Icons.badge_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      _buildField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter your email';
                          final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!reg.hasMatch(v.trim())) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      _buildPasswordField(
                        controller: _passwordController,
                        label: 'Password',
                        obscure: _obscurePassword,
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a password';
                          if (v.length < 8) return 'At least 8 characters required';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) {
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spaceMD),

                // ── Athlete Profile Card ──────────────────────────────────
                RxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Athlete Profile', Icons.sports_outlined),
                      const SizedBox(height: AppConstants.spaceMD),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _ageController,
                              label: 'Age',
                              hint: '22',
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (int.tryParse(v.trim()) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceMD),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Gender',
                              value: _selectedGender,
                              items: _genders,
                              onChanged: (v) => setState(() => _selectedGender = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _heightController,
                              label: 'Height (cm)',
                              hint: '175',
                              icon: Icons.height_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (double.tryParse(v.trim()) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceMD),
                          Expanded(
                            child: _buildField(
                              controller: _weightController,
                              label: 'Weight (kg)',
                              hint: '70',
                              icon: Icons.monitor_weight_outlined,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (double.tryParse(v.trim()) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      _buildField(
                        controller: _sportController,
                        label: 'Sport',
                        hint: 'e.g. football, basketball',
                        icon: Icons.sports_soccer_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your sport' : null,
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Level',
                              value: _selectedSportLevel,
                              items: _sportLevels,
                              onChanged: (v) => setState(() => _selectedSportLevel = v),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceMD),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Dominant Side',
                              value: _selectedDominantSide,
                              items: _sides,
                              onChanged: (v) => setState(() => _selectedDominantSide = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spaceLG),

                // ── Register Button ───────────────────────────────────────
                RxGradientButton(
                  label: 'CREATE ACCOUNT',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _handleRegister,
                  icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                ),

                const SizedBox(height: AppConstants.spaceMD),

                // ── Already have account ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMD),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget Helpers ──────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, IconData icon) => Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppConstants.spaceSM),
          Text(title, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
        ],
      );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        style: AppTextStyles.bodyMedium,
        validator: validator,
        decoration: _inputDecoration(label: label, hint: hint, icon: icon),
      );

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        style: AppTextStyles.bodyMedium,
        validator: validator,
        decoration: _inputDecoration(
          label: label,
          hint: '••••••••',
          icon: Icons.lock_outlined,
        ).copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      );

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: _inputDecoration(label: label, hint: 'Select', icon: Icons.expand_more_rounded),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        dropdownColor: AppColors.surface,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: AppTextStyles.bodyMedium),
                ))
            .toList(),
        onChanged: onChanged,
      );

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      );
}
