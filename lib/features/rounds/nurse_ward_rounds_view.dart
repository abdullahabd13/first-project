// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 28: NurseWardRoundsView -> Redesigned clinical rounds dashboard with timeline, visual status indicators (Overdue, In-Progress, Upcoming, Completed), quick-action status toggles, WCAG AAA dark/light mode tokens, and full Arabic RTL support.
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/translate/localizations/app_localizations.dart';
import '../../references/mock_hospital_data.dart';
import '../../services/app_settings_service.dart';
import '../../services/auth_service.dart';
import '../../themes/app_colors.dart';

class NurseWardRoundsView extends StatefulWidget {
  const NurseWardRoundsView({super.key});

  @override
  State<NurseWardRoundsView> createState() => _NurseWardRoundsViewState();
}

class _NurseWardRoundsViewState extends State<NurseWardRoundsView> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'All Beds (10)',
    'Overdue (1)',
    'Due Meds (1)',
    'Pending Vitals (2)',
    'Completed (6)',
  ];

  int _selectedRoundTimeline = 1; // Round 2 is active
  bool _isLisinoprilAdministered = false;
  bool _isBed310Completed = false;
  bool _isBed304Completed = false;
  bool _isBed305Completed = false;
  bool _isBed306Completed = false;

  void _showLogVitalsDialog() {
    final l10n = AppLocalizations.of(context);
    final isDark = AppSettingsService().isDarkMode;
    final isAr = AppSettingsService().isArabic;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.monitor_heart_rounded, color: AppColors.primaryDark, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n?.logBesideVitals ?? 'Log Bedside Vitals',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textColor,
                  letterSpacing: isAr ? 0.0 : 0.2,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${tr("Patient")}: Ahmed Tariq • Bed 304-A',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _vitalDialogRow(tr('Blood Pressure'), '135/88 mmHg', Icons.speed_rounded, textColor, mutedColor),
            _vitalDialogRow(tr('Pulse'), '78 bpm (Regular)', Icons.favorite_border_rounded, textColor, mutedColor),
            _vitalDialogRow(tr('SpO2 (Pulse Ox)'), '98% (Room Air)', Icons.air_rounded, textColor, mutedColor),
            _vitalDialogRow(tr('Temperature'), '37.1 °C (Tympanic)', Icons.thermostat_rounded, textColor, mutedColor),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.sync_rounded, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tr('Telemetry synchronizing with central monitor...'),
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel', style: TextStyle(color: mutedColor, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Bedside vitals recorded and logged to hospital EHR.')),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(l10n?.confirm ?? 'Confirm Vitals'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalDialogRow(String label, String value, IconData icon, Color text, Color muted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryMedium),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 12.5, color: text, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _administerMedication() {
    setState(() => _isLisinoprilAdministered = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Lisinopril 10mg Oral administered to Ahmed Tariq. eMAR timestamped.')),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = MockHospitalData.primaryActiveBed;
    final nurseName = AuthService().currentUser?.name ?? 'Fatima Ali, RN';
    final l10n = AppLocalizations.of(context);
    final settings = AppSettingsService();
    final isDark = settings.isDarkMode;
    final isAr = settings.isArabic;

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final primaryGreen = isDark ? AppColors.darkAccent : AppColors.primaryDark;

    // Calculate dynamic round completion
    int completedCount = 6;
    if (_isBed310Completed) completedCount++;
    if (_isBed304Completed) completedCount++;
    if (_isBed305Completed) completedCount++;
    if (_isBed306Completed) completedCount++;
    if (completedCount > 10) completedCount = 10;
    final completionPct = (completedCount / 10.0 * 100).round();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Top Header
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n?.baghdadMedicalCity ?? 'BAGHDAD MEDICAL CITY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primaryGreen,
                        letterSpacing: isAr ? 0.0 : 0.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    CircleAvatar(radius: 3, backgroundColor: primaryGreen),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$nurseName • ${tr("Ward 3")}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: isAr ? 0.0 : 0.2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cardBorder),
              ),
              child: Icon(Icons.qr_code_scanner_rounded, size: 18, color: primaryGreen),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 17,
              backgroundColor: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
              child: Text(
                'FA',
                style: TextStyle(
                  color: isDark ? AppColors.darkAccent : AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Scheduled Clinical Rounds Timeline Dashboard
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: primaryGreen),
                      const SizedBox(width: 6),
                      Text(
                        l10n?.round2of4 ?? 'Round 2 of 4',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: textColor,
                          letterSpacing: isAr ? 0.0 : 0.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    tr('$completedCount of 10 completed ($completionPct%)'),
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: completedCount / 10.0,
                  minHeight: 7,
                  backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                ),
              ),
              const SizedBox(height: 12),

              // Interactive shift rounds timeline badges
              Row(
                children: [
                  _timelineRoundItem(
                    roundLabel: 'R1 (07:00)',
                    statusLabel: tr('Completed'),
                    isCompleted: true,
                    isActive: false,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedRoundTimeline = 0),
                  ),
                  const SizedBox(width: 6),
                  _timelineRoundItem(
                    roundLabel: 'R2 (09:30)',
                    statusLabel: tr('In Progress'),
                    isCompleted: false,
                    isActive: _selectedRoundTimeline == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedRoundTimeline = 1),
                  ),
                  const SizedBox(width: 6),
                  _timelineRoundItem(
                    roundLabel: 'R3 (11:30)',
                    statusLabel: tr('Upcoming'),
                    isCompleted: false,
                    isActive: _selectedRoundTimeline == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedRoundTimeline = 2),
                  ),
                  const SizedBox(width: 6),
                  _timelineRoundItem(
                    roundLabel: 'R4 (13:30)',
                    statusLabel: tr('Scheduled'),
                    isCompleted: false,
                    isActive: _selectedRoundTimeline == 3,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedRoundTimeline = 3),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Priority Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (idx) {
              final active = _selectedFilter == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = idx),
                child: Container(
                  margin: EdgeInsetsDirectional.only(end: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? (isDark ? const Color(0xFF166534) : AppColors.primaryDark)
                        : cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? (isDark ? AppColors.darkAccent : AppColors.primaryDark)
                          : cardBorder,
                      width: active ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (idx == 1) ...[
                        const CircleAvatar(radius: 3.5, backgroundColor: AppColors.emergencyRed),
                        const SizedBox(width: 6),
                      ],
                      if (idx == 2) ...[
                        const CircleAvatar(radius: 3.5, backgroundColor: AppColors.warningAmber),
                        const SizedBox(width: 6),
                      ],
                      if (idx == 3) ...[
                        const CircleAvatar(radius: 3.5, backgroundColor: AppColors.infoBlue),
                        const SizedBox(width: 6),
                      ],
                      if (idx == 4) ...[
                        const CircleAvatar(radius: 3.5, backgroundColor: AppColors.successGreen),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        tr(_filters[idx]),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : mutedColor,
                          letterSpacing: isAr ? 0.0 : 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Overdue Patient Round Card (High Priority Alert)
        if (_selectedFilter == 0 || _selectedFilter == 1) ...[
          _overdueRoundCard(
            bedCode: 'BED 310-C',
            patientName: 'Zainab Noor (38y)',
            clinicalNote: 'Severe Sepsis Protocol • Ceftriaxone 1g IV due 11:30 • Overdue by 15m',
            isCompleted: _isBed310Completed,
            isDark: isDark,
            isAr: isAr,
            cardBg: cardBg,
            cardBorder: cardBorder,
            textColor: textColor,
            mutedColor: mutedColor,
            onToggleStatus: () {
              setState(() => _isBed310Completed = !_isBed310Completed);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isBed310Completed
                      ? tr('Bed 310-C marked as completed.')
                      : tr('Bed 310-C round reopened.')),
                  backgroundColor: _isBed310Completed ? AppColors.successGreen : AppColors.emergencyRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 14),
        ],

        // Section: ACTIVE BEDSIDE CARE
        Row(
          children: [
            CircleAvatar(radius: 3.5, backgroundColor: primaryGreen),
            const SizedBox(width: 6),
            Text(
              l10n?.activeBesideCare ?? 'ACTIVE BEDSIDE CARE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: isAr ? 0.0 : 0.5,
              ),
            ),
            const Spacer(),
            Text(
              tr('Round Timer: 08:24'),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: mutedColor),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Primary Active Bedside Care Card (Ahmed Tariq • Bed 304-A)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isBed304Completed
                  ? (isDark ? AppColors.darkSuccessGreen : AppColors.successGreen)
                  : cardBorder,
              width: _isBed304Completed ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
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
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'BED',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkAccent : AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          '304-A',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkAccent : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              patient.patientName,
                              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: textColor),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreenBorder,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                tr('Stable'),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(patient.demographics, style: TextStyle(fontSize: 11, color: mutedColor)),
                      ],
                    ),
                  ),
                  // Quick Action Status Toggle for Active Bed
                  IconButton(
                    onPressed: () {
                      setState(() => _isBed304Completed = !_isBed304Completed);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isBed304Completed
                              ? tr('Bed 304-A round marked as completed.')
                              : tr('Bed 304-A marked active.')),
                          backgroundColor: _isBed304Completed ? AppColors.successGreen : AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    tooltip: tr('Quick Status Toggle'),
                    icon: Icon(
                      _isBed304Completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: _isBed304Completed
                          ? (isDark ? AppColors.darkAccent : AppColors.successGreen)
                          : mutedColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Vitals Telemetry Grid (WCAG AAA High Contrast)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                childAspectRatio: 2.1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _vitalTile(tr('Blood Pressure'), AppColors.warningAmber, '135/88', 'mmHg • 15m ago', isDark, cardBorder),
                  _vitalTile(tr('Pulse'), AppColors.successGreen, '78 bpm', 'Regular rhythm', isDark, cardBorder),
                  _vitalTile(tr('SpO2 (Pulse Ox)'), AppColors.successGreen, '98%', 'Room air', isDark, cardBorder),
                  _vitalTile(tr('Temperature'), AppColors.successGreen, '37.1 °C', 'Tympanic • Afebrile', isDark, cardBorder),
                ],
              ),
              const SizedBox(height: 14),

              // Active Meds Rows
              _activeMedRow(
                icon: Icons.water_drop_outlined,
                title: 'Saline 0.9% Normal',
                sub: '60 mL/hr • 300 mL remaining',
                badgeText: tr('Infusing'),
                badgeBg: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                badgeColor: isDark ? AppColors.darkTextMuted : const Color(0xFF475569),
                isDark: isDark,
                cardBorder: cardBorder,
              ),
              const SizedBox(height: 8),
              _activeMedRow(
                icon: Icons.medication_rounded,
                title: 'Lisinopril 10mg Oral',
                sub: 'Due in 30m • Hypertension protocol',
                isButton: true,
                btnText: _isLisinoprilAdministered ? tr('Administered ✓') : tr('Administer'),
                onBtnTap: _isLisinoprilAdministered ? null : _administerMedication,
                isDark: isDark,
                cardBorder: cardBorder,
              ),
              const SizedBox(height: 14),

              // Primary Action: Log Bedside Vitals
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _showLogVitalsDialog,
                  icon: const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 20),
                  label: Text(
                    l10n?.logBesideVitals ?? 'Log Bedside Vitals',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: isAr ? 0.0 : 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF166534) : AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section: UPCOMING IN THIS ROUND
        Row(
          children: [
            Text(
              tr('UPCOMING IN THIS ROUND'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: mutedColor,
                letterSpacing: isAr ? 0.0 : 0.5,
              ),
            ),
            const Spacer(),
            Text(tr('2 Beds Remaining'), style: TextStyle(fontSize: 11, color: mutedColor)),
          ],
        ),
        const SizedBox(height: 10),

        // Upcoming Bed 305-B Card
        _upcomingBedCard(
          bedLabel: 'BED 305-B',
          patientName: 'Mariam Al-Saadi (32y)',
          desc: 'Post-Op Day 1 • IV Antibiotic scheduled in 45m',
          actionText: _isBed305Completed ? tr('Completed ✓') : tr('Start Round'),
          isCompleted: _isBed305Completed,
          onAction: () {
            setState(() => _isBed305Completed = !_isBed305Completed);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isBed305Completed
                    ? tr('Bed 305-B marked as completed.')
                    : tr('Starting bedside round for Bed 305-B.')),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          isDark: isDark,
          isAr: isAr,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
        const SizedBox(height: 10),

        // Upcoming Bed 306-A Card
        _upcomingBedCard(
          bedLabel: 'BED 306-A',
          patientName: 'Hussein K. (58y)',
          desc: 'Diabetic Foot Review • Insulin sliding scale check due',
          actionText: _isBed306Completed ? tr('Completed ✓') : tr('Review eMAR'),
          isCompleted: _isBed306Completed,
          onAction: () {
            setState(() => _isBed306Completed = !_isBed306Completed);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isBed306Completed
                    ? tr('Bed 306-A marked as completed.')
                    : tr('Opening eMAR for Bed 306-A.')),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          isDark: isDark,
          isAr: isAr,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
        const SizedBox(height: 20),

        // Section: CLINICAL SHORTCUTS
        Text(
          l10n?.clinicalShortcuts ?? 'CLINICAL SHORTCUTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: mutedColor,
            letterSpacing: isAr ? 0.0 : 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _shortcutTile(
                Icons.qr_code_scanner_rounded,
                l10n?.scanWristband ?? 'Scan\nWristband',
                isDark,
                cardBg,
                cardBorder,
                textColor,
                isAr,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _shortcutTile(
                Icons.phone_in_talk_rounded,
                l10n?.callAttending ?? 'Call\nAttending',
                isDark,
                cardBg,
                cardBorder,
                textColor,
                isAr,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _shortcutTile(
                Icons.report_problem_outlined,
                l10n?.wardIncident ?? 'Ward\nIncident',
                isDark,
                cardBg,
                cardBorder,
                textColor,
                isAr,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _timelineRoundItem({
    required String roundLabel,
    required String statusLabel,
    required bool isCompleted,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    Color bg;
    Color border;
    Color text;

    if (isActive) {
      bg = isDark ? const Color(0xFF166534) : AppColors.mintBackground;
      border = isDark ? AppColors.darkAccent : AppColors.primaryDark;
      text = isDark ? AppColors.darkAccent : AppColors.primaryDark;
    } else if (isCompleted) {
      bg = isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg;
      border = isDark ? AppColors.darkSuccessGreen : AppColors.successGreenBorder;
      text = isDark ? AppColors.darkSuccessGreen : AppColors.successGreen;
    } else {
      bg = isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC);
      border = isDark ? AppColors.darkBorder : AppColors.borderLight;
      text = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    }

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: isActive ? 1.5 : 1.0),
          ),
          child: Column(
            children: [
              Text(
                roundLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: text),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                statusLabel,
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: text),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overdueRoundCard({
    required String bedCode,
    required String patientName,
    required String clinicalNote,
    required bool isCompleted,
    required bool isDark,
    required bool isAr,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color mutedColor,
    required VoidCallback onToggleStatus,
  }) {
    final alertBg = isCompleted
        ? (isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg)
        : (isDark ? AppColors.darkEmergencyRedBg : AppColors.emergencyRedBg);
    final alertBorder = isCompleted
        ? (isDark ? AppColors.darkSuccessGreen : AppColors.successGreenBorder)
        : (isDark ? AppColors.darkEmergencyRed : AppColors.emergencyRedBorder);
    final alertText = isCompleted
        ? (isDark ? AppColors.darkSuccessGreen : AppColors.successGreen)
        : (isDark ? AppColors.darkEmergencyRed : AppColors.emergencyRed);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alertBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? Colors.green : Colors.red).withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: alertBg, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: alertText),
                    const SizedBox(width: 5),
                    Text(
                      isCompleted ? tr('Completed') : tr('Overdue'),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: alertText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                bedCode,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: mutedColor),
              ),
              const Spacer(),
              // Quick action status toggle
              OutlinedButton.icon(
                onPressed: onToggleStatus,
                icon: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                  size: 14,
                  color: alertText,
                ),
                label: Text(
                  isCompleted ? tr('Done ✓') : tr('Administer STAT'),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: alertText),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: alertBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(patientName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 2),
          Text(
            clinicalNote,
            style: TextStyle(
              fontSize: 11,
              color: isCompleted ? mutedColor : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C)),
              height: isAr ? 1.35 : 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalTile(String label, Color dotColor, String val, String sub, bool isDark, Color border) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 3, backgroundColor: dotColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.textDark,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeMedRow({
    required IconData icon,
    required String title,
    required String sub,
    String? badgeText,
    Color? badgeBg,
    Color? badgeColor,
    bool isButton = false,
    String? btnText,
    VoidCallback? onBtnTap,
    required bool isDark,
    required Color cardBorder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? AppColors.darkAccent : AppColors.primaryDark),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textDark,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isButton)
            OutlinedButton(
              onPressed: onBtnTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.darkAccent : AppColors.primaryDark,
                side: BorderSide(color: isDark ? AppColors.darkAccent : AppColors.primaryDark),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(btnText ?? '', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
            )
          else if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
              child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
            ),
        ],
      ),
    );
  }

  Widget _upcomingBedCard({
    required String bedLabel,
    required String patientName,
    required String desc,
    required String actionText,
    required bool isCompleted,
    required VoidCallback onAction,
    required bool isDark,
    required bool isAr,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color mutedColor,
  }) {
    final statusColor = isCompleted
        ? (isDark ? AppColors.darkSuccessGreen : AppColors.successGreen)
        : (isDark ? AppColors.darkInfoBlue : AppColors.infoBlue);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted ? statusColor : cardBorder,
          width: isCompleted ? 1.3 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              bedLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkAccent : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(patientName, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: textColor)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? (isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg)
                            : (isDark ? AppColors.darkInfoBlueBg : AppColors.infoBlueBg),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompleted ? tr('Completed') : tr('Upcoming'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  desc,
                  style: TextStyle(fontSize: 10.5, color: mutedColor, height: isAr ? 1.3 : 1.2),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkAccent : AppColors.primaryDark,
              side: BorderSide(color: isDark ? AppColors.darkAccent : AppColors.primaryDark),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(actionText, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _shortcutTile(IconData icon, String label, bool isDark, Color bg, Color border, Color text, bool isAr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Transform.flip(
            flipX: isAr,
            child: Icon(icon, size: 20, color: isDark ? AppColors.darkAccent : AppColors.primaryDark),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: text,
              height: isAr ? 1.3 : 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
