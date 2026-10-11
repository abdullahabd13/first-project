// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 11: NurseProfileView.build() -> Builds the nurse profile screen with i18n & dark mode support.
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/translate/localizations/app_localizations.dart';
import '../../services/app_settings_service.dart';
import '../../services/auth_service.dart';
import '../../themes/app_colors.dart';

class NurseProfileView extends StatelessWidget {
  const NurseProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final nurse = AuthService().currentUser;
    final nurseName = nurse?.name ?? 'Fatima Ali, RN';
    final email = nurse?.email ?? 'sarah.kareem@bmc.iq';
    final badgeNumber = nurse?.badgeNumber ?? 'BMC-NUR-308';
    final l10n = AppLocalizations.of(context);
    final isDark = AppSettingsService().isDarkMode;

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final primaryGreen = isDark ? AppColors.darkAccent : AppColors.primaryDark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                child: Text(
                  nurseName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                  style: TextStyle(color: isDark ? AppColors.darkAccent : AppColors.primaryDark, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                nurseName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreenBorder,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  tr('Registered Nurse • Bedside Lead'),
                  style: TextStyle(color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              Text(email, style: TextStyle(color: mutedColor, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '${l10n?.baghdadMedicalCity ?? "H . M . S"} • ${l10n?.nurseBesidePortal ?? "Nursing Portal"}',
                style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w700, fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.clinicalCredentials ?? 'CLINICAL CREDENTIALS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: mutedColor, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              _credentialRow(Icons.badge_outlined, tr('Nurse Badge ID'), badgeNumber, textColor, mutedColor, primaryGreen),
              Divider(height: 16, color: cardBorder),
              _credentialRow(Icons.local_hospital_outlined, tr('Assigned Ward'), tr('Ward 3 • Acute Care & Observation'), textColor, mutedColor, primaryGreen),
              Divider(height: 16, color: cardBorder),
              _credentialRow(Icons.medication_rounded, tr('Prescription Authority'), tr('Restricted: Physician Order Required to Edit.'), textColor, mutedColor, primaryGreen),
              Divider(height: 16, color: cardBorder),
              _credentialRow(Icons.schedule_outlined, tr('Active Shift'), tr('Morning Shift (07:00 - 15:00)'), textColor, mutedColor, primaryGreen),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ListenableBuilder(
          listenable: AppSettingsService(),
          builder: (context, _) {
            final settings = AppSettingsService();
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.appPreferences ?? 'APP PREFERENCES & LOCALIZATION',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: mutedColor, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 18, color: primaryGreen),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n?.displayTheme ?? 'Display Theme', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
                              Text(settings.isDarkMode ? (l10n?.darkMode ?? 'Dark Mode') : (l10n?.lightMode ?? 'Light Mode'), style: TextStyle(fontSize: 10.5, color: mutedColor)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: settings.isDarkMode,
                        activeThumbColor: primaryGreen,
                        onChanged: (_) => settings.toggleTheme(),
                      ),
                    ],
                  ),
                  Divider(height: 16, color: cardBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.language_rounded, size: 18, color: primaryGreen),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n?.portalLanguage ?? 'Portal Language', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
                              Text(settings.isArabic ? 'العربية (RTL)' : 'English (LTR)', style: TextStyle(fontSize: 10.5, color: mutedColor)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => settings.toggleLanguage(),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                        label: Text(settings.isArabic ? 'English' : 'العربية', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            key: const Key('nurseSignOutButton'),
            onPressed: () {
              AuthService().signOut();
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            label: Text(l10n?.signOutNurse ?? 'Sign Out of Nurse Portal', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _credentialRow(IconData icon, String label, String value, Color textColor, Color mutedColor, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10.5, color: mutedColor)),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }
}
