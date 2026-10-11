// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 20: DoctorNursingRosterView -> Floor-grouped nursing staff page matching Beds & Ward changes, with floor filters, interactive patient assignment, contact dialog, i18n, and dark mode support.
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/translate/localizations/app_localizations.dart';
import '../../services/app_settings_service.dart';
import '../../themes/app_colors.dart';

class NurseStaffData {
  final String id;
  final String name;
  final String initials;
  final String floor;
  final String role;
  final String ext;
  final String loadText;
  final double loadFraction;
  final String statusBadge;
  final bool isAvailable;
  final List<String> assignedBeds;

  NurseStaffData({
    required this.id,
    required this.name,
    required this.initials,
    required this.floor,
    required this.role,
    required this.ext,
    required this.loadText,
    required this.loadFraction,
    required this.statusBadge,
    required this.isAvailable,
    required this.assignedBeds,
  });
}

class DoctorNursingRosterView extends StatefulWidget {
  const DoctorNursingRosterView({super.key});

  @override
  State<DoctorNursingRosterView> createState() => _DoctorNursingRosterViewState();
}

class _DoctorNursingRosterViewState extends State<DoctorNursingRosterView> {
  String _selectedFloorFilter = 'All'; // 'All', 'Floor A', 'Floor B', 'Floor C'
  String _selectedLoadFilter = 'All'; // 'All', 'Available', 'High Load'

  final List<NurseStaffData> _nurses = [
    // Floor A
    NurseStaffData(
      id: 'n1',
      name: 'Fatima Ali, RN',
      initials: 'FA',
      floor: 'Floor A',
      role: 'Lead Nurse • Acute Ward 1',
      ext: 'Ext. 214',
      loadText: '3/5 (Moderate)',
      loadFraction: 0.6,
      statusBadge: 'Available to Assign',
      isAvailable: true,
      assignedBeds: ['Bed 101-A', 'Bed 102-A'],
    ),
    NurseStaffData(
      id: 'n2',
      name: 'Sarah Kareem, BSN',
      initials: 'SK',
      floor: 'Floor A',
      role: 'Floor Float • Ward 1',
      ext: 'Ext. 218',
      loadText: '5/5 (Max)',
      loadFraction: 1.0,
      statusBadge: 'High Load',
      isAvailable: false,
      assignedBeds: ['Bed 101-B', 'Bed 102-B', 'Bed 103-A'],
    ),

    // Floor B
    NurseStaffData(
      id: 'n3',
      name: 'Omar Kareem, RN',
      initials: 'OK',
      floor: 'Floor B',
      role: 'Observation Lead • Ward 2',
      ext: 'Ext. 301',
      loadText: '2/5 (Light)',
      loadFraction: 0.4,
      statusBadge: 'Available to Assign',
      isAvailable: true,
      assignedBeds: ['Bed 201-A'],
    ),
    NurseStaffData(
      id: 'n4',
      name: 'Noor Al-Hassan, RN',
      initials: 'NH',
      floor: 'Floor B',
      role: 'Staff Nurse • Ward 2',
      ext: 'Ext. 305',
      loadText: '4/5 (Moderate)',
      loadFraction: 0.8,
      statusBadge: 'Available to Assign',
      isAvailable: true,
      assignedBeds: ['Bed 201-B', 'Bed 202-B'],
    ),

    // Floor C
    NurseStaffData(
      id: 'n5',
      name: 'Mustafa Raheem, RN',
      initials: 'MR',
      floor: 'Floor C',
      role: 'Telemetry Nurse • Ward 3',
      ext: 'Ext. 402',
      loadText: '1/5 (Light)',
      loadFraction: 0.2,
      statusBadge: 'Optimal Availability',
      isAvailable: true,
      assignedBeds: ['Bed 301-A'],
    ),
    NurseStaffData(
      id: 'n6',
      name: 'Zainab Omran, RN',
      initials: 'ZO',
      floor: 'Floor C',
      role: 'ICU Step-down Nurse',
      ext: 'Ext. 410',
      loadText: '5/5 (Max)',
      loadFraction: 1.0,
      statusBadge: 'High Load',
      isAvailable: false,
      assignedBeds: ['Bed 302-A', 'Bed 302-B'],
    ),
  ];

