// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 38: _DoctorPatientEncounterViewState._showClinicalAssessmentDialog() -> Opens edit dialog for clinical assessment.
// - Line 106: _DoctorPatientEncounterViewState._showChangeNurseDialog() -> Opens selection dialog to change assigned nurse.
// - Line 188: _DoctorPatientEncounterViewState._showDischargeNoteDialog() -> Opens discharge note dialog.
// - Line 340: _DoctorPatientEncounterViewState._showPrescriptionDialog() -> Opens dialog for creating/editing prescriptions.
// - Line 477: _DoctorPatientEncounterViewState._confirmAndAdvanceNextPatient() -> Confirms orders, transmits to pharmacy, advances to next patient.
// - Line 507: _DoctorPatientEncounterViewState._showPatientDetailDrawer() -> Opens slide-over drawer / modal inspector for patient details, clinical assessment, and discharge notes.
// - Line 648: _DoctorPatientEncounterViewState.build() -> Builds the responsive healthcare encounter layout with horizontal patient & nurse carousels and detailed inspector panel.
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/translate/localizations/app_localizations.dart';
import '../../models/prescription_model.dart';
import '../../services/app_settings_service.dart';
import '../../services/auth_service.dart';
import '../../services/pharmacy_service.dart';
import '../../services/prescription_service.dart';
import '../../themes/app_colors.dart';

class DoctorPatientEncounterView extends StatefulWidget {
  const DoctorPatientEncounterView({super.key});

  @override
  State<DoctorPatientEncounterView> createState() =>
      _DoctorPatientEncounterViewState();
}

