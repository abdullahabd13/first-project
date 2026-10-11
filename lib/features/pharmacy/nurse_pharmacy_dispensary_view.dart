// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 45: BedsidePatientQueueItem & BedsideMedicationOrder -> Data models for patient medication queue.
// - Line 90: _NursePharmacyDispensaryViewState -> Bedside Medication Administration with patient queue, multi-select checkboxes, Confirm & Save / Transfer actions, smooth animated transitions, and auto-advance to next patient.
// - Line 140: _confirmAndSaveMedications() -> Confirms selected medications, removes processed patient from queue with smooth transition, auto-advances to next patient, and updates PharmacyService.
// - Line 180: _transferPatientOrder() -> Transfers medication order out of active queue, animates removal, and auto-advances to next patient.
// - Line 220: _showVendDialog() -> Vault dispenser unit vend modal dialog.
// - Line 360: _showDetailsDialog() -> Clinical drug monograph dialog.
// - Line 450: _showLogUseDialog() -> Floor stock usage logging dialog.
// - Line 550: _showUnlockDialog() -> Narcotic Schedule II dual-witness unlock dialog.
// - Line 660: _showBarcodeScannerDialog() -> Optical barcode scanning simulation.
// - Line 730: _showViewRxDialog() -> Attending physician prescription order review dialog.
// - Line 800: build() -> Builds complete pharmacy dispensary screen with bedside administration queue, shift dispensing velocity, STAT pneumatic pod, vault dispenser units, and pending clearance orders.
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/translate/localizations/app_localizations.dart';
import '../../models/pharmacy_item_model.dart';
import '../../services/app_settings_service.dart';
import '../../services/auth_service.dart';
import '../../services/pharmacy_service.dart';
import '../../themes/app_colors.dart';

class BedsidePatientQueueItem {
  final String id;
  final String bedCode;
  final String patientName;
  final String demographics;
  final String condition;
  final String physician;
  final List<BedsideMedicationOrder> orders;

  const BedsidePatientQueueItem({
    required this.id,
    required this.bedCode,
    required this.patientName,
    required this.demographics,
    required this.condition,
    required this.physician,
    required this.orders,
  });

  BedsidePatientQueueItem copyWith({
    String? id,
    String? bedCode,
    String? patientName,
    String? demographics,
    String? condition,
    String? physician,
    List<BedsideMedicationOrder>? orders,
  }) {
    return BedsidePatientQueueItem(
      id: id ?? this.id,
      bedCode: bedCode ?? this.bedCode,
      patientName: patientName ?? this.patientName,
      demographics: demographics ?? this.demographics,
      condition: condition ?? this.condition,
      physician: physician ?? this.physician,
      orders: orders ?? this.orders,
    );
  }
}

class BedsideMedicationOrder {
  final String id;
  final String medicationName;
  final String dosageAndRoute;
  final String scheduleTime;
  final String prescriber;
  final String status; // 'Verified', 'New Dose', 'STAT Urgent', 'Due Now'
  final bool isControlled;

  const BedsideMedicationOrder({
    required this.id,
    required this.medicationName,
    required this.dosageAndRoute,
    required this.scheduleTime,
    required this.prescriber,
    required this.status,
    this.isControlled = false,
  });
}

class NursePharmacyDispensaryView extends StatefulWidget {
  const NursePharmacyDispensaryView({super.key});

  @override
  State<NursePharmacyDispensaryView> createState() => _NursePharmacyDispensaryViewState();
}

class _NursePharmacyDispensaryViewState extends State<NursePharmacyDispensaryView> {
  int _selectedMedFilter = 0;
  final List<String> _medFilters = ['All Medications', 'IV Solutions', 'Oral Antibiotics'];
  final TextEditingController _searchController = TextEditingController();

