// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 35: _SignInScreenState.dispose() -> Disposes all text controllers.
// - Line 45: _SignInScreenState._handleSignIn() -> Signs in with email or phone/OTP.
// - Line 75: _SignInScreenState._quickLogin() -> Quick login for demo.
// - Line 95: _SignInScreenState.build() -> Full sign in screen with i18n & dark mode.
// ============================================================================

import 'package:flutter/material.dart';
import '../core/core.dart';
import 'role_selection_screen.dart';
import 'widgets/hospital_gradient_header.dart';
import 'widgets/quick_settings_bar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _usePhoneMethod = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController(text: 'ahmed.alsaadi@bmc.iq');
  final TextEditingController _passwordController = TextEditingController(text: '163822');
  final TextEditingController _phoneController = TextEditingController(text: '770 123 4567');
  final TextEditingController _otpController = TextEditingController(text: '482 915');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final auth = AuthService();
    bool success;

    if (_usePhoneMethod) {
      success = await auth.signInWithPhone(
        '+964 ${_phoneController.text.trim()}',
        _otpController.text.trim(),
      );
    } else {
      success = await auth.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr("Welcome Back")}, ${auth.currentUser?.name ?? "User"}!',
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _quickLogin(UserRole role) {
    final auth = AuthService();
    auth.quickLogin(role);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged in as ${role.displayName} (${role == UserRole.doctor ? "Dr. Ahmed" : "Nurse Sarah"})',
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showForgotPasswordDialog() {
    final isDark = AppSettingsService().isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: Color(0xFF1E513B)),
            const SizedBox(width: 8),
            Text(tr('Forgot Password?'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
        content: Text(
          'A password reset link or SMS code will be sent to your registered H . M . S clinical account.\n\n(Mock mode: Default credentials are pre-filled).',
          style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Close'), style: const TextStyle(color: Color(0xFF1E513B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                                      title: l10n?.emailAndPassword ?? 'Email & Password',
                                      isSelected: !_usePhoneMethod,
                                      onTap: () => setState(() => _usePhoneMethod = false),
                                      isDark: isDark,
                                    ),
                                    _modeTabButton(
                                      title: l10n?.phoneAndOtp ?? 'Phone & OTP (Iraq 🇮🇶)',
                                      isSelected: _usePhoneMethod,
                                      onTap: () => setState(() => _usePhoneMethod = true),
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            if (!_usePhoneMethod) ...[
                              _buildLabel(l10n?.emailOrClinicalId ?? 'Email or Clinical ID', textColor),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _emailController,
                                hintText: 'ahmed.alsaadi@bmc.iq',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                fieldBg: fieldBg,
                                textColor: textColor,
                              ),
                              const SizedBox(height: 14),

                              _buildLabel(l10n?.password ?? 'Password', textColor),
                              const SizedBox(height: 6),
                              _buildPasswordField(fieldBg, textColor),
                            ] else ...[
                              _buildLabel(l10n?.phoneNumber ?? 'Phone Number', textColor),
                              const SizedBox(height: 6),
                              _buildPhoneField(fieldBg, textColor),
                              const SizedBox(height: 14),

                              _buildLabel(l10n?.smsVerification ?? 'SMS Verification (OTP)', textColor),
                              const SizedBox(height: 6),
                              _buildOtpField(fieldBg, textColor, isDark),
                            ],

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                        activeColor: const Color(0xFF1E513B),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n?.rememberMe ?? 'Remember me',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: mutedColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _showForgotPasswordDialog,
                                  child: Text(
                                    l10n?.forgotPassword ?? 'Forgot Password?',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF1E513B),
                                      fontWeight: FontWeight.w700,
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
                                key: const Key('signInButton'),
                                onPressed: auth.isLoading ? null : _handleSignIn,
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
                                        l10n?.signIn ?? 'Sign In',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF14532D) : const Color(0xFFBBF7D0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF15803D)),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n?.quickDemoAccess ?? 'Quick Demo Access (Mock Data)',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          key: const Key('quickLoginDoctor'),
                                          onPressed: () => _quickLogin(UserRole.doctor),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            side: const BorderSide(color: Color(0xFF1E513B)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            l10n?.doctorLogin ?? '👨‍⚕️ Doctor Login',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E513B),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          key: const Key('quickLoginNurse'),
                                          onPressed: () => _quickLogin(UserRole.nurse),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            side: const BorderSide(color: Color(0xFF1E513B)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            l10n?.nurseLogin ?? '👩‍⚕️ Nurse Login',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E513B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 13, color: mutedColor),
                                    children: [
                                      TextSpan(text: l10n?.dontHaveAccount ?? "Don't have an account? "),
                                      TextSpan(
                                        text: l10n?.signUp ?? 'Sign Up',
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
                ),
                alignment: Alignment.center,
                child: const HmsLogoWidget(size: 22),
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
            l10n?.welcomeBack ?? 'Welcome Back',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.signInSubtitle ?? 'Sign in to access your H . M . S\nclinical portal.',
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
    required bool isDark,
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
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextMuted : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
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
    required Color fieldBg,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
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
            color: Colors.blueGrey.shade400,
            fontSize: 13.5,
          ),
          icon: Icon(icon, color: const Color(0xFF4A7260), size: 18),
        ),
      ),
    );
  }

  Widget _buildPhoneField(Color fieldBg, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(width: 10),
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
                  color: Colors.blueGrey.shade400,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(Color fieldBg, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '••••••••',
          hintStyle: TextStyle(
            color: Colors.blueGrey.shade400,
            fontSize: 13.5,
          ),
          icon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF4A7260), size: 18),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF4A7260),
              size: 18,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(Color fieldBg, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.sms_outlined, color: isDark ? AppColors.darkAccent : const Color(0xFF4A7260), size: 18),
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
}