class _DoctorPatientEncounterViewState
    extends State<DoctorPatientEncounterView> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All (8)',
    'In Consultation (1)',
    'Upcoming (5)',
    'Completed (2)',
  ];

  int _currentPatientIndex = 0;
  bool _isInspectorExpanded = true;

  final List<Map<String, String>> _patientQueue = [
    {
      'name': 'Ahmed Tariq',
      'demographic': '45y • M',
      'location': 'Room 304 • Bed A',
      'time': '09:30 AM',
      'tag': 'Bedside Round',
      'bp': '162/98',
      'hr': '104',
      'spo2': '98%',
    },
    {
      'name': 'Mariam Al-Saadi',
      'demographic': '32y • F',
      'location': 'Room 306 • Bed B',
      'time': '10:15 AM',
      'tag': 'Post-op review',
      'bp': '124/82',
      'hr': '76',
      'spo2': '99%',
    },
    {
      'name': 'Hussein K.',
      'demographic': '58y • M',
      'location': 'Room 304 • Bed B',
      'time': '11:00 AM',
      'tag': 'Diabetic Check',
      'bp': '138/88',
      'hr': '82',
      'spo2': '97%',
    },
    {
      'name': 'Zainab Omran',
      'demographic': '29y • F',
      'location': 'Room 301 • Bed A',
      'time': '11:45 AM',
      'tag': 'Observation',
      'bp': '118/76',
      'hr': '72',
      'spo2': '100%',
    },
  ];

  String _assignedNurseName = 'Nurse Fatima Ali, RN';
  String _assignedNurseExt = 'Ext. 214';

  // Encounter & Telehealth Toggle State
  bool _isTelehealthMode = false;

  // SOAP Note Form Controllers & State
  final TextEditingController _soapSubjectiveController = TextEditingController(
    text: 'Patient reports persistent occipital throbbing headache and blurred vision since 06:00. Denies chest pain or shortness of breath.',
  );
  final TextEditingController _soapObjectiveController = TextEditingController(
    text: 'Vitals: BP 162/98 mmHg, HR 104 bpm, SpO2 98% room air, Temp 37.2°C. JVP normal, S1/S2 heard, no murmurs, chest clear bilaterally.',
  );
  final TextEditingController _soapAssessmentController = TextEditingController(
    text: 'Essential HTN Stage 2 with acute pressure elevation without evident target-organ damage.',
  );
  final TextEditingController _soapPlanController = TextEditingController(
    text: '1. Administer IV labetalol bolus.\n2. Continuous BP monitoring q15min.\n3. Titrate oral Amlodipine to 10mg daily.\n4. Stat Renal Panel, Troponin T, and ECG.',
  );

  // Quick Diagnosis & Symptom Chips
  final List<String> _quickDiagnosticChips = [
    'Acute BP Spike',
    'Rule out TIA',
    'Titrate ACEi/CCB',
    'Check Renal Panel',
    'Cardiac Troponin Stat',
    'ECG 12-Lead Required',
  ];

  // Diagnostic Labs & Imaging State
  final List<Map<String, dynamic>> _diagnosticLabResults = [
    {
      'test': 'Serum Creatinine',
      'value': '1.4 mg/dL',
      'ref': '0.7 - 1.2 mg/dL',
      'status': 'High',
      'isAbnormal': true,
      'category': 'Renal',
    },
    {
      'test': 'Serum Potassium (K+)',
      'value': '4.1 mEq/L',
      'ref': '3.5 - 5.0 mEq/L',
      'status': 'Normal',
      'isAbnormal': false,
      'category': 'Electrolytes',
    },
    {
      'test': 'Cardiac Troponin T',
      'value': '<0.01 ng/mL',
      'ref': '<0.04 ng/mL',
      'status': 'Negative',
      'isAbnormal': false,
      'category': 'Cardiac',
    },
    {
      'test': '12-Lead ECG',
      'value': 'Sinus Tachycardia (104)',
      'ref': 'No ST/T elevation',
      'status': 'Review',
      'isAbnormal': true,
      'category': 'Cardiology',
    },
  ];

  // Clinical History Timeline
  final List<Map<String, String>> _clinicalHistoryTimeline = [
    {
      'date': 'Yesterday, 22:30',
      'title': 'ER Acute Admission',
      'detail': 'Admitted with BP 190/110, initiated on IV Labetalol 20mg.',
      'type': 'Emergency',
    },
    {
      'date': '12 Sep 2026',
      'title': 'Cardiology Follow-up',
      'detail':
          'Prescribed Amlodipine 5mg PO daily. Advised lifestyle changes.',
      'type': 'Outpatient',
    },
    {
      'date': '04 Jun 2025',
      'title': 'Laparoscopic Cholecystectomy',
      'detail': 'Elective surgery at Baghdad Medical City Complex. Uncomplicated recovery.',
      'type': 'Surgical',
    },
    {
      'date': 'Chronic Condition',
      'title': 'Essential Hypertension (Stage 2)',
      'detail': 'Diagnosed 4 years ago. Moderate medication compliance.',
      'type': 'Chronic',
    },
  ];

  // Active Allergies & Clinical Warnings
  final List<String> _patientAllergies = [
    'Penicillin (Anaphylaxis)',
    'Sulfa Drugs',
  ];
  final bool _showDrugInteractionWarning = true;

  final List<Map<String, String>> _availableNurses = [
    {
      'name': 'Nurse Fatima Ali, RN',
      'ext': 'Ext. 214',
      'status': 'Assigned Ward Nurse',
    },
    {
      'name': 'Nurse Sarah Kareem, BSN',
      'ext': 'Ext. 218',
      'status': 'Floor Lead',
    },
    {
      'name': 'Nurse Noor Al-Hassan, RN',
      'ext': 'Ext. 220',
      'status': 'Available',
    },
    {
      'name': 'Nurse Zainab Omran, RN',
      'ext': 'Ext. 225',
      'status': 'ICU Float',
    },
  ];

  String _clinicalAssessment =
      'Hypertensive Crisis / Stage 2 — Responsive to initial IV labetalol infusion. Baseline symptoms resolving, headache dissipated, no acute target-organ damage observed.';

  String _dischargeDiagnosis =
      'Hypertensive Urgency — Resolved. Essential Hypertension Stage 2.';
  String _dischargeCondition = 'Stable, Afebrile, Normotensive on Oral Regimen';
  String _dischargeInstructions =
      '1. Continue Amlodipine 5mg PO daily at 08:00.\n2. Low sodium diet (<2g/day) & daily BP logging.\n3. Return to Cardiology Clinic in 10 days for follow-up.\n4. Seek ER immediately if severe headache or chest tightness recurs.';
  String _dischargeDestination = 'Home with Outpatient Follow-up';
  bool _isDischargeFinalized = false;

  void _showClinicalAssessmentDialog() {
    final controller = TextEditingController(text: tr(_clinicalAssessment));
    final isDark = AppSettingsService().isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.psychology_alt_outlined, color: Color(0xFF1E513B)),
            const SizedBox(width: 8),
            Text(
              tr('Edit Clinical Assessment'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr("Update clinical findings and diagnostic plan for")} ${tr(_patientQueue[_currentPatientIndex]['name']!)}:',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 4,
              style: TextStyle(fontSize: 13, color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? AppColors.fieldBackgroundDark
                    : const Color(0xFFF1F5F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              tr('Cancel'),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final assessment = controller.text.trim();
              setState(() {
                if (assessment != tr(_clinicalAssessment)) {
                  _clinicalAssessment = assessment;
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Clinical Assessment updated.')),
                  backgroundColor: const Color(0xFF1E513B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E513B),
              foregroundColor: Colors.white,
            ),
            child: Text(tr('Save Assessment')),
          ),
        ],
      ),
    );
  }

  void _showChangeNurseDialog() {
    final isDark = AppSettingsService().isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.people_alt_rounded, color: Color(0xFF1E513B)),
            const SizedBox(width: 8),
            Text(
              tr('Change Nurse'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _availableNurses.map((nurse) {
            final isSelected = nurse['name'] == _assignedNurseName;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                          ? const Color(0xFF174230)
                          : const Color(0xFFE2F0EC))
                    : (isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E513B)
                      : (isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFE2E8F0)),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF1E513B),
                  child: Text(
                    nurse['name']!.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  tr(nurse['name']!),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  '${tr(nurse['status']!)} • ${nurse['ext']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF1E513B),
                        size: 20,
                      )
                    : OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _assignedNurseName = nurse['name']!;
                            _assignedNurseExt = nurse['ext']!;
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${tr('Nurse assigned')}: $_assignedNurseName ($_assignedNurseExt)',
                              ),
                              backgroundColor: const Color(0xFF1E513B),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          side: const BorderSide(color: Color(0xFF1E513B)),
                        ),
                        child: Text(
                          tr('Assign'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1E513B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              tr('Close'),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDischargeNoteDialog() {
    final diagnosisController = TextEditingController(
      text: tr(_dischargeDiagnosis),
    );
    final conditionController = TextEditingController(
      text: tr(_dischargeCondition),
    );
    final instructionsController = TextEditingController(
      text: tr(_dischargeInstructions),
    );
    String selectedDest = _dischargeDestination;
    final isDark = AppSettingsService().isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF174230)
                      : const Color(0xFFE2F0EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Color(0xFF1E513B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('Discharge Note & Disposition'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${tr('Patient')}: ${_patientQueue[_currentPatientIndex]['name']} (${_patientQueue[_currentPatientIndex]['location']})',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
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
                Text(
                  tr('Discharge Primary Diagnosis'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: diagnosisController,
                  style: TextStyle(fontSize: 12, color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.fieldBackgroundDark
                        : const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('Condition on Discharge'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: conditionController,
                  style: TextStyle(fontSize: 12, color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.fieldBackgroundDark
                        : const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('Disposition / Destination'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  initialValue: selectedDest,
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  items: [
                    DropdownMenuItem(
                      value: 'Home with Outpatient Follow-up',
                      child: Text(
                        tr('Home with Outpatient Follow-up'),
                        style: TextStyle(fontSize: 11.5, color: textColor),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Transfer to Step-Down Ward',
                      child: Text(
                        tr('Transfer to Step-Down Ward'),
                        style: TextStyle(fontSize: 11.5, color: textColor),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Rehabilitation Center',
                      child: Text(
                        tr('Rehabilitation Center'),
                        style: TextStyle(fontSize: 11.5, color: textColor),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedDest = val);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.fieldBackgroundDark
                        : const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('Post-Discharge Instructions & Follow-up'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: instructionsController,
                  maxLines: 4,
                  style: TextStyle(fontSize: 12, color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.fieldBackgroundDark
                        : const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                tr('Cancel'),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  final diagnosis = diagnosisController.text.trim();
                  final condition = conditionController.text.trim();
                  final instructions = instructionsController.text.trim();
                  if (diagnosis != tr(_dischargeDiagnosis)) {
                    _dischargeDiagnosis = diagnosis;
                  }
                  if (condition != tr(_dischargeCondition)) {
                    _dischargeCondition = condition;
                  }
                  if (instructions != tr(_dischargeInstructions)) {
                    _dischargeInstructions = instructions;
                  }
                  _dischargeDestination = selectedDest;
                  _isDischargeFinalized = true;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        'Discharge summary note signed & transmitted to Ward Team.',
                      ),
                    ),
                    backgroundColor: const Color(0xFF1E513B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: Text(tr('Sign & Finalize Note')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E513B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrescriptionDialog([PrescriptionItem? existing]) {
    final nameController = TextEditingController(
      text: existing?.medicationName ?? '',
    );
    final dosageController = TextEditingController(
      text: existing?.dosageAndRoute ?? 'Oral • Once daily',
    );
    String selectedStatus = existing?.status ?? 'New Dose';
    final isDark = AppSettingsService().isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.medication_rounded, color: Color(0xFF1E513B)),
              const SizedBox(width: 8),
              Text(
                existing == null
                    ? tr('New Doctor Order')
                    : tr('Edit Prescription'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: textColor,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Medication & Strength'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: 12, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g. Amlodipine 5mg',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.fieldBackgroundDark
                        : const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('Dosage, Route & Frequency'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: dosageController,
                  style: TextStyle(fontSize: 12, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g. Oral • Once daily at 08:00',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.fieldBackgroundDark
                        : const Color(0xFFF1F5F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('Order Verification Status'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['Verified', 'New Dose', 'Active Order'].map((st) {
                    final isSel = selectedStatus == st;
                    return ChoiceChip(
                      label: Text(
                        st,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSel ? Colors.white : textColor,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: const Color(0xFF1E513B),
                      onSelected: (_) =>
                          setDialogState(() => selectedStatus = st),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                tr('Cancel'),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                if (existing == null) {
                  PrescriptionService().addPrescription(
                    PrescriptionItem(
                      id: 'rx-${DateTime.now().millisecondsSinceEpoch}',
                      medicationName: nameController.text.trim(),
                      dosageAndRoute: dosageController.text.trim(),
                      status: selectedStatus,
                      prescribedBy:
                          AuthService().currentUser?.name ??
                          'Dr. Zaid Al-Husseini',
                      prescribedAt: DateTime.now(),
                    ),
                  );
                } else {
                  PrescriptionService().updatePrescription(
                    existing.id,
                    nameController.text.trim(),
                    dosageController.text.trim(),
                    selectedStatus,
                  );
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('Prescription updated successfully.')),
                    backgroundColor: const Color(0xFF1E513B),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E513B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(tr('Save Order')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndAdvanceNextPatient() {
    PrescriptionService().confirmAndSaveOrders();
    final currentPatient = _patientQueue[_currentPatientIndex];

    // Transmit order to nurse portal / pharmacy dispensary
    PharmacyService().addDoctorRxOrder(
      patientName: currentPatient['name']!,
      bedCode: currentPatient['location']!,
      regimenName:
          'Regimen updated by ${AuthService().currentUser?.name ?? "Dr. Zaid"}',
      doctorName: AuthService().currentUser?.name ?? 'Dr. Zaid Al-Husseini',
    );

    final nextIndex = (_currentPatientIndex + 1) % _patientQueue.length;

    setState(() {
      _currentPatientIndex = nextIndex;
      _isDischargeFinalized = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tr('Orders confirmed & transferred to Nurse Portal. Switched to next patient:')} ${_patientQueue[nextIndex]['name']}',
        ),
        backgroundColor: const Color(0xFF1E513B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Interactive detailed information panel (Slide-over drawer / modal inspector)
  void _showPatientDetailDrawer(Map<String, String> patient) {
    final isDark = AppSettingsService().isDarkMode;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final isCurrent =
        _patientQueue[_currentPatientIndex]['name'] == patient['name'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10n = AppLocalizations.of(context);
            final prescriptions = PrescriptionService().prescriptions;

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Slide-over Drawer Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header with Patient Profile & Close Action
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF1E513B),
                          child: Text(
                            patient['name']!
                                .split(' ')
                                .map((n) => n.isNotEmpty ? n[0] : '')
                                .take(2)
                                .join(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${patient['name']} — Dossier',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF174230)
                                          : const Color(0xFFE2F0EC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tr(patient['tag']!),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : const Color(0xFF1E513B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${patient['demographic']} • ${patient['location']} • ${patient['time']}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close_rounded, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE2E8F0),
                  ),

                  // Scrollable Body containing Detailed Sections
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      children: [
                        // Vitals Metric Tiles
                        Row(
                          children: [
                            Expanded(
                              child: _vitalMetricTile(
                                label: l10n?.bloodPress ?? 'BLOOD PRESS',
                                value: patient['bp']!,
                                subtext: 'Elevated',
                                subtextColor: Colors.red,
                                bgColor: isDark
                                    ? const Color(0xFF450A0A)
                                    : const Color(0xFFFFF1F2),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _vitalMetricTile(
                                label: l10n?.heartRate ?? 'HEART RATE',
                                value: patient['hr']!,
                                unit: 'bpm',
                                subtext: 'Regular',
                                subtextColor: isDark
                                    ? AppColors.primaryLight
                                    : const Color(0xFF027A48),
                                bgColor: isDark
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFFF0FDF4),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _vitalMetricTile(
                                label: l10n?.spo2 ?? 'SPO2',
                                value: patient['spo2']!,
                                subtext: 'Normal',
                                subtextColor: isDark
                                    ? AppColors.primaryLight
                                    : const Color(0xFF1E513B),
                                bgColor: isDark
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFFF0FDF4),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section: Clinical Assessment
                        _buildClinicalAssessmentSection(
                          isDark,
                          cardBg,
                          cardBorder,
                          textColor,
                          mutedColor,
                          l10n,
                          onEdit: () {
                            Navigator.pop(ctx);
                            _showClinicalAssessmentDialog();
                          },
                        ),
                        const SizedBox(height: 14),

                        // Section: Discharge Note
                        _buildDischargeNoteSection(
                          isDark,
                          cardBg,
                          cardBorder,
                          textColor,
                          mutedColor,
                          l10n,
                          onEdit: () {
                            Navigator.pop(ctx);
                            _showDischargeNoteDialog();
                          },
                        ),
                        const SizedBox(height: 14),

                        // Section: Assigned Nurse
                        _buildAssignedNurseTile(
                          isDark,
                          textColor,
                          mutedColor,
                          onChange: () {
                            Navigator.pop(ctx);
                            _showChangeNurseDialog();
                          },
                        ),
                        const SizedBox(height: 14),

                        // Prescriptions Preview in Drawer
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n?.activeOrdersVerification ??
                                    'Active Orders for Verification',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              '${prescriptions.length} orders',
                              style: TextStyle(fontSize: 11, color: mutedColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...prescriptions.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _medicationTile(p, isDark),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick Switch Action
                        if (!isCurrent)
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final targetIndex = _patientQueue.indexWhere(
                                  (p) => p['name'] == patient['name'],
                                );
                                if (targetIndex != -1) {
                                  setState(
                                    () => _currentPatientIndex = targetIndex,
                                  );
                                }
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${tr('Switched active encounter to')} ${patient['name']}',
                                    ),
                                    backgroundColor: const Color(0xFF1E513B),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                '${tr('Set as Active Patient Encounter')} (${patient['location']})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E513B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Clinical Assessment Section reusable builder
  Widget _buildClinicalAssessmentSection(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color mutedColor,
    AppLocalizations? l10n, {
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF174230)
                      : const Color(0xFFE2F0EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_alt_outlined,
                  size: 18,
                  color: Color(0xFF1E513B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.clinicalAssessment ?? 'Clinical Assessment',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 17,
                  color: Color(0xFF1E513B),
                ),
                onPressed: onEdit ?? _showClinicalAssessmentDialog,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: tr('Edit Assessment'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.fieldBackgroundDark
                  : const Color(0xFFF1F5F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tr(_clinicalAssessment),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkText : const Color(0xFF334155),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Discharge Note Section reusable builder
  Widget _buildDischargeNoteSection(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color mutedColor,
    AppLocalizations? l10n, {
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDischargeFinalized
            ? (isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                  : const Color(0xFFF0FDF4))
            : (isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isDischargeFinalized
              ? const Color(0xFF86EFAC)
              : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E513B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 18,
                  color: Color(0xFF1E513B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.dischargeNote ?? 'Discharge Note & Disposition',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isDischargeFinalized
                      ? (isDark
                            ? const Color(0xFF14532D)
                            : const Color(0xFFD1FADF))
                      : (isDark
                            ? const Color(0xFF713F12)
                            : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isDischargeFinalized
                      ? (l10n?.signedAndFinalized ?? 'Signed & Finalized')
                      : (l10n?.draftPendingReview ?? 'Draft / Pending Review'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _isDischargeFinalized
                        ? (isDark
                              ? AppColors.primaryLight
                              : const Color(0xFF027A48))
                        : (isDark
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr('Diagnosis')}: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: mutedColor,
                ),
              ),
              Expanded(
                child: Text(
                  tr(_dischargeDiagnosis),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr('Condition')}: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: mutedColor,
                ),
              ),
              Expanded(
                child: Text(
                  tr(_dischargeCondition),
                  style: TextStyle(fontSize: 11, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr('Disposition')}: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: mutedColor,
                ),
              ),
              Expanded(
                child: Text(
                  tr(_dischargeDestination),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1E513B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${tr('Instructions')}:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.fieldBackgroundDark
                  : const Color(0xFFF1F5F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tr(_dischargeInstructions),
              style: TextStyle(fontSize: 11, color: textColor, height: 1.35),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit ?? _showDischargeNoteDialog,
              icon: Icon(
                _isDischargeFinalized
                    ? Icons.edit_note_rounded
                    : Icons.edit_document,
                size: 16,
                color: const Color(0xFF1E513B),
              ),
              label: Text(
                _isDischargeFinalized
                    ? (l10n?.editViewDischargeNote ??
                          'Edit / View Discharge Note')
                    : (l10n?.authorSignDischargeNote ??
                          'Author & Sign Discharge Note'),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E513B),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E513B)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Assigned Nurse Tile reusable builder
  Widget _buildAssignedNurseTile(
    bool isDark,
    Color textColor,
    Color mutedColor, {
    VoidCallback? onChange,
  }) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFF1E513B),
            child: Icon(Icons.person_pin, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _assignedNurseName,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  '${tr('Assigned Ward Nurse')} • $_assignedNurseExt',
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onChange ?? _showChangeNurseDialog,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              side: const BorderSide(color: Color(0xFF1E513B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n?.changeNurse ?? 'Change Nurse',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E513B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Quick Metrics Ribbon: Top-level KPIs for clinical shift
  Widget _buildQuickMetricsRibbon(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _metricKpiTile(
              label: tr('Total Patients Today'),
              value: '8',
              badge: '4 Wards',
              icon: Icons.personal_injury_outlined,
              iconColor: const Color(0xFF1E513B),
              isDark: isDark,
              textColor: textColor,
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _metricKpiTile(
              label: tr('Pending Lab Results'),
              value: '3',
              badge: 'STAT: 1',
              icon: Icons.biotech_outlined,
              iconColor: const Color(0xFFD97706),
              isDark: isDark,
              textColor: textColor,
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _metricKpiTile(
              label: tr('Unsigned SOAP Notes'),
              value: '2',
              badge: 'Review',
              icon: Icons.history_edu_outlined,
              iconColor: const Color(0xFF2563EB),
              isDark: isDark,
              textColor: textColor,
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _metricKpiTile(
              label: tr('High Acuity / Critical'),
              value: '1',
              badge: 'Priority',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFDC2626),
              isDark: isDark,
              textColor: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricKpiTile({
    required String label,
    required String value,
    required String badge,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Emergency clinical alert banner
  Widget _buildEmergencyAlertBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626)
                  .withValues(alpha: isDark ? 0.3 : 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.crisis_alert_rounded,
              size: 18,
              color: Color(0xFFDC2626),
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
                      tr('Emergency Clinical Alert'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tr('Critical'),
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Room 304 Bed A (Ahmed Tariq): BP 162/98 mmHg (Hypertensive Stage 2). Stat order verified.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF991B1B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modernized Persistent Patient Header with vitals, allergies & emergency tags
  Widget _buildModernPatientHeader(
    Map<String, String> activePatient,
    bool isDark,
    Color textColor,
    Color mutedColor,
    AppLocalizations? l10n,
  ) {
    final initials = activePatient['name']!
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .take(2)
        .join();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main identity row
        Row(
          children: [
            Tooltip(
              message: tr('Click avatar to view full patient dossier'),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _showPatientDetailDrawer(activePatient),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF1E513B),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E513B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.open_in_new_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${activePatient['name']} • ${activePatient['demographic']}',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activePatient['location']} • ${activePatient['time']}',
                    style: TextStyle(fontSize: 11.5, color: mutedColor),
                  ),
                ],
              ),
            ),
            // Triage priority indicator badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emergency_rounded,
                    size: 12,
                    color: Color(0xFFB91C1C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n?.inConsultation ?? 'In Consultation',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: tr('Open Full Slide-Over Dossier'),
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: Color(0xFF1E513B),
              ),
              onPressed: () => _showPatientDetailDrawer(activePatient),
            ),
            IconButton(
              tooltip: _isInspectorExpanded
                  ? tr('Collapse Inspector')
                  : tr('Expand Inspector'),
              icon: Icon(
                _isInspectorExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: mutedColor,
              ),
              onPressed: () =>
                  setState(() => _isInspectorExpanded = !_isInspectorExpanded),
            ),
          ],
        ),

        // Active Allergies Ribbon
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 15,
                color: Color(0xFFD97706),
              ),
              const SizedBox(width: 6),
              Text(
                '${tr('Active Allergies')}: ',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _patientAllergies.map((allergy) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626)
                            .withValues(alpha: isDark ? 0.35 : 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        allergy,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2. Clinical History Timeline Section
  Widget _buildClinicalHistoryTimeline(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 17,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr('Clinical History Timeline'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_clinicalHistoryTimeline.length} events',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _clinicalHistoryTimeline.map((item) {
              Color tagColor;
              switch (item['type']) {
                case 'Emergency':
                  tagColor = const Color(0xFFDC2626);
                  break;
                case 'Surgical':
                  tagColor = const Color(0xFF7C3AED);
                  break;
                case 'Chronic':
                  tagColor = const Color(0xFFD97706);
                  break;
                default:
                  tagColor = const Color(0xFF2563EB);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: tagColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 34,
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item['date']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['detail']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 3. Diagnostic & Lab Viewer with color-coded abnormal highlights
  Widget _buildDiagnosticLabViewer(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F766E).withValues(alpha: 0.3)
                      : const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.biotech_outlined,
                  size: 17,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr('Diagnostic & Lab Viewer'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                '${tr("Lab Tests")} (4)',
                style: TextStyle(
                  fontSize: 11,
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.1,
            ),
            itemCount: _diagnosticLabResults.length,
            itemBuilder: (context, index) {
              final lab = _diagnosticLabResults[index];
              final isAbnormal = lab['isAbnormal'] as bool;
              final Color badgeColor = isAbnormal
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF059669);

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isAbnormal
                        ? (isDark
                              ? const Color(0xFF7F1D1D)
                              : const Color(0xFFFCA5A5))
                        : (isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE2E8F0)),
                    width: isAbnormal ? 1.4 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lab['test'] as String,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(
                              alpha: isDark ? 0.3 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            lab['status'] as String,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lab['value'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: isAbnormal ? const Color(0xFFDC2626) : textColor,
                      ),
                    ),
                    Text(
                      'Ref: ${lab["ref"]}',
                      style: TextStyle(fontSize: 9, color: mutedColor),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 4. Consultation & SOAP Notes Workflow with Telehealth toggle & Quick-Insert Chips
  Widget _buildSoapNoteWorkflow(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Encounter Mode Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF14532D)
                      : const Color(0xFFD1FADF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 17,
                  color: Color(0xFF1E513B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('SOAP Clinical Notes'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${tr("Encounter Mode")}: ${_isTelehealthMode ? tr("Telehealth Video") : tr("In-Person Bedside")}',
                      style: TextStyle(fontSize: 10, color: mutedColor),
                    ),
                  ],
                ),
              ),
              // Encounter Mode Toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.fieldBackgroundDark
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isTelehealthMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: !_isTelehealthMode
                              ? const Color(0xFF1E513B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bed_rounded,
                              size: 12,
                              color: !_isTelehealthMode
                                  ? Colors.white
                                  : mutedColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tr('In-Person Bedside'),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: !_isTelehealthMode
                                    ? Colors.white
                                    : mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isTelehealthMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isTelehealthMode
                              ? const Color(0xFF0284C7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_rounded,
                              size: 12,
                              color: _isTelehealthMode
                                  ? Colors.white
                                  : mutedColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tr('Telehealth Video'),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: _isTelehealthMode
                                    ? Colors.white
                                    : mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick-Insert Diagnostic Chips
          Text(
            tr('Quick Insert Diagnostic Chips'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickDiagnosticChips.map((chip) {
              return ActionChip(
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                side: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder
                      : const Color(0xFFCBD5E1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                label: Text(
                  chip,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.primaryLight
                        : const Color(0xFF1E513B),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _soapAssessmentController.text =
                        '${_soapAssessmentController.text} • $chip';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inserted "$chip" into Assessment note.'),
                      backgroundColor: const Color(0xFF1E513B),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(milliseconds: 1200),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Structured SOAP form fields
          _soapInputField(
            'S',
            tr('Subjective'),
            _soapSubjectiveController,
            isDark,
            textColor,
            mutedColor,
          ),
          const SizedBox(height: 8),
          _soapInputField(
            'O',
            tr('Objective'),
            _soapObjectiveController,
            isDark,
            textColor,
            mutedColor,
          ),
          const SizedBox(height: 8),
          _soapInputField(
            'A',
            tr('Assessment'),
            _soapAssessmentController,
            isDark,
            textColor,
            mutedColor,
          ),
          const SizedBox(height: 8),
          _soapInputField(
            'P',
            tr('Plan'),
            _soapPlanController,
            isDark,
            textColor,
            mutedColor,
          ),
        ],
      ),
    );
  }

  Widget _soapInputField(
    String letter,
    String title,
    TextEditingController controller,
    bool isDark,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 9,
                backgroundColor: const Color(0xFF1E513B),
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: 2,
            style: TextStyle(fontSize: 11, color: textColor),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Orders, E-Prescription & Drug Safety Warnings
  Widget _buildOrderPadAndDrugWarnings(
    bool isDark,
    Color textColor,
    Color mutedColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drug-Drug Interaction and Allergy Conflict Warning Banner
        if (_showDrugInteractionWarning)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFB45309)
                    : const Color(0xFFFBBF24),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Drug-Drug Interaction Warning'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Caution: Concomitant Calcium Channel Blocker (Amlodipine) + Beta-blocker infusion may induce bradycardia. Continuous ECG telemetry active.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Quick Order Pad Action Buttons (Labs, Radiology, E-Prescriptions)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr(
                          'Order Lab Test: CBC, Electrolytes & Cardiac Enzymes requested.',
                        ),
                      ),
                      backgroundColor: const Color(0xFF1E513B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.science_outlined,
                  size: 14,
                  color: Color(0xFF1E513B),
                ),
                label: Text(
                  tr('Order Lab Test'),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E513B),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: Color(0xFF1E513B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr('Order Radiology: Chest X-Ray & Echo requested.'),
                      ),
                      backgroundColor: const Color(0xFF0F766E),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.document_scanner_outlined,
                  size: 14,
                  color: Color(0xFF0F766E),
                ),
                label: Text(
                  tr('Order Radiology'),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F766E),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: Color(0xFF0F766E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = AuthService().currentUser;
    final doctorName = doctor?.name ?? 'Dr. Zaid Al-Husseini';
    final l10n = AppLocalizations.of(context);
    final isDark = AppSettingsService().isDarkMode;

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    final activePatient = _patientQueue[_currentPatientIndex];

    return ListenableBuilder(
      listenable: PrescriptionService(),
      builder: (context, _) {
        final prescriptionService = PrescriptionService();
        final prescriptions = prescriptionService.prescriptions;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Top Doctor Info Bar
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF14532D)
                            : const Color(0xFFD1FADF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n?.attendingPhysician ?? 'Attending Physician',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.primaryLight
                              : const Color(0xFF027A48),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('Notifications — active shift online.'),
                        ),
                        backgroundColor: const Color(0xFF1E513B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : const Color(0xFF334155),
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1E513B),
                  child: Text(
                    doctorName
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Top Quick Metrics Ribbon (Total Patients, Pending Labs, Unsigned SOAP, High Acuity)
            _buildQuickMetricsRibbon(
              isDark,
              cardBg,
              cardBorder,
              textColor,
              mutedColor,
            ),
            const SizedBox(height: 12),

            // Emergency Clinical Alert Banner
            _buildEmergencyAlertBanner(isDark),
            const SizedBox(height: 14),

            // Shift Context Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF1E513B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr('Cardiology Inpatients Shift'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF174230)
                              : const Color(0xFFE2F0EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_patientQueue.length} ${tr('Patients Queue')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.primaryLight
                                : const Color(0xFF1E513B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: mutedColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tr('Ward 3B • Morning Shift (08:00 - 14:00)'),
                          style: TextStyle(fontSize: 11, color: mutedColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tr('Active Patient')} ${_currentPatientIndex + 1}/${_patientQueue.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E513B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (idx) {
                  final active = _selectedFilterIndex == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterIndex = idx),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF1E513B) : cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? const Color(0xFF1E513B) : cardBorder,
                        ),
                      ),
                      child: Text(
                        _filters[idx],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextMuted
                                    : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ================================================================
            // SECTION 1: HORIZONTAL SCROLLABLE PATIENT PROFILES TRACK (CAROUSEL)
            // ================================================================
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E513B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 16,
                    color: Color(0xFF1E513B),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l10n?.patients ?? "Patients"} Queue & Profiles',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF174230)
                        : const Color(0xFFE2F0EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_patientQueue.length} ${tr('Inpatients')}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.primaryLight
                          : const Color(0xFF1E513B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 195,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _patientQueue.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = _patientQueue[index];
                  final isSelected = index == _currentPatientIndex;
                  return _PatientTrackCard(
                    patient: p,
                    index: index,
                    isSelected: isSelected,
                    isDark: isDark,
                    onCardTap: () {
                      setState(() {
                        _currentPatientIndex = index;
                        _isInspectorExpanded = true;
                      });
                    },
                    onAvatarTap: () {
                      setState(() => _currentPatientIndex = index);
                      _showPatientDetailDrawer(p);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // ================================================================
            // SECTION 2: HORIZONTAL SCROLLABLE NURSE PROFILES TRACK (CAROUSEL)
            // ================================================================
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    size: 16,
                    color: Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr('Care Team & Floor Nurses'),
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF134E48)
                        : const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_availableNurses.length} ${tr('On Duty')}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF5EEAD4)
                          : const Color(0xFF0F766E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _availableNurses.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final nurse = _availableNurses[index];
                  final isAssigned = nurse['name'] == _assignedNurseName;
                  return _NurseTrackCard(
                    nurse: nurse,
                    isAssigned: isAssigned,
                    isDark: isDark,
                    onAssignTap: () {
                      setState(() {
                        _assignedNurseName = nurse['name']!;
                        _assignedNurseExt = nurse['ext']!;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${tr('Nurse assigned')}: $_assignedNurseName ($_assignedNurseExt)',
                          ),
                          backgroundColor: const Color(0xFF1E513B),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onContactTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr('Calling {name} ({ext})...')
                                .replaceFirst('{name}', nurse['name']!)
                                .replaceFirst('{ext}', nurse['ext']!),
                          ),
                          backgroundColor: const Color(0xFF0F766E),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // ================================================================
            // SECTION 3: PATIENT DETAILED INFORMATION PANEL (INSPECTOR VIEW)
            // ================================================================
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n?.activePatientEncounter ?? 'Active Patient Encounter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF174230)
                        : const Color(0xFFE2F0EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tr(activePatient['tag']!),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.primaryLight
                          : const Color(0xFF1E513B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Patient Modernized Header with Allergies & Emergency tags
                  _buildModernPatientHeader(
                    activePatient,
                    isDark,
                    textColor,
                    mutedColor,
                    l10n,
                  ),

                  if (_isInspectorExpanded) ...[
                    const SizedBox(height: 14),

                    // Vitals Metric Tiles
                    Row(
                      children: [
                        Expanded(
                          child: _vitalMetricTile(
                            label: l10n?.bloodPress ?? 'BLOOD PRESS',
                            value: activePatient['bp']!,
                            subtext: 'Elevated',
                            subtextColor: Colors.red,
                            bgColor: isDark
                                ? const Color(0xFF450A0A)
                                : const Color(0xFFFFF1F2),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _vitalMetricTile(
                            label: l10n?.heartRate ?? 'HEART RATE',
                            value: activePatient['hr']!,
                            unit: 'bpm',
                            subtext: 'Regular',
                            subtextColor: isDark
                                ? AppColors.primaryLight
                                : const Color(0xFF027A48),
                            bgColor: isDark
                                ? const Color(0xFF064E3B)
                                : const Color(0xFFF0FDF4),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _vitalMetricTile(
                            label: l10n?.spo2 ?? 'SPO2',
                            value: activePatient['spo2']!,
                            subtext: 'Normal',
                            subtextColor: isDark
                                ? AppColors.primaryLight
                                : const Color(0xFF1E513B),
                            bgColor: isDark
                                ? const Color(0xFF064E3B)
                                : const Color(0xFFF0FDF4),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Detail View Section 1: Clinical History Timeline
                    _buildClinicalHistoryTimeline(
                      isDark,
                      cardBg,
                      cardBorder,
                      textColor,
                      mutedColor,
                    ),
                    const SizedBox(height: 14),

                    // Detail View Section 2: Diagnostic & Lab Viewer Grid
                    _buildDiagnosticLabViewer(
                      isDark,
                      cardBg,
                      cardBorder,
                      textColor,
                      mutedColor,
                    ),
                    const SizedBox(height: 14),

                    // Detail View Section 3: Consultation & SOAP Notes Workflow
                    _buildSoapNoteWorkflow(
                      isDark,
                      cardBg,
                      cardBorder,
                      textColor,
                      mutedColor,
                    ),
                    const SizedBox(height: 14),

                    // Detail View Section 4: Clinical Assessment (Original in-page widget)
                    _buildClinicalAssessmentSection(
                      isDark,
                      cardBg,
                      cardBorder,
                      textColor,
                      mutedColor,
                      l10n,
                    ),
                    const SizedBox(height: 12),

                    // Detail View Section 5: Discharge Note & Disposition
                    _buildDischargeNoteSection(
                      isDark,
                      cardBg,
                      cardBorder,
                      textColor,
                      mutedColor,
                      l10n,
                    ),
                    const SizedBox(height: 14),

                    // Detail View Section 6: Quick Order Pad & Drug Safety Warnings
                    _buildOrderPadAndDrugWarnings(
                      isDark,
                      textColor,
                      mutedColor,
                    ),
                    const SizedBox(height: 14),

                    // Detail View Section 7: Rx Orders for Verification
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n?.activeOrdersVerification ??
                                'Active Orders for Verification',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${prescriptions.length} pending',
                          style: TextStyle(fontSize: 11, color: mutedColor),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showPrescriptionDialog(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF174230)
                                  : const Color(0xFFE2F0EC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 13,
                                  color: Color(0xFF1E513B),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  l10n?.orderRx ?? 'Order Rx',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E513B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ...prescriptions.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () => _showPrescriptionDialog(p),
                          borderRadius: BorderRadius.circular(10),
                          child: _medicationTile(p, isDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Detail View Section 8: Assigned Nurse Card
                    _buildAssignedNurseTile(isDark, textColor, mutedColor),
                    const SizedBox(height: 16),

                    // Detail View Action: Confirm & Save Orders (Transfers order to Nurse Portal & Switches to Next Patient)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _confirmAndAdvanceNextPatient,
                        icon: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          '${l10n?.confirmSaveOrders ?? "Confirm & Save Orders"} (Transfer & Next)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E513B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  static Widget _vitalMetricTile({
    required String label,
    required String value,
    String? unit,
    required String subtext,
    required Color subtextColor,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : const Color(0xFF0F172A),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _medicationTile(PrescriptionItem item, bool isDark) {
    Color badgeBg;
    Color badgeText;
    switch (item.status) {
      case 'Verified':
        badgeBg = isDark ? const Color(0xFF14532D) : const Color(0xFFD1FADF);
        badgeText = isDark ? AppColors.primaryLight : const Color(0xFF027A48);
        break;
      case 'New Dose':
        badgeBg = isDark ? const Color(0xFF713F12) : const Color(0xFFFEF08A);
        badgeText = isDark ? const Color(0xFFFEF08A) : const Color(0xFF854D0E);
        break;
      case 'Active Order':
        badgeBg = isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF);
        badgeText = isDark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3);
        break;
      default:
        badgeBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
        badgeText = isDark ? AppColors.darkTextMuted : const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medication_rounded,
            size: 16,
            color: Color(0xFF1E513B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicationName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : Colors.black,
                  ),
                ),
                Text(
                  item.dosageAndRoute,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeText,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.edit_outlined,
            size: 14,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}

/// Horizontal Track Card for Patient Profiles with hover, focus, and selection states
class _PatientTrackCard extends StatefulWidget {
  final Map<String, String> patient;
  final int index;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onCardTap;
  final VoidCallback onAvatarTap;

  const _PatientTrackCard({
    required this.patient,
    required this.index,
    required this.isSelected,
    required this.isDark,
    required this.onCardTap,
    required this.onAvatarTap,
  });

  @override
  State<_PatientTrackCard> createState() => _PatientTrackCardState();
}

class _PatientTrackCardState extends State<_PatientTrackCard> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isSelected = widget.isSelected;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    final Color bgColor;
    if (isSelected) {
      bgColor = isDark ? const Color(0xFF132F23) : const Color(0xFFF0FDF4);
    } else if (_isHovered) {
      bgColor = isDark ? const Color(0xFF243347) : const Color(0xFFF8FAFC);
    } else {
      bgColor = isDark ? AppColors.darkCard : Colors.white;
    }

    final Border border;
    if (isSelected) {
      border = Border.all(color: const Color(0xFF1E513B), width: 2.0);
    } else if (_isFocused) {
      border = Border.all(color: const Color(0xFF0284C7), width: 2.0);
    } else if (_isHovered) {
      border = Border.all(
        color: const Color(0xFF1E513B).withValues(alpha: 0.6),
        width: 1.5,
      );
    } else {
      border = Border.all(
        color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
        width: 1.0,
      );
    }

    final initials = widget.patient['name']!
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .take(2)
        .join();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Focus(
        onFocusChange: (f) => setState(() => _isFocused = f),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 285,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: border,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF1E513B)
                          .withValues(alpha: isDark ? 0.35 : 0.12)
                    : (_isHovered
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.03)),
                blurRadius: _isHovered ? 12 : (isSelected ? 10 : 6),
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onCardTap,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Interactive Patient Logo/Avatar Card Trigger + Details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: tr(
                            'Click avatar to view full patient dossier',
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: widget.onAvatarTap,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E513B)
                                        : (isDark
                                              ? AppColors.fieldBackgroundDark
                                              : const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF86EFAC)
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? AppColors.darkText
                                                : const Color(0xFF334155)),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E513B),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline_rounded,
                                      size: 9,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patient['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.patient['demographic']} • ${widget.patient['location']}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: mutedColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Badges row: Tag & Time
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF174230)
                                    : const Color(0xFFE2F0EC),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tr(widget.patient['tag']!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.primaryLight
                                      : const Color(0xFF1E513B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: mutedColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.patient['time']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Vitals Quick Preview Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _miniVital(
                              'BP',
                              widget.patient['bp']!,
                              Colors.redAccent,
                              isDark,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 13,
                            color: isDark
                                ? AppColors.darkBorder
                                : const Color(0xFFCBD5E1),
                          ),
                          Expanded(
                            child: _miniVital(
                              'HR',
                              widget.patient['hr']!,
                              const Color(0xFF027A48),
                              isDark,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 13,
                            color: isDark
                                ? AppColors.darkBorder
                                : const Color(0xFFCBD5E1),
                          ),
                          Expanded(
                            child: _miniVital(
                              'O2',
                              widget.patient['spo2']!,
                              const Color(0xFF1E513B),
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Active Selection Indicator & Dossier Action
                    Row(
                      children: [
                        Expanded(
                          child: isSelected
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E513B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        tr('Active'),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E513B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  tr('Tap to view'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mutedColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: widget.onAvatarTap,
                          child: Text(
                            tr('Dossier ›'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF1E513B)
                                  : mutedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniVital(
    String label,
    String value,
    Color statusColor,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Horizontal Track Card for Nurse Staff Profiles with distinct visual styling and assignment actions
class _NurseTrackCard extends StatefulWidget {
  final Map<String, String> nurse;
  final bool isAssigned;
  final bool isDark;
  final VoidCallback onAssignTap;
  final VoidCallback onContactTap;

  const _NurseTrackCard({
    required this.nurse,
    required this.isAssigned,
    required this.isDark,
    required this.onAssignTap,
    required this.onContactTap,
  });

  @override
  State<_NurseTrackCard> createState() => _NurseTrackCardState();
}

class _NurseTrackCardState extends State<_NurseTrackCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isAssigned = widget.isAssigned;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    const Color tealPrimary = Color(0xFF0F766E);
    final Color cardBg;
    if (isAssigned) {
      cardBg = isDark ? const Color(0xFF0D332D) : const Color(0xFFF0FDFA);
    } else if (_isHovered) {
      cardBg = isDark ? const Color(0xFF1C2C38) : const Color(0xFFF8FAFC);
    } else {
      cardBg = isDark ? AppColors.darkCard : Colors.white;
    }

    final Border border;
    if (isAssigned) {
      border = Border.all(color: tealPrimary, width: 2.0);
    } else if (_isHovered) {
      border = Border.all(
        color: tealPrimary.withValues(alpha: 0.6),
        width: 1.5,
      );
    } else {
      border = Border.all(
        color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
        width: 1.0,
      );
    }

    final initials = widget.nurse['name']!
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .take(2)
        .join();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 260,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: [
            BoxShadow(
              color: isAssigned
                  ? tealPrimary.withValues(alpha: isDark ? 0.3 : 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 10 : 6,
              offset: Offset(0, _isHovered ? 3 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name & Contact Icon
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: tealPrimary,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nurse['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.nurse['ext']!,
                          style: TextStyle(fontSize: 10.5, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onContactTap,
                    icon: const Icon(
                      Icons.phone_in_talk_rounded,
                      size: 16,
                      color: tealPrimary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: tr('Contact Nurse'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF134E48)
                      : const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tr(widget.nurse['status']!),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF5EEAD4)
                        : const Color(0xFF0F766E),
                  ),
                ),
              ),
              const Spacer(),

              // Assignment Status or Action Button
              if (isAssigned)
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: tealPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tr('Assigned to Patient'),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: tealPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: OutlinedButton(
                    onPressed: widget.onAssignTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: const BorderSide(color: tealPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      tr('Assign to Active Patient'),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: tealPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
