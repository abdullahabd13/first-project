// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 59: WardBedPatient.copyWith() -> Returns updated clone of ward patient and bedside state.
// ============================================================================

class BedsideVitals {
  final String bloodPressure;
  final String pulse;
  final String spo2;
  final String temperature;
  final String bpTimeAgo;
  final String rhythm;
  final String o2Mode;
  final String tempMode;

  const BedsideVitals({
    required this.bloodPressure,
    required this.pulse,
    required this.spo2,
    required this.temperature,
    this.bpTimeAgo = '15m ago',
    this.rhythm = 'Regular rhythm',
    this.o2Mode = 'Room air',
    this.tempMode = 'Tympanic • Afebrile',
  });
}

class WardBedPatient {
  final String bedCode;
  final String patientName;
  final String demographics;
  final String condition;
  final String attendingPhysician;
  final String statusBadge;
  final BedsideVitals vitals;
  final String activeInfusion;
  final String pendingMedication;
  final bool isVitalsPending;
  final bool isMedDue;
  final bool isCompletedInRound;
  final String roomWing;

  const WardBedPatient({
    required this.bedCode,
    required this.patientName,
    required this.demographics,
    required this.condition,
    required this.attendingPhysician,
    required this.statusBadge,
    required this.vitals,
    this.activeInfusion = 'Saline 0.9% Normal • 60 mL/hr',
    this.pendingMedication = 'Lisinopril 10mg Oral • Due in 30m',
    this.isVitalsPending = false,
    this.isMedDue = true,
    this.isCompletedInRound = false,
    this.roomWing = 'Observation Wing',
  });

  WardBedPatient copyWith({
    String? bedCode,
    String? patientName,
    String? demographics,
    String? condition,
    String? attendingPhysician,
    String? statusBadge,
    BedsideVitals? vitals,
    String? activeInfusion,
    String? pendingMedication,
    bool? isVitalsPending,
    bool? isMedDue,
    bool? isCompletedInRound,
    String? roomWing,
  }) {
    return WardBedPatient(
      bedCode: bedCode ?? this.bedCode,
      patientName: patientName ?? this.patientName,
      demographics: demographics ?? this.demographics,
      condition: condition ?? this.condition,
      attendingPhysician: attendingPhysician ?? this.attendingPhysician,
      statusBadge: statusBadge ?? this.statusBadge,
      vitals: vitals ?? this.vitals,
      activeInfusion: activeInfusion ?? this.activeInfusion,
      pendingMedication: pendingMedication ?? this.pendingMedication,
      isVitalsPending: isVitalsPending ?? this.isVitalsPending,
      isMedDue: isMedDue ?? this.isMedDue,
      isCompletedInRound: isCompletedInRound ?? this.isCompletedInRound,
      roomWing: roomWing ?? this.roomWing,
    );
  }
}