  void _showAssignPatientDialog(NurseStaffData nurse) {
    String selectedPatientBed = 'Bed 304-A • Ahmed Tariq';
    final patientOptions = [
      'Bed 304-A • Ahmed Tariq',
      'Bed 306-B • Mariam Al-Saadi',
      'Bed 304-B • Hussein K.',
      'Bed 301-A • Zainab Omran',
    ];

    final isDark = AppSettingsService().isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFE2F0EC), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF1E513B), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Assign Nurse to Patient'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
                    Text('${nurse.name} (${nurse.floor} • ${nurse.ext})', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Select Inpatient Bed:'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedPatientBed,
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                items: patientOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(opt, style: TextStyle(fontSize: 12, color: textColor)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedPatientBed = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.fieldBackgroundDark : const Color(0xFFF1F5F3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel'), style: const TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final bedCode = selectedPatientBed.split(' • ').first;
                  if (!nurse.assignedBeds.contains(bedCode)) {
                    nurse.assignedBeds.add(bedCode);
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${nurse.name} assigned to $selectedPatientBed.'),
                    backgroundColor: const Color(0xFF1E513B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E513B), foregroundColor: Colors.white),
              child: Text(tr('Confirm Assignment')),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactNurseDialog(NurseStaffData nurse) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Calling {name} ({ext})...').replaceFirst('{name}', nurse.name).replaceFirst('{ext}', nurse.ext)),
        backgroundColor: const Color(0xFF1E513B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = AppSettingsService().isDarkMode;

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    final totalNurses = _nurses.length;
    final availableNurses = _nurses.where((n) => n.isAvailable).length;

    // Filter nurses by floor and load status
    final filteredNurses = _nurses.where((n) {
      final matchesFloor = _selectedFloorFilter == 'All' || n.floor == _selectedFloorFilter;
      final matchesLoad = _selectedLoadFilter == 'All' ||
          (_selectedLoadFilter == 'Available' && n.isAvailable) ||
          (_selectedLoadFilter == 'High Load' && !n.isAvailable);
      return matchesFloor && matchesLoad;
    }).toList();

    final floors = ['Floor A', 'Floor B', 'Floor C'];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.morningShift ?? 'MORNING SHIFT • 07:00 - 15:00',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF174230) : const Color(0xFFE2F0EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: Color(0xFF1E513B)),
                    const SizedBox(width: 4),
                    Text(l10n?.liveSync ?? 'Live Sync', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? AppColors.primaryLight : const Color(0xFF1E513B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.floorNursingRoster ?? 'Floor Nursing Roster',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
          ),
          const SizedBox(height: 12),

          // Charge Nurse Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF1E513B),
                  child: Text('FA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Fatima Ali, RN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF174230) : const Color(0xFFE2F0EC), borderRadius: BorderRadius.circular(8)),
                            child: Text(l10n?.leadCharge ?? 'Charge Nurse', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isDark ? AppColors.primaryLight : const Color(0xFF1E513B))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Ward Shift Supervisor • Extension #4301', style: TextStyle(fontSize: 10.5, color: mutedColor)),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF174230) : const Color(0xFFE2F0EC), shape: BoxShape.circle),
                  child: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Color(0xFF1E513B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stat Items
          Row(
            children: [
              _statItem('$totalNurses', l10n?.onDuty ?? 'On Duty', textColor, cardBg, isDark),
              const SizedBox(width: 8),
              _statItem('$availableNurses', l10n?.availableToAssign ?? 'Available', const Color(0xFF1E513B), isDark ? const Color(0xFF174230) : const Color(0xFFE2F0EC), isDark),
              const SizedBox(width: 8),
              _statItem('${totalNurses - availableNurses}', l10n?.highLoad ?? 'High Load', const Color(0xFFB45309), isDark ? const Color(0xFF713F12) : const Color(0xFFFEF3C7), isDark),
            ],
          ),
          const SizedBox(height: 14),

          // Filters Section
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
                Text(tr('Filter Staff Roster'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(tr('All Floors'), _selectedFloorFilter == 'All', () => setState(() => _selectedFloorFilter = 'All'), isDark),
                      _filterChip(tr('Floor A'), _selectedFloorFilter == 'Floor A', () => setState(() => _selectedFloorFilter = 'Floor A'), isDark),
                      _filterChip(tr('Floor B'), _selectedFloorFilter == 'Floor B', () => setState(() => _selectedFloorFilter = 'Floor B'), isDark),
                      _filterChip(tr('Floor C'), _selectedFloorFilter == 'Floor C', () => setState(() => _selectedFloorFilter = 'Floor C'), isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(tr('All Load States'), _selectedLoadFilter == 'All', () => setState(() => _selectedLoadFilter = 'All'), isDark),
                      _filterChip(tr('🟢 Available'), _selectedLoadFilter == 'Available', () => setState(() => _selectedLoadFilter = 'Available'), isDark),
                      _filterChip(tr('🔴 High Load'), _selectedLoadFilter == 'High Load', () => setState(() => _selectedLoadFilter = 'High Load'), isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Floor-Grouped Staff Cards
          ...floors.map((floorName) {
            final floorNurses = filteredNurses.where((n) => n.floor == floorName).toList();
            if (floorNurses.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF174230) : const Color(0xFFE2F0EC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tr(floorName).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.primaryLight : const Color(0xFF1E513B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${floorNurses.length} ${tr('Staff On Floor')}', style: TextStyle(fontSize: 11, color: mutedColor)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...floorNurses.map((nurse) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF1E513B),
                                child: Text(
                                  nurse.initials,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nurse.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: textColor)),
                                    Text('${nurse.role} • ${nurse.ext}', style: TextStyle(fontSize: 11, color: mutedColor)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: nurse.isAvailable ? (isDark ? const Color(0xFF14532D) : const Color(0xFFD1FADF)) : (isDark ? const Color(0xFF713F12) : const Color(0xFFFEF3C7)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tr(nurse.statusBadge),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: nurse.isAvailable ? (isDark ? AppColors.primaryLight : const Color(0xFF027A48)) : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${tr('Patient Load')}:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: mutedColor)),
                              Text(tr(nurse.loadText), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: nurse.loadFraction,
                              minHeight: 5,
                              backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(nurse.isAvailable ? const Color(0xFF1E513B) : Colors.amber.shade800),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 4,
                                  children: nurse.assignedBeds.map((bed) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.fieldBackgroundDark : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(bed, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor)),
                                    );
                                  }).toList(),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _showAssignPatientDialog(nurse),
                                icon: const Icon(Icons.add, size: 14),
                                label: Text(l10n?.assignToPatient ?? '+ Assign', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E513B),
                                  side: const BorderSide(color: Color(0xFF1E513B)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.phone_in_talk_rounded, size: 18, color: Color(0xFF1E513B)),
                                onPressed: () => _showContactNurseDialog(nurse),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E513B) : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF1E513B) : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0))),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextMuted : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String val, String label, Color textColor, Color bg, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
