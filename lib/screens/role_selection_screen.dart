// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 20: _RoleSelectionScreenState.build() -> Renders role selection interface with step progress indicator.
// - Line 233: _RoleSelectionScreenState._buildHeader() -> Renders header with back navigation and hospital cross icon.
// - Line 292: _RoleSelectionScreenState._buildRoleCard() -> Builds selectable card for Doctor or Nurse role.
// ============================================================================

import 'package:flutter/material.dart';
import '../core/core.dart';
import 'create_account_screen.dart';
import 'sign_in_screen.dart';
import 'widgets/hospital_gradient_header.dart';
import 'widgets/quick_settings_bar.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.doctor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final isDark = AppSettingsService().isDarkMode;
        final formBg = isDark ? AppColors.darkBackground : Colors.white;
        final cardBg = isDark ? AppColors.darkCard : const Color(0xFFF3F7F5);
        final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2EBE6);
        final mutedColor = isDark ? AppColors.darkTextMuted : const Color(0xFF64748B);

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
                  _buildHeader(context),
                  const SizedBox(height: 18),
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
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr('STEP 1 OF 2 • ROLE PROFILE'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: mutedColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E3A2E) : const Color(0xFFE4F4EC),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tr('H . M . S'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E513B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildRoleCard(
                              role: UserRole.doctor,
                              title: tr('Doctor / Physician'),
                              description: tr('Consultations, patient diagnostics, clinical care orders & medication prescriptions.'),
                              icon: Icons.medical_services_rounded,
                              tags: [tr('Patient Schedule'), tr('Care Orders')],
                              isSelected: _selectedRole == UserRole.doctor,
                              isDark: isDark,
                              onTap: () {
                                setState(() => _selectedRole = UserRole.doctor);
                              },
                            ),
                            const SizedBox(height: 14),

                            _buildRoleCard(
                              role: UserRole.nurse,
                              title: tr('Nurse / Bedside Care'),
                              description: tr('Bedside ward rounds, vitals telemetry logging, med administration & floor med triage.'),
                              icon: Icons.favorite_rounded,
                              tags: [tr('Ward Rounds'), tr('Med Stock')],
                              isSelected: _selectedRole == UserRole.nurse,
                              isDark: isDark,
                              onTap: () {
                                setState(() => _selectedRole = UserRole.nurse);
                              },
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E3A2E) : const Color(0xFFE0EFE8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.verified_user_outlined,
                                      size: 16,
                                      color: Color(0xFF1E513B),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tr('Hospital credentials and department assignment will be verified during profile fill in the next step.'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.35,
                                        color: mutedColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                key: const Key('roleContinue'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreateAccountScreen(
                                        initialRole: _selectedRole,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E513B),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tr('Continue to Registration'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            Center(
                              child: GestureDetector(
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
                                      TextSpan(text: tr('Already registered? ')),
                                      TextSpan(
                                        text: tr('Sign In'),
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

  Widget _buildHeader(BuildContext context) {
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
          const SizedBox(height: 12),
          Text(
            tr('Select Your Role'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr('Choose your clinical portal profile to\nproceed with account registration.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.3,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required List<String> tags,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    const activeGreen = Color(0xFF1E513B);
    final borderColor = isSelected ? activeGreen : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0));
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF1E3A2E) : const Color(0xFFF1F8F4))
        : (isDark ? AppColors.darkCard : Colors.white);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeGreen.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? activeGreen : (isDark ? const Color(0xFF263238) : const Color(0xFFE5F1EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected ? Colors.white : activeGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? (isDark ? const Color(0xFF66BB6A) : activeGreen)
                                : (isDark ? AppColors.darkText : const Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? activeGreen : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                        width: 2,
                      ),
                      color: isDark ? AppColors.darkCard : Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: isSelected
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeGreen,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF2C4A3C) : const Color(0xFFE2F0E8))
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? const Color(0xFF388E3C) : const Color(0xFFC7E3D4))
                            : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (isDark ? const Color(0xFF81C784) : activeGreen)
                            : (isDark ? AppColors.darkTextMuted : const Color(0xFF475569)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
