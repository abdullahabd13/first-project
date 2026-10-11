// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 26: _DoctorPortalScaffoldState.build() -> Builds the doctor portal with a top app-bar showing hospital name, shift badge, emergency icon, and doctor avatar; renders the active page from _pages list; bottom nav bar switches between Patients, Beds & Ward, Staff, and Profile tabs. Avatar tap navigates to Profile (index 3).
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/translate/localizations/app_localizations.dart';
import '../../services/app_settings_service.dart';
import '../../services/auth_service.dart';
import '../../themes/app_colors.dart';
import 'doctor_beds_ward_view.dart';
import 'doctor_nursing_roster_view.dart';
import 'doctor_patient_encounter_view.dart';
import 'doctor_profile_view.dart';
import '../widgets/hospital_gradient_header.dart';
import '../widgets/quick_settings_bar.dart';

class DoctorPortalScaffold extends StatefulWidget {
  const DoctorPortalScaffold({super.key});

  @override
  State<DoctorPortalScaffold> createState() => _DoctorPortalScaffoldState();
}

class _DoctorPortalScaffoldState extends State<DoctorPortalScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DoctorPatientEncounterView(),
    DoctorBedsWardView(),
    DoctorNursingRosterView(),
    DoctorProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final doctor = AuthService().currentUser;
    final doctorName = doctor?.name ?? 'Dr. Zaid Al-Husseini';
    final initials = doctorName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join();

    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final isDark = AppSettingsService().isDarkMode;

        final headerBg = isDark ? AppColors.darkSurface : Colors.white;
        final headerBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
        final primaryGreen = isDark ? AppColors.primaryMedium : AppColors.primaryDark;
        final textColor = isDark ? AppColors.darkText : AppColors.textDark;
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
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const HmsLogoWidget(size: 20),
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF14532D) : const Color(0xFFD1FADF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n?.shift1 ?? 'Shift 1',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.primaryLight : const Color(0xFF027A48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            l10n?.doctorClinicalPortal ?? 'DOCTOR CLINICAL PORTAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: mutedColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Row(
                                  children: [
                                    const Icon(Icons.emergency_rounded, color: Colors.redAccent, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n?.emergencyWardAlert ?? 'Emergency Ward Alert',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select clinical emergency trigger:',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                                    ),
                                    const SizedBox(height: 10),
                                    ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.campaign_rounded, color: Colors.redAccent),
                                      title: Text(l10n?.codeBlue ?? 'Code Blue (Cardiac Arrest)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: textColor)),
                                      subtitle: Text('Dispatch rapid response resuscitation team', style: TextStyle(fontSize: 11, color: mutedColor)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('CODE BLUE activated: Resuscitation Team dispatched to Ward 4B.'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.flash_on_rounded, color: Colors.orange),
                                      title: Text(l10n?.rapidResponse ?? 'Rapid Response / STAT Consultation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: textColor)),
                                      subtitle: Text('Urgent attending bedside evaluation', style: TextStyle(fontSize: 11, color: mutedColor)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('STAT clinical request broadcasted across Ward 4B.'),
                                            backgroundColor: primaryGreen,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n?.cancel ?? 'Cancel', style: TextStyle(color: mutedColor)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emergency_rounded, color: Colors.redAccent, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const QuickSettingsBar(isCompact: true),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 3),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: primaryGreen,
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: headerBorder),

                Expanded(
                  child: _pages[_currentIndex],
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            selectedItemColor: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.show_chart_rounded),
                activeIcon: const Icon(Icons.show_chart_rounded),
                label: l10n?.patients ?? 'Patients',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bed_outlined),
                activeIcon: const Icon(Icons.bed_rounded),
                label: l10n?.bedsAndWard ?? 'Beds & Ward',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline_rounded),
                activeIcon: const Icon(Icons.people_rounded),
                label: l10n?.staff ?? 'Staff',
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
