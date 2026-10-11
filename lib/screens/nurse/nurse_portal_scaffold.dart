// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 29: _NursePortalScaffoldState.build() -> Builds the nurse portal with a top app-bar (hospital name, morning-shift badge, nurse avatar that navigates to Profile on tap), the active page view, and a bottom nav bar switching between Rounds, Pharmacy, and Profile tabs.
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/translate/localizations/app_localizations.dart';
import '../../services/app_settings_service.dart';
import '../../services/auth_service.dart';
import '../../themes/app_colors.dart';
import 'nurse_pharmacy_dispensary_view.dart';
import 'nurse_profile_view.dart';
import 'nurse_ward_rounds_view.dart';
import '../widgets/hospital_gradient_header.dart';
import '../widgets/quick_settings_bar.dart';

class NursePortalScaffold extends StatefulWidget {
  const NursePortalScaffold({super.key});

  @override
  State<NursePortalScaffold> createState() => _NursePortalScaffoldState();
}

class _NursePortalScaffoldState extends State<NursePortalScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    NurseWardRoundsView(),
    NursePharmacyDispensaryView(),
    NurseProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final nurse = AuthService().currentUser;
    final nurseName = nurse?.name ?? 'Fatima Ali, RN';
    final initials = nurseName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join();

    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final isDark = AppSettingsService().isDarkMode;

        final isArabic = AppSettingsService().isArabic;
        final headerBg = isDark ? AppColors.darkSurface : Colors.white;
        final headerBorder = isDark ? AppColors.darkBorder : AppColors.borderLight;
        final primaryGreen = isDark ? AppColors.darkAccent : AppColors.primaryDark;
        final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: headerBg,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF166534) : AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const HmsLogoWidget(size: 18),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n?.baghdadMedicalCity ?? 'H . M . S',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: primaryGreen,
                                  letterSpacing: isArabic ? 0.0 : 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n?.morningShiftWard3 ?? '• Morning Shift (Ward 3)',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkAccent : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            l10n?.nurseBesidePortal ?? 'NURSE BEDSIDE & DISPENSARY PORTAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: mutedColor,
                              letterSpacing: isArabic ? 0.0 : 0.4,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const QuickSettingsBar(isCompact: true),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 2),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: isDark ? const Color(0xFF166534) : AppColors.primaryDark,
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: headerBorder),

                Expanded(child: _pages[_currentIndex]),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            selectedItemColor: isDark ? AppColors.darkAccent : AppColors.primaryDark,
            unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: isArabic ? 0.0 : 0.2,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: isArabic ? 0.0 : 0.2,
            ),
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.assignment_turned_in_outlined),
                activeIcon: const Icon(Icons.assignment_turned_in_rounded),
                label: l10n?.rounds ?? 'Rounds',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.local_pharmacy_outlined),
                activeIcon: const Icon(Icons.local_pharmacy_rounded),
                label: l10n?.pharmacy ?? 'Pharmacy',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                label: l10n?.profile ?? 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