  // Bedside Patient Queue State
  late List<BedsidePatientQueueItem> _patientQueue;
  int _selectedPatientIndex = 0;
  Set<String> _selectedMedOrderIds = {};
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _resetPatientQueue();
  }

  void _resetPatientQueue() {
    _patientQueue = [
      BedsidePatientQueueItem(
        id: 'pt-01',
        bedCode: 'Bed 304-A',
        patientName: 'Ahmed Tariq',
        demographics: 'Male, 45y • Post-cholecystectomy',
        condition: 'Hypertension & Post-Op Recovery',
        physician: 'Dr. Zaid Al-Husseini',
        orders: const [
          BedsideMedicationOrder(
            id: 'rx-01',
            medicationName: 'Amlodipine 5mg',
            dosageAndRoute: 'Oral • Once daily at 08:00',
            scheduleTime: '08:00 Due',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'Verified',
          ),
          BedsideMedicationOrder(
            id: 'rx-02',
            medicationName: 'Lisinopril 10mg',
            dosageAndRoute: 'Oral • Morning titration',
            scheduleTime: '08:30 Titration',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'New Dose',
          ),
          BedsideMedicationOrder(
            id: 'rx-03',
            medicationName: 'Normal Saline 0.9%',
            dosageAndRoute: 'IV Infusion • 60 mL/hr',
            scheduleTime: 'Continuous',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'Active Order',
          ),
        ],
      ),
      BedsidePatientQueueItem(
        id: 'pt-02',
        bedCode: 'Bed 305-B',
        patientName: 'Layla Abbas',
        demographics: 'Female, 52y • Surgical Day 1',
        condition: 'Post-op inspection & drain check',
        physician: 'Dr. Zaid Al-Husseini',
        orders: const [
          BedsideMedicationOrder(
            id: 'rx-04',
            medicationName: 'Cefazolin 1g IV',
            dosageAndRoute: 'IV Bolus • Q8H Post-Op',
            scheduleTime: '09:00 Due',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'Verified',
          ),
          BedsideMedicationOrder(
            id: 'rx-05',
            medicationName: 'Paracetamol 1g IV',
            dosageAndRoute: 'IV Infusion • Q6H PRN Analgesia',
            scheduleTime: '09:30 Due',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'Due Now',
          ),
        ],
      ),
      BedsidePatientQueueItem(
        id: 'pt-03',
        bedCode: 'Bed 310-C',
        patientName: 'Zainab Noor',
        demographics: 'Female, 38y • Sepsis Protocol',
        condition: 'Severe Sepsis Protocol',
        physician: 'Dr. Zaid Al-Husseini',
        orders: const [
          BedsideMedicationOrder(
            id: 'rx-06',
            medicationName: 'Ceftriaxone 1g IV',
            dosageAndRoute: 'IV Piggyback • Sepsis Protocol',
            scheduleTime: 'STAT 11:30',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'STAT Urgent',
          ),
          BedsideMedicationOrder(
            id: 'rx-07',
            medicationName: 'Normal Saline 500mL Bolus',
            dosageAndRoute: 'IV Rapid Infusion',
            scheduleTime: 'STAT Infusion',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'Verified',
          ),
        ],
      ),
      BedsidePatientQueueItem(
        id: 'pt-04',
        bedCode: 'Bed 306-A',
        patientName: 'Hussein K.',
        demographics: 'Male, 58y • Diabetic Check',
        condition: 'Type 2 Diabetes & Foot Ulcer',
        physician: 'Dr. Zaid Al-Husseini',
        orders: const [
          BedsideMedicationOrder(
            id: 'rx-08',
            medicationName: 'Insulin Regular 6 Units',
            dosageAndRoute: 'SubQ • Sliding Scale Check',
            scheduleTime: '11:45 Pre-Meal',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'Due Now',
          ),
          BedsideMedicationOrder(
            id: 'rx-09',
            medicationName: 'Metformin 500mg Oral',
            dosageAndRoute: 'Oral Tab • With Lunch',
            scheduleTime: '12:00 Scheduled',
            prescriber: 'Dr. Zaid Al-Husseini',
            status: 'Verified',
          ),
        ],
      ),
    ];
    _selectedPatientIndex = 0;
    _selectedMedOrderIds = _patientQueue.first.orders.map((o) => o.id).toSet();
  }

  void _onSelectPatient(int index) {
    if (index >= 0 && index < _patientQueue.length) {
      setState(() {
        _selectedPatientIndex = index;
        _selectedMedOrderIds = _patientQueue[index].orders.map((o) => o.id).toSet();
      });
    }
  }

  void _toggleMedOrder(String orderId) {
    setState(() {
      if (_selectedMedOrderIds.contains(orderId)) {
        _selectedMedOrderIds.remove(orderId);
      } else {
        _selectedMedOrderIds.add(orderId);
      }
    });
  }

  void _selectAllOrders(bool select) {
    if (_patientQueue.isEmpty) return;
    final currentPatient = _patientQueue[_selectedPatientIndex];
    setState(() {
      if (select) {
        _selectedMedOrderIds = currentPatient.orders.map((o) => o.id).toSet();
      } else {
        _selectedMedOrderIds.clear();
      }
    });
  }

  /// Confirm and save active medication orders for bedside administration.
  /// Smoothly animates the processed patient card out of the active queue,
  /// auto-advances to the next patient in the queue, and updates PharmacyService.
  void _confirmAndSaveMedications() async {
    if (_patientQueue.isEmpty) return;
    final currentPatient = _patientQueue[_selectedPatientIndex];
    final processedCount = _selectedMedOrderIds.length;

    setState(() => _isTransitioning = true);
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    // Update underlying PharmacyService
    final pharmacy = PharmacyService();
    if (currentPatient.patientName == 'Ahmed Tariq') {
      pharmacy.bringPrescriptionToPatient();
    } else {
      pharmacy.vendMedication('disp-01', quantity: processedCount > 0 ? processedCount : 1);
    }

    setState(() {
      _patientQueue.removeAt(_selectedPatientIndex);
      _isTransitioning = false;

      if (_patientQueue.isNotEmpty) {
        _selectedPatientIndex = _selectedPatientIndex % _patientQueue.length;
        _selectedMedOrderIds = _patientQueue[_selectedPatientIndex].orders.map((o) => o.id).toSet();
      } else {
        _selectedMedOrderIds.clear();
      }
    });

    final nextPatientName = _patientQueue.isNotEmpty ? _patientQueue[_selectedPatientIndex].patientName : '';
    final nextBedCode = _patientQueue.isNotEmpty ? _patientQueue[_selectedPatientIndex].bedCode : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _patientQueue.isNotEmpty
              ? '${tr("Confirmed & saved $processedCount medication(s) for")} ${currentPatient.patientName} (${currentPatient.bedCode}). ${tr("Auto-advancing to next patient:")} $nextPatientName ($nextBedCode).'
              : tr("All active patient medication orders processed & confirmed for Ward 3 bedside rounds!"),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Transfer / Handover active medication orders to the next nurse/shift.
  /// Smoothly animates the patient card out of the current queue and auto-advances.
  void _transferPatientOrder() async {
    if (_patientQueue.isEmpty) return;
    final currentPatient = _patientQueue[_selectedPatientIndex];

    setState(() => _isTransitioning = true);
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      _patientQueue.removeAt(_selectedPatientIndex);
      _isTransitioning = false;

      if (_patientQueue.isNotEmpty) {
        _selectedPatientIndex = _selectedPatientIndex % _patientQueue.length;
        _selectedMedOrderIds = _patientQueue[_selectedPatientIndex].orders.map((o) => o.id).toSet();
      } else {
        _selectedMedOrderIds.clear();
      }
    });

    final nextPatientName = _patientQueue.isNotEmpty ? _patientQueue[_selectedPatientIndex].patientName : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _patientQueue.isNotEmpty
              ? '${tr("Medication orders for")} ${currentPatient.patientName} ${tr("transferred to shift handover.")} ${tr("Auto-advancing to next patient:")} $nextPatientName.'
              : tr("All patient orders transferred successfully."),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showVendDialog(DispenserMedication med) {
    int quantity = 1;
    String selectedPatient = 'Bed 304-A • Ahmed Tariq';
    final patients = [
      'Bed 304-A • Ahmed Tariq',
      'Bed 310-C • Zainab Noor',
      'Bed 302-B • Zainab Omran',
      'Floor Stock • Unallocated',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.mintBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.outbox_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Automated Vault Vend'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(tr('Dispensary Unit W3-A'), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medication_rounded, color: AppColors.primaryDark, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                            Text('${med.form} • ${med.drawer}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text('${med.unitsAvailable} ${tr("units currently in vault")}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.successGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(tr('Allocate to Patient / Bed'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedPatient,
                  items: patients.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedPatient = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('Dispense Quantity'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: quantity > 1 ? () => setDlgState(() => quantity--) : null,
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: quantity < med.unitsAvailable ? () => setDlgState(() => quantity++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel'), style: const TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final success = PharmacyService().vendMedication(med.id, quantity: quantity, patientBed: selectedPatient);
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tr("Vended")} $quantity ${tr("unit(s) of")} ${med.name} ${tr("from")} ${med.drawer} ${tr("for")} $selectedPatient.'),
                      backgroundColor: AppColors.primaryDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text(tr('Dispense Unit')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(DispenserMedication med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.info_outline_rounded, color: Color(0xFF0369A1), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(tr('Clinical Drug Monograph'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(med.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text('${med.form} • ${med.drawer}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _detailRow(tr('Available Stock'), '${med.unitsAvailable} ${tr("units")}'),
                    const Divider(height: 10),
                    _detailRow(tr('Inventory Status'), med.statusBadge),
                    const Divider(height: 10),
                    _detailRow(tr('Location / Bin'), med.drawer),
                    const Divider(height: 10),
                    _detailRow(tr('Schedule Control'), med.isControlled ? tr('Schedule II (Controlled)') : tr('Standard Prescription')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(tr('Clinical Pharmacology & Guidelines'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text(
                tr('Indicated for essential hypertension & cardiovascular management. Confirm baseline renal panel and blood pressure prior to administration. Verify unit dose against physician prescription before handing to bedside nurse.'),
                style: const TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFF92400E)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tr('Auto-Reorder trigger active at < 15 units. Batch refill order #BM-914 dispatched to Central Stores.'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              PharmacyService().requestRestock();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${tr("Reorder request submitted for")} ${med.name}.'), backgroundColor: AppColors.primaryDark),
              );
            },
            child: Text(tr('Request Restock'), style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: Text(tr('Close'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogUseDialog(DispenserMedication med) {
    int bagsUsed = 1;
    String selectedPurpose = 'IV Hydration Maintenance';
    String selectedBed = 'Bed 304-A • Ahmed Tariq';
    final purposes = [
      'IV Hydration Maintenance',
      'Medication Dilution & Piggyback',
      'Catheter & Line Flush',
      'Resuscitation Protocol',
    ];
    final beds = [
      'Bed 304-A • Ahmed Tariq',
      'Bed 310-C • Zainab Noor',
      'Bed 302-B • Zainab Omran',
      'Ward Floor Reserve',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.mintBackground, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tr('Log Floor Stock Usage'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text('${med.form} • ${med.drawer}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Text(tr('Select Patient / Bed'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedBed,
                  items: beds.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedBed = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Text(tr('Clinical Indication / Purpose'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedPurpose,
                  items: purposes.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedPurpose = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('Quantity Used'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: bagsUsed > 1 ? () => setDlgState(() => bagsUsed--) : null,
                        ),
                        Text('$bagsUsed', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: bagsUsed < med.unitsAvailable ? () => setDlgState(() => bagsUsed++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel'), style: const TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                final success = PharmacyService().logUsage(med.id, bagsUsed, patientBed: selectedBed, reason: selectedPurpose);
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tr("Logged")} $bagsUsed ${tr("unit(s) of")} ${med.name} ${tr("for")} $selectedBed ($selectedPurpose).'),
                      backgroundColor: AppColors.primaryDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(tr('Record & Deduct Stock')),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnlockDialog(DispenserMedication med) {
    String selectedWitness = 'Nurse Sarah Tariq, BSN (Shift Float)';
    final witnesses = [
      'Nurse Sarah Tariq, BSN (Shift Float)',
      'Dr. Zaid Al-Husseini, MD (Attending)',
      'Nurse Omar Kareem, RN (Floor Lead)',
    ];
    final pinController = TextEditingController(text: '4829');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.lock_open_rounded, color: Color(0xFFB91C1C), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Vault Safe Dual Witness'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(tr('Schedule II Narcotic Security Protocol'), style: const TextStyle(fontSize: 10.5, color: Color(0xFFB91C1C), fontWeight: FontWeight.w700)),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: Color(0xFFB91C1C), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF991B1B))),
                            Text('${med.form} • ${med.unitsAvailable} ${tr("ampules remaining")}', style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(tr('Co-Signing Witness (Mandatory)'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedWitness,
                  items: witnesses.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 11.5)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedWitness = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Text(tr('Vault Authorization PIN'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pin_outlined, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('Note: Audit trail will record timestamps, Nurse ID, witness ID, and serial count.'),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel'), style: const TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final success = PharmacyService().unlockVault(med.id, witnessName: selectedWitness, pin: pinController.text);
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tr("Vault Safe unlocked for")} ${med.name}. ${tr("Dual witness authorized by")} $selectedWitness.'),
                      backgroundColor: AppColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.lock_open_rounded, size: 16),
              label: Text(tr('Authorize & Unlock')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBarcodeScannerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(tr('Optical Barcode Scanner'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 50, color: Color(0xFF10B981)),
                  const SizedBox(height: 6),
                  Text(tr('Scanning Unit-Dose Barcode...'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD1FADF), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF027A48), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scanned: Amlodipine 5mg (Drawer 2B)\nLot: #AM-2026-94 • Exp: 12/2027',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF027A48)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Close'), style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              PharmacyService().vendMedication('disp-01');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Vended scanned unit Amlodipine 5mg from Drawer 2B.')),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: Text(tr('Vend Scanned Unit'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStatBreakdownDialog(String title, String count, String desc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$count Total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF475569))),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: Text(tr('Close'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
      ],
    );
  }

  void _showViewRxDialog(PendingDoctorOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(tr('Doctor Prescription Order'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tr("Patient")}: ${order.patientName} (${order.bedCode})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 4),
            Text('${tr("Ordered by")}: ${order.orderingDoctor}', style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.regimenName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  const Text('• Amlodipine 5mg Oral (Once daily at 08:00)', style: TextStyle(fontSize: 11.5)),
                  const Text('• Lisinopril 10mg Oral (Titration dose)', style: TextStyle(fontSize: 11.5)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF92400E)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tr('Authority Note: Only attending doctors can edit dosages. Nurse role is to retrieve medication from pharmacy for the patient.'),
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Close'), style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              PharmacyService().bringPrescriptionToPatient();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Medication retrieved from dispensary and brought to Ahmed Tariq (Bed 304-A).')),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            label: Text(tr('Bring Meds to Patient'), style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return ListenableBuilder(
      listenable: Listenable.merge([PharmacyService(), AppSettingsService()]),
      builder: (context, _) {
        final pharmacy = PharmacyService();
        final pod = pharmacy.activePod;
        final docOrder = pharmacy.doctorRxOrder;
        final dispenserItems = pharmacy.dispenserItems;

        final query = _searchController.text.trim().toLowerCase();
        final filteredItems = dispenserItems.where((med) {
          final matchesQuery = query.isEmpty ||
              med.name.toLowerCase().contains(query) ||
              med.form.toLowerCase().contains(query) ||
              med.drawer.toLowerCase().contains(query) ||
              med.statusBadge.toLowerCase().contains(query);

          if (!matchesQuery) return false;

          if (_selectedMedFilter == 1) {
            return med.form.toLowerCase().contains('bag') ||
                med.form.toLowerCase().contains('ml') ||
                med.form.toLowerCase().contains('iv') ||
                med.name.toLowerCase().contains('saline');
          } else if (_selectedMedFilter == 2) {
            return med.form.toLowerCase().contains('tab') ||
                med.form.toLowerCase().contains('oral') ||
                med.name.toLowerCase().contains('lisinopril') ||
                med.name.toLowerCase().contains('amlodipine');
          }
          return true;
        }).toList();

        final hasPatientsInQueue = _patientQueue.isNotEmpty;
        final currentPatient = hasPatientsInQueue ? _patientQueue[_selectedPatientIndex] : null;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Satellite Dispensary Header
            Container(
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.local_pharmacy_rounded, color: primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.wardSatelliteDispensary ?? 'Ward 3 Satellite Dispensary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: isAr ? 0.0 : 0.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreenBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          tr('Automated Hub Active'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$nurseName • Station ID: W3-PYX-02',
                        style: TextStyle(fontSize: 11, color: mutedColor),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const CircleAvatar(radius: 3, backgroundColor: AppColors.successGreen),
                          const SizedBox(width: 4),
                          Text(
                            tr('Pneumatic Tube Online'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section: SHIFT DISPENSING VELOCITY
            Row(
              children: [
                CircleAvatar(radius: 3.5, backgroundColor: primaryGreen),
                const SizedBox(width: 6),
                Text(
                  l10n?.shiftDispensingVelocity ?? 'SHIFT DISPENSING VELOCITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: isAr ? 0.0 : 0.5,
                  ),
                ),
                const Spacer(),
                Text(tr('Cycle: 07:00 - 15:00'), style: TextStyle(fontSize: 10.5, color: mutedColor)),
              ],
            ),
            const SizedBox(height: 8),

            // Shift velocity stat cards (WCAG AAA High Contrast)
            Row(
              children: [
                _dispenseStatBox(
                  '${pharmacy.dispensedAndVerified}',
                  tr('Dispensed\n& Verified'),
                  isDark ? AppColors.darkSuccessGreenBg : const Color(0xFFEBF7F0),
                  isDark ? AppColors.darkSuccessGreen : AppColors.successGreen,
                  isDark,
                  onTap: () => _showStatBreakdownDialog(
                    tr('Dispensed & Verified Units'),
                    '${pharmacy.dispensedAndVerified}',
                    tr('Dose units successfully dispensed, verified by dual witness (where required), and logged to ward patient beds during this shift cycle.'),
                  ),
                ),
                const SizedBox(width: 8),
                _dispenseStatBox(
                  '${pharmacy.pendingCheck}',
                  tr('Pending\nCheck'),
                  isDark ? AppColors.darkWarningAmberBg : const Color(0xFFFEF3C7),
                  isDark ? AppColors.darkWarningAmber : AppColors.warningAmber,
                  isDark,
                  onTap: () => _showStatBreakdownDialog(
                    tr('Pending Pharmacist Checks'),
                    '${pharmacy.pendingCheck}',
                    tr('Prescription orders requiring final pharmacist clearance and dosing confirmation prior to bedside administration.'),
                  ),
                ),
                const SizedBox(width: 8),
                _dispenseStatBox(
                  '${pharmacy.statUrgents}',
                  tr('STAT\nUrgents'),
                  isDark ? AppColors.darkEmergencyRedBg : const Color(0xFFFEE2E2),
                  isDark ? AppColors.darkEmergencyRed : AppColors.emergencyRed,
                  isDark,
                  onTap: () => _showStatBreakdownDialog(
                    tr('STAT Urgent Deliveries'),
                    '${pharmacy.statUrgents}',
                    tr('Priority high-acuity orders dispatched via pneumatic tube requiring immediate delivery to patient bedside.'),
                  ),
                ),
                const SizedBox(width: 8),
                _dispenseStatBox(
                  '${pharmacy.stockOuts}',
                  tr('Stock\nOuts'),
                  isDark ? const Color(0xFF0F291E) : const Color(0xFFF0FDF4),
                  isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                  isDark,
                  onTap: () => _showStatBreakdownDialog(
                    tr('Dispensary Stock Outs'),
                    '${pharmacy.stockOuts}',
                    tr('Zero stockouts in Satellite Vault W3-A. All critical emergency and floor medications are fully stocked.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ================================================================
            // BEDSIDE MEDICATION ADMINISTRATION & PATIENT QUEUE (MODULE 1)
            // ================================================================
            Row(
              children: [
                Icon(Icons.medication_liquid_rounded, size: 16, color: primaryGreen),
                const SizedBox(width: 6),
                Text(
                  tr('Bedside Medication Administration'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: isAr ? 0.0 : 0.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_patientQueue.length} ${tr("Patients in Queue")}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Patient Selection Queue Track
            if (hasPatientsInQueue) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_patientQueue.length, (idx) {
                    final item = _patientQueue[idx];
                    final isSelected = _selectedPatientIndex == idx;
                    return GestureDetector(
                      onTap: () => _onSelectPatient(idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF166534) : AppColors.mintBackground)
                              : cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.darkAccent : AppColors.primaryDark)
                                : cardBorder,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (isDark ? AppColors.darkAccent : AppColors.primaryDark).withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppColors.darkAccent : AppColors.primaryDark)
                                    : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.bedCode,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF0B1320) : Colors.white)
                                      : mutedColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.patientName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? (isDark ? Colors.white : AppColors.primaryDark)
                                        : textColor,
                                  ),
                                ),
                                Text(
                                  '${item.orders.length} ${tr("Med orders")}',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: isSelected
                                        ? (isDark ? AppColors.darkTextMuted : AppColors.primaryDark)
                                        : mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),

              // Active Medication Orders and Prescription Details Box with Transition
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isTransitioning ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
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
                      // Selected Patient Clinical Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.person_rounded, size: 16, color: primaryGreen),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${currentPatient!.patientName} (${currentPatient.bedCode})',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        tr('Active Patient'),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.darkSuccessGreen : AppColors.successGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${currentPatient.demographics} • ${currentPatient.physician}',
                                  style: TextStyle(fontSize: 10, color: mutedColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Selection Toolbar
                      Row(
                        children: [
                          Text(
                            tr('Select Prescribed Medications:'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: mutedColor,
                              letterSpacing: isAr ? 0.0 : 0.3,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              final allSelected = _selectedMedOrderIds.length == currentPatient.orders.length;
                              _selectAllOrders(!allSelected);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _selectedMedOrderIds.length == currentPatient.orders.length
                                  ? tr('Deselect All')
                                  : tr('Select All'),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Prescribed Medications List with Multi-Select Checkboxes
                      ...currentPatient.orders.map((order) {
                        final isChecked = _selectedMedOrderIds.contains(order.id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isChecked
                                  ? (isDark ? AppColors.darkAccent : AppColors.primaryDark)
                                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                              width: isChecked ? 1.4 : 1.0,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _toggleMedOrder(order.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: primaryGreen,
                                    onChanged: (_) => _toggleMedOrder(order.id),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              order.medicationName,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w800,
                                                color: textColor,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getOrderBadgeBg(order.status, isDark),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                tr(order.status),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: _getOrderBadgeText(order.status, isDark),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${order.dosageAndRoute} • ${order.scheduleTime}',
                                          style: TextStyle(fontSize: 10.5, color: mutedColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Pick, Confirm & Transfer Action Buttons
                      Row(
                        children: [
                          // Primary: Confirm & Save
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: _selectedMedOrderIds.isNotEmpty ? _confirmAndSaveMedications : null,
                              icon: const Icon(Icons.check_circle_rounded, size: 16),
                              label: Text(
                                tr('Confirm & Save'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: isAr ? 0.0 : 0.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF166534) : AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Secondary: Transfer / Handover
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: _transferPatientOrder,
                              icon: Transform.flip(
                                flipX: isAr,
                                child: const Icon(Icons.swap_horiz_rounded, size: 16),
                              ),
                              label: Text(
                                tr('Transfer / Handover'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: isAr ? 0.0 : 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? AppColors.darkInfoBlue : AppColors.infoBlue,
                                side: BorderSide(color: isDark ? AppColors.darkInfoBlue : AppColors.infoBlue),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Queue Empty / Completed View
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.task_alt_rounded, size: 40, color: primaryGreen),
                    const SizedBox(height: 8),
                    Text(
                      tr('All Patients Processed'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('All active patient medication orders processed & confirmed for Ward 3 bedside rounds!'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: mutedColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _resetPatientQueue()),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(tr('Reset Patient Queue')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF166534) : AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            // STAT Pneumatic Pod Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkEmergencyRed : const Color(0xFFFCA5A5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.04),
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
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkEmergencyRedBg : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tr('STAT ORDER'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkEmergencyRed : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(pod.podNumber, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: mutedColor)),
                      const Spacer(),
                      const Text('🚀', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(pod.medicationName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 2),
                  Text('${tr("Patient")}: ${pod.patientName} • ${pod.bedCode} (${pod.protocol})', style: TextStyle(fontSize: 11, color: mutedColor)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.send_rounded, size: 14, color: primaryGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pod.stationLocation,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryGreen),
                        ),
                      ),
                      Icon(Icons.access_time_rounded, size: 13, color: mutedColor),
                      const SizedBox(width: 4),
                      Text(pod.etaText, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: mutedColor)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: pod.status == PodStatus.inTransit
                          ? () {
                              pharmacy.acknowledgePodReceipt();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('Pod #07 acknowledged. Bring medication to Zainab Noor (Bed 310-C).')),
                                  backgroundColor: AppColors.primaryDark,
                                ),
                              );
                            }
                          : pod.status == PodStatus.receivedAtStation
                              ? () {
                                  pharmacy.deliverPodToPatient();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(tr('Ceftriaxone 1g IV delivered to Bed 310-C.')),
                                      backgroundColor: AppColors.successGreen,
                                    ),
                                  );
                                }
                              : null,
                      icon: Icon(
                        pod.status == PodStatus.deliveredToPatient ? Icons.check_circle_rounded : Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        pod.status == PodStatus.inTransit
                            ? tr('Acknowledge Receipt at Station')
                            : pod.status == PodStatus.receivedAtStation
                                ? tr('Bring Med to Patient (Bed 310-C)')
                                : tr('Delivered & Administered ✓'),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pod.status == PodStatus.deliveredToPatient ? AppColors.successGreen : AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Ward Med Dispenser Units Section
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 16, color: primaryGreen),
                const SizedBox(width: 6),
                Text(
                  l10n?.wardMedDispenserUnits ?? 'Ward Med Dispenser Units',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: textColor),
                ),
                const Spacer(),
                Text(tr('Vault W3-A'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: mutedColor)),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: textColor, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: tr('Search drug, generic name, barcode...'),
                        hintStyle: TextStyle(fontSize: 11.5, color: mutedColor),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                      onPressed: () => setState(() => _searchController.clear()),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner_rounded, color: primaryGreen, size: 18),
                    onPressed: _showBarcodeScannerDialog,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: tr('Scan Barcode'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_medFilters.length, (idx) {
                  final active = _selectedMedFilter == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMedFilter = idx),
                    child: Container(
                      margin: EdgeInsetsDirectional.only(end: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: active
                            ? (isDark ? const Color(0xFF166534) : AppColors.primaryDark)
                            : cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active
                              ? (isDark ? AppColors.darkAccent : AppColors.primaryDark)
                              : cardBorder,
                        ),
                      ),
                      child: Text(
                        tr(_medFilters[idx]),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : mutedColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),

            if (filteredItems.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                alignment: Alignment.center,
                child: Text(
                  tr('No medications found matching your filter criteria.'),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutedColor),
                ),
              )
            else
              ...filteredItems.map((med) => _dispenserItemTile(
                    med: med,
                    isDark: isDark,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    primaryGreen: primaryGreen,
                    onActionTap: () {
                      if (med.actionType == 'Vend') {
                        _showVendDialog(med);
                      } else if (med.actionType == 'Details') {
                        _showDetailsDialog(med);
                      } else if (med.actionType == 'Log Use') {
                        _showLogUseDialog(med);
                      } else if (med.actionType == 'Unlock') {
                        _showUnlockDialog(med);
                      } else {
                        _showDetailsDialog(med);
                      }
                    },
                  )),
            const SizedBox(height: 16),

            // Orders Pending Clearance Section
            Row(
              children: [
                Icon(Icons.assignment_turned_in_outlined, size: 16, color: primaryGreen),
                const SizedBox(width: 6),
                Text(
                  l10n?.ordersPendingClearance ?? 'Orders Pending Clearance',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: textColor),
                ),
                const Spacer(),
                Text('1 In Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryGreen)),
              ],
            ),
            const SizedBox(height: 8),

            Container(
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
                      Text(docOrder.patientName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
                      const SizedBox(width: 6),
                      Text(docOrder.bedCode, style: TextStyle(fontSize: 11, color: mutedColor)),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Text(docOrder.timeAgo, style: TextStyle(fontSize: 10, color: mutedColor)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(docOrder.regimenName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen)),
                  const SizedBox(height: 2),
                  Text('${tr("Ordering")}: ${docOrder.orderingDoctor}', style: TextStyle(fontSize: 11, color: mutedColor)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const CircleAvatar(radius: 3, backgroundColor: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          docOrder.pharmacistReviewStatus,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showViewRxDialog(docOrder),
                        icon: Icon(Icons.open_in_new_rounded, size: 12, color: primaryGreen),
                        label: Text(
                          docOrder.isBroughtToPatient ? tr('Delivered ✓') : tr('View RX'),
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: primaryGreen),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cardBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Actions: Request Restock & Central Call
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      pharmacy.requestRestock();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('Restock request submitted to Central Pharmacy.')), backgroundColor: AppColors.primaryDark),
                      );
                    },
                    icon: Icon(Icons.add_shopping_cart_rounded, size: 16, color: primaryGreen),
                    label: Text(
                      tr('Request Restock'),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryGreen),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF14532D) : AppColors.mintBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showCallCentralPharmacyDialog,
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.white),
                    label: Text(
                      tr('Central Ext #4102'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF166534) : AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Color _getOrderBadgeBg(String status, bool isDark) {
    switch (status) {
      case 'STAT Urgent':
        return isDark ? AppColors.darkEmergencyRedBg : AppColors.emergencyRedBg;
      case 'Due Now':
        return isDark ? AppColors.darkWarningAmberBg : AppColors.warningAmberBg;
      case 'Verified':
        return isDark ? AppColors.darkSuccessGreenBg : AppColors.successGreenBg;
      default:
        return isDark ? AppColors.darkInfoBlueBg : AppColors.infoBlueBg;
    }
  }

  Color _getOrderBadgeText(String status, bool isDark) {
    switch (status) {
      case 'STAT Urgent':
        return isDark ? AppColors.darkEmergencyRed : AppColors.emergencyRed;
      case 'Due Now':
        return isDark ? AppColors.darkWarningAmber : AppColors.warningAmber;
      case 'Verified':
        return isDark ? AppColors.darkSuccessGreen : AppColors.successGreen;
      default:
        return isDark ? AppColors.darkInfoBlue : AppColors.infoBlue;
    }
  }

  void _showCallCentralPharmacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.mintBackground, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Central Pharmacy Direct'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(tr('Internal Ward Intercom • Ext #4102'), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primaryDark,
                    radius: 16,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pharm. Sarah Mansour, PharmD', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('On-Duty Lead Pharmacist (Central)', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFD1FADF), borderRadius: BorderRadius.circular(6)),
                    child: Text(tr('Available'), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF027A48))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(tr('Priority Options'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flash_on_rounded, color: Color(0xFFB91C1C), size: 20),
              title: Text(tr('Escalate STAT Order'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              subtitle: Text(tr('Priority pneumatic tube dispatch'), style: const TextStyle(fontSize: 10.5)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('STAT escalation signal dispatched to Central Pharmacy desk.')),
                    backgroundColor: const Color(0xFFB91C1C),
                  ),
                );
              },
            ),
            const Divider(height: 8),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_rounded, color: AppColors.primaryDark, size: 20),
              title: Text(tr('Inquire Stock / Batch Compounding'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              subtitle: Text(tr('Check central warehouse availability'), style: const TextStyle(fontSize: 10.5)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('Stock inquiry sent to compounding cleanroom.')),
                    backgroundColor: AppColors.primaryDark,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Dismiss'), style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Connecting voice intercom to Central Pharmacy (Ext. #4102)...')),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
            icon: const Icon(Icons.call, size: 16),
            label: Text(tr('Connect Audio Call')),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _dispenseStatBox(String num, String label, Color bg, Color text, bool isDark, {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? text.withValues(alpha: 0.3) : text.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Text(num, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: text)),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dispenserItemTile({
    required DispenserMedication med,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color mutedColor,
    required Color primaryGreen,
    required VoidCallback onActionTap,
  }) {
    Color badgeBg;
    Color badgeText;
    switch (med.statusBadge) {
      case 'Normal':
        badgeBg = isDark ? AppColors.darkSuccessGreenBg : const Color(0xFFD1FADF);
        badgeText = isDark ? AppColors.darkSuccessGreen : const Color(0xFF027A48);
        break;
      case 'Auto-Reordered':
        badgeBg = isDark ? AppColors.darkWarningAmberBg : const Color(0xFFFEF3C7);
        badgeText = isDark ? AppColors.darkWarningAmber : const Color(0xFF92400E);
        break;
      case 'Optimal':
        badgeBg = isDark ? AppColors.darkInfoBlueBg : const Color(0xFFE0F2FE);
        badgeText = isDark ? AppColors.darkInfoBlue : const Color(0xFF0369A1);
        break;
      case 'Dual Witness':
        badgeBg = isDark ? AppColors.darkEmergencyRedBg : const Color(0xFFFEE2E2);
        badgeText = isDark ? AppColors.darkEmergencyRed : const Color(0xFFB91C1C);
        break;
      default:
        badgeBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
        badgeText = isDark ? AppColors.darkTextMuted : const Color(0xFF475569);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetailsDialog(med),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  med.isControlled ? Icons.lock_outline_rounded : Icons.medication_rounded,
                  color: primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(med.name, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: textColor)),
                        const SizedBox(width: 4),
                        Text(med.form, style: TextStyle(fontSize: 10.5, color: mutedColor)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                          child: Text(tr(med.statusBadge), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeText)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${med.drawer}  •  ${med.unitsAvailable} ${tr("units available")}', style: TextStyle(fontSize: 10.5, color: mutedColor)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onActionTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  tr(med.actionType),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: primaryGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
