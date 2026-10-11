// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 20: DoctorBedsWardView -> Floor-grouped ward layout (Floor A, B, C) with interactive floor & availability filter system, and patient room transfer functionality.
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/translate/localizations/app_localizations.dart';
import '../../services/app_settings_service.dart';
import '../../themes/app_colors.dart';

class BedData {
  final String id;
  final String floor;
  final String room;
  final String bedCode;
  String? patientName;
  String? demographics;
  String status; // 'Occupied' or 'Available'
  String? badge;

  BedData({
    required this.id,
    required this.floor,
    required this.room,
    required this.bedCode,
    this.patientName,
    this.demographics,
    required this.status,
    this.badge,
  });

  bool get isAvailable => status == 'Available';
}

class DoctorBedsWardView extends StatefulWidget {
  const DoctorBedsWardView({super.key});

  @override
  State<DoctorBedsWardView> createState() => _DoctorBedsWardViewState();
}

class _DoctorBedsWardViewState extends State<DoctorBedsWardView> {
  String _selectedFloorFilter = 'All'; // 'All', 'Floor A', 'Floor B', 'Floor C'
  String _selectedAvailabilityFilter = 'All'; // 'All', 'Available', 'Occupied'

  final List<BedData> _allBeds = [
    // Floor A
    BedData(id: 'b1', floor: 'Floor A', room: 'Room 101', bedCode: '101-A', patientName: 'Ahmed Tariq', demographics: '45y • M • Hypertensive Urgency', status: 'Occupied', badge: 'Telemetry'),
    BedData(id: 'b2', floor: 'Floor A', room: 'Room 101', bedCode: '101-B', status: 'Available', badge: 'Wall O2 Ready'),
    BedData(id: 'b3', floor: 'Floor A', room: 'Room 102', bedCode: '102-A', patientName: 'Hassan J. Al-Rubaie', demographics: '61y • M • Post-Op Day 2', status: 'Occupied', badge: 'Post-Op'),
    BedData(id: 'b4', floor: 'Floor A', room: 'Room 102', bedCode: '102-B', status: 'Available', badge: 'Sanitized'),

    // Floor B
    BedData(id: 'b5', floor: 'Floor B', room: 'Room 201', bedCode: '201-A', patientName: 'Mariam Al-Saadi', demographics: '32y • F • Post-op review', status: 'Occupied', badge: 'Ward 3B'),
    BedData(id: 'b6', floor: 'Floor B', room: 'Room 201', bedCode: '201-B', patientName: 'Hussein K.', demographics: '58y • M • Diabetic Routine', status: 'Occupied', badge: 'Tele-ready'),
    BedData(id: 'b7', floor: 'Floor B', room: 'Room 202', bedCode: '202-A', status: 'Available', badge: 'Adult Bed'),
    BedData(id: 'b8', floor: 'Floor B', room: 'Room 202', bedCode: '202-B', patientName: 'Zainab Noor', demographics: '41y • F • Ceftriaxone IV', status: 'Occupied', badge: 'IV Infusing'),

    // Floor C
    BedData(id: 'b9', floor: 'Floor C', room: 'Room 301', bedCode: '301-A', patientName: 'Layla Abbas', demographics: '37y • F • Observation', status: 'Occupied', badge: 'Drain Monitored'),
    BedData(id: 'b10', floor: 'Floor C', room: 'Room 301', bedCode: '301-B', status: 'Available', badge: 'Ready'),
    BedData(id: 'b11', floor: 'Floor C', room: 'Room 302', bedCode: '302-A', patientName: 'Omar Kareem', demographics: '50y • M • Cardiac Monitor', status: 'Occupied', badge: 'ICU Step-down'),
    BedData(id: 'b12', floor: 'Floor C', room: 'Room 302', bedCode: '302-B', status: 'Available', badge: 'Ventilator Ready'),
  ];

