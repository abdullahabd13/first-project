// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 40: _CreateAccountScreenState.initState() -> Initializes selected role and starts OTP resend countdown.
// - Line 46: _CreateAccountScreenState._startTimer() -> Manages 45-second timer ticker for SMS OTP resending.
// - Line 58: _CreateAccountScreenState.dispose() -> Releases text controllers and cancels active timer.
// - Line 68: _CreateAccountScreenState._handleSignUp() -> Validates terms and registers new account via AuthService.
// - Line 104: _CreateAccountScreenState.build() -> Builds registration view with Phone/Email input modes.
// - Line 364: _CreateAccountScreenState._buildHeader() -> Renders top gradient header with back button and role badge.
// - Line 434: _CreateAccountScreenState._modeTabButton() -> Builds tab button toggling Phone vs Email registration.
// - Line 458: _CreateAccountScreenState._buildLabel() -> Renders standardized input field label text.
// - Line 469: _CreateAccountScreenState._buildTextField() -> Builds rounded text input with icon prefix.
// - Line 501: _CreateAccountScreenState._buildPhoneField() -> Renders phone number field with Iraqi flag and +964 code.
// - Line 550: _CreateAccountScreenState._buildOtpField() -> Builds stylized emerald SMS OTP input field.
// - Line 607: _CreateAccountScreenState._buildPasswordField() -> Builds password field with visibility toggle icon.
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/core.dart';
import 'sign_in_screen.dart';
import 'widgets/hospital_gradient_header.dart';
import 'widgets/quick_settings_bar.dart';

class CreateAccountScreen extends StatefulWidget {
  final UserRole initialRole;

  const CreateAccountScreen({
    super.key,
    this.initialRole = UserRole.doctor,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late UserRole _selectedRole;
  bool _usePhoneMethod = true;

  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _phoneController = TextEditingController(text: '770 123 4567');
  final TextEditingController _otpController = TextEditingController(text: '482 915');
  final TextEditingController _emailController = TextEditingController(text: 'example@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '163822');

  bool _agreeToTerms = true;
  bool _obscurePassword = true;
  int _resendCountdown = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _resendCountdown = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Please accept the Terms & Conditions to proceed.')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final auth = AuthService();
    final success = await auth.signUp(
      name: _nameController.text.trim(),
      email: _usePhoneMethod ? 'user@bmc.iq' : _emailController.text.trim(),
      phone: _usePhoneMethod ? '+964 ${_phoneController.text.trim()}' : '+964 770 123 4567',
      role: _selectedRole,
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr("Account created successfully as")} ${_selectedRole.shortName}! ${tr("H . M . S")}.',
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final isDark = AppSettingsService().isDarkMode;

        final formBg = isDark ? AppColors.darkBackground : Colors.white;
        final cardBg = isDark ? AppColors.darkCard : const Color(0xFFF1F5F3);
        final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
        final textColor = isDark ? AppColors.darkText : AppColors.textDark;
        final mutedColor = isDark ? AppColors.darkTextMuted : const Color(0xFF64748B);
        final fieldBg = isDark ? AppColors.fieldBackgroundDark : const Color(0xFFE2EBE6);

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.primaryDark,
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkHeaderGradient : AppColors.headerGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context, l10n),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: formBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(34),
                          topRight: Radius.circular(34),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 14),
                            Center(
                              child: Text(
                                l10n?.createAccount ?? tr('Create Account'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkText : AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: cardBorder),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _modeTabButton(
                                      title: tr('Phone & OTP (Iraq 🇮🇶)'),
                                      isSelected: _usePhoneMethod,
                                      onTap: () => setState(() => _usePhoneMethod = true),
                                    ),
                                    _modeTabButton(
                                      title: tr('Email & Password'),
                                      isSelected: !_usePhoneMethod,
                                      onTap: () => setState(() => _usePhoneMethod = false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLabel(tr('Name'), textColor),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _nameController,
                              hintText: 'John Doe',
                              icon: Icons.person_outline_rounded,
                              isDark: isDark,
                              fieldBg: fieldBg,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 14),
                            if (_usePhoneMethod) ...[
                              _buildLabel(tr('Phone Number'), textColor),
                              const SizedBox(height: 6),
                              _buildPhoneField(isDark: isDark, fieldBg: fieldBg, textColor: textColor),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLabel(tr('SMS Verification (OTP)'), textColor),
                                  GestureDetector(
                                    onTap: _resendCountdown == 0 ? _startTimer : null,
                                    child: Text(
                                      _resendCountdown > 0
                                          ? 'Resend code (00:${_resendCountdown.toString().padLeft(2, '0')})'
                                          : 'Resend code now',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _resendCountdown > 0
                                            ? mutedColor
                                            : const Color(0xFF1E513B),
                                        decoration: _resendCountdown == 0 ? TextDecoration.underline : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _buildOtpField(isDark: isDark, fieldBg: fieldBg, textColor: textColor),
                            ] else ...[
                              _buildLabel(tr('Email'), textColor),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _emailController,
                                hintText: 'example@gmail.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                isDark: isDark,
                                fieldBg: fieldBg,
                                textColor: textColor,
                              ),
                              const SizedBox(height: 14),
                              _buildLabel(l10n?.password ?? tr('Password'), textColor),
                              const SizedBox(height: 6),
                              _buildPasswordField(),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                                    activeColor: const Color(0xFF1E513B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(fontSize: 12, color: mutedColor),
                                        children: [
                                          TextSpan(text: tr('Agree with ')),
                                          TextSpan(
                                            text: tr('Terms & Conditions'),
                                            style: const TextStyle(
                                              color: Color(0xFF1E513B),
                                              fontWeight: FontWeight.w700,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                key: const Key('signUpButton'),
                                onPressed: auth.isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E513B),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        l10n?.signUp ?? tr('Sign Up'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                key: const Key('goToSignIn'),
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 13, color: mutedColor),
                                    children: [
                                      TextSpan(text: l10n?.alreadyRegistered ?? tr('Already registered? ')),
                                      TextSpan(
                                        text: l10n?.signIn ?? tr('Sign In'),
                                        style: const TextStyle(
                                          color: Color(0xFF1E513B),
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedRole == UserRole.doctor
                          ? Icons.medical_services_rounded
                          : Icons.favorite_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedRole.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const QuickSettingsBar(
                isCompact: true,
                backgroundColor: Colors.white24,
                iconColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.createAccount ?? tr('Create Account'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr('Fill your information below to complete account registration.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E513B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    required Color fieldBg,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextMuted : Colors.blueGrey.shade400,
            fontSize: 13.5,
          ),
          icon: Icon(icon, color: const Color(0xFF4A7260), size: 18),
        ),
      ),
    );
  }

  Widget _buildPhoneField({
    required bool isDark,
    required Color fieldBg,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          const IraqFlagWidget(width: 22, height: 15),
          const SizedBox(width: 8),
          Text(
            '+964',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 18,
            color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '770 123 4567',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : Colors.blueGrey.shade400,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField({
    required bool isDark,
    required Color fieldBg,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.sms_outlined,
            color: isDark ? AppColors.darkAccent : const Color(0xFF1E513B),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 15,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '482 915',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : Colors.blueGrey.shade400,
                  fontSize: 14,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFD1FADF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: isDark ? AppColors.darkAccent : const Color(0xFF027A48),
              size: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E513B),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(
          fontSize: 14,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '••••••••',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            letterSpacing: 2,
          ),
          icon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9EE4C2), size: 18),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF9EE4C2),
              size: 18,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }
}