  void _showTransferPatientDialog(BedData bed) {
    if (bed.isAvailable) return;
    BedData? targetBed;
    final availableTargetBeds = _allBeds.where((b) => b.isAvailable && b.id != bed.id).toList();

    if (availableTargetBeds.isNotEmpty) {
      targetBed = availableTargetBeds.first;
    }

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
                child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF1E513B), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Transfer Patient'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
                    Text('${bed.patientName} (${bed.floor} • ${bed.room} Bed ${bed.bedCode})',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Select target bed for transfer'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 8),
                if (availableTargetBeds.isEmpty)
                  const Text('No available beds to transfer to.', style: TextStyle(color: Colors.redAccent, fontSize: 12))
                else
                  DropdownButtonFormField<BedData>(
                    initialValue: targetBed,
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    items: availableTargetBeds.map((target) {
                      return DropdownMenuItem<BedData>(
                        value: target,
                        child: Text('${target.floor} • ${target.room} (Bed ${target.bedCode})', style: TextStyle(fontSize: 12, color: textColor)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => targetBed = val);
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel'), style: const TextStyle(color: Color(0xFF64748B))),
            ),
            if (availableTargetBeds.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  if (targetBed != null) {
                    setState(() {
                      targetBed!.patientName = bed.patientName;
                      targetBed!.demographics = bed.demographics;
                      targetBed!.status = 'Occupied';
                      targetBed!.badge = 'Transferred';

                      bed.patientName = null;
                      bed.demographics = null;
                      bed.status = 'Available';
                      bed.badge = 'Sanitized';
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Patient transferred to ${targetBed!.floor} ${targetBed!.room} (Bed ${targetBed!.bedCode}).'),
                        backgroundColor: const Color(0xFF1E513B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text(tr('Confirm Transfer')),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E513B), foregroundColor: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  void _reserveBed(BedData bed) {
    setState(() {
      bed.status = 'Occupied';
      bed.patientName = 'Reserved for Direct Admit';
      bed.demographics = 'Incoming Triage';
      bed.badge = 'Reserved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bed ${bed.bedCode} reserved for incoming patient.'),
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

    final totalBedsCount = _allBeds.length;
    final occupiedBedsCount = _allBeds.where((b) => !b.isAvailable).length;
    final availableBedsCount = _allBeds.where((b) => b.isAvailable).length;

    // Filter beds according to selected floor and availability
    final filteredBeds = _allBeds.where((bed) {
      final matchesFloor = _selectedFloorFilter == 'All' || bed.floor == _selectedFloorFilter;
      final matchesAvailability = _selectedAvailabilityFilter == 'All' ||
          (_selectedAvailabilityFilter == 'Available' && bed.isAvailable) ||
          (_selectedAvailabilityFilter == 'Occupied' && !bed.isAvailable);
      return matchesFloor && matchesAvailability;
    }).toList();

    // Group filtered beds by Floor (Floor A, Floor B, Floor C)
    final floors = ['Floor A', 'Floor B', 'Floor C'];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Ward Capacity Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.mainInpatientComplex ?? 'MAIN INPATIENT COMPLEX',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: mutedColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ward Inpatient Operations',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Floors A, B, C • Bed Allocation & Transfer Hub',
                            style: TextStyle(fontSize: 11, color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: totalBedsCount > 0 ? occupiedBedsCount / totalBedsCount : 0,
                                strokeWidth: 4.5,
                                backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.primaryLight : const Color(0xFF1E513B)),
                              ),
                            ),
                            Text(
                              '${((occupiedBedsCount / totalBedsCount) * 100).toInt()}%',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isDark ? AppColors.primaryLight : const Color(0xFF1E513B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(l10n?.capacity ?? 'Capacity', style: TextStyle(fontSize: 9.5, color: mutedColor)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    _statBox(l10n?.totalBeds ?? 'Total', '$totalBedsCount', 'Beds', isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC), textColor, isDark),
                    const SizedBox(width: 8),
                    _statBox(l10n?.occupied ?? 'Occupied', '$occupiedBedsCount', 'Beds', isDark ? const Color(0xFF174230) : const Color(0xFFEBF7F0), const Color(0xFF1E513B), isDark),
                    const SizedBox(width: 8),
                    _statBox(l10n?.availableBeds ?? 'Available', '$availableBedsCount', 'Beds', isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4), const Color(0xFF15803D), isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filters Section (Floor Selector & Availability Selector)
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
                  children: [
                    const Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF1E513B)),
                    const SizedBox(width: 6),
                    Text(
                      l10n?.filterBeds ?? 'Filter Beds',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Floor Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All Floors', _selectedFloorFilter == 'All', () => setState(() => _selectedFloorFilter = 'All'), isDark),
                      _filterChip('Floor A', _selectedFloorFilter == 'Floor A', () => setState(() => _selectedFloorFilter = 'Floor A'), isDark),
                      _filterChip('Floor B', _selectedFloorFilter == 'Floor B', () => setState(() => _selectedFloorFilter = 'Floor B'), isDark),
                      _filterChip('Floor C', _selectedFloorFilter == 'Floor C', () => setState(() => _selectedFloorFilter = 'Floor C'), isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Availability Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All States', _selectedAvailabilityFilter == 'All', () => setState(() => _selectedAvailabilityFilter = 'All'), isDark),
                      _filterChip('🟢 Available Only', _selectedAvailabilityFilter == 'Available', () => setState(() => _selectedAvailabilityFilter = 'Available'), isDark),
                      _filterChip('🔴 Occupied Only', _selectedAvailabilityFilter == 'Occupied', () => setState(() => _selectedAvailabilityFilter = 'Occupied'), isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Floor-Grouped Bed Lists
          ...floors.map((floorName) {
            final floorBeds = filteredBeds.where((b) => b.floor == floorName).toList();
            if (floorBeds.isEmpty) return const SizedBox.shrink();

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
                          floorName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.primaryLight : const Color(0xFF1E513B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${floorBeds.length} Beds Shown',
                        style: TextStyle(fontSize: 11, color: mutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...floorBeds.map((bed) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bed.isAvailable
                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4))
                            : (isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: bed.isAvailable ? const Color(0xFF86EFAC) : cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E513B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              bed.bedCode,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
                                      tr(bed.patientName ?? 'Available Bed'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: bed.isAvailable ? (isDark ? AppColors.primaryLight : const Color(0xFF15803D)) : textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (bed.badge != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: bed.isAvailable ? const Color(0xFFD1FADF) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tr(bed.badge!),
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: bed.isAvailable ? const Color(0xFF027A48) : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${tr(bed.room)} • ${bed.demographics != null ? tr(bed.demographics!) : "Equipped with Wall O2 & Telemetry"}',
                                  style: TextStyle(fontSize: 11, color: mutedColor),
                                ),
                              ],
                            ),
                          ),
                          if (!bed.isAvailable)
                            ElevatedButton.icon(
                              onPressed: () => _showTransferPatientDialog(bed),
                              icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                              label: Text(tr('Transfer'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E513B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => _reserveBed(bed),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF1E513B)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(tr('Reserve'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E513B))),
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
          tr(label),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextMuted : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _statBox(String title, String val, String sub, Color bg, Color textCol, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textCol)),
            Text(sub, style: TextStyle(fontSize: 9, color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
