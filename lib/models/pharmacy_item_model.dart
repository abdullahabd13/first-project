// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 31: DispenserMedication.copyWith() -> Returns updated clone of dispensary medication.
// - Line 85: PneumaticPodOrder.copyWith() -> Returns updated clone of pneumatic tube pod delivery order.
// - Line 133: PendingDoctorOrder.copyWith() -> Returns updated clone of physician prescription order.
// ============================================================================

class DispenserMedication {
  final String id;
  final String name;
  final String form;
  final String drawer;
  final int unitsAvailable;
  final String statusBadge;
  final String actionType;
  final bool isControlled;
  final bool isVended;

  const DispenserMedication({
    required this.id,
    required this.name,
    required this.form,
    required this.drawer,
    required this.unitsAvailable,
    required this.statusBadge,
    required this.actionType,
    this.isControlled = false,
    this.isVended = false,
  });

  DispenserMedication copyWith({
    String? id,
    String? name,
    String? form,
    String? drawer,
    int? unitsAvailable,
    String? statusBadge,
    String? actionType,
    bool? isControlled,
    bool? isVended,
  }) {
    return DispenserMedication(
      id: id ?? this.id,
      name: name ?? this.name,
      form: form ?? this.form,
      drawer: drawer ?? this.drawer,
      unitsAvailable: unitsAvailable ?? this.unitsAvailable,
      statusBadge: statusBadge ?? this.statusBadge,
      actionType: actionType ?? this.actionType,
      isControlled: isControlled ?? this.isControlled,
      isVended: isVended ?? this.isVended,
    );
  }
}

enum PodStatus {
  inTransit,
  receivedAtStation,
  deliveredToPatient,
}

class PneumaticPodOrder {
  final String id;
  final String podNumber;
  final String medicationName;
  final String patientName;
  final String bedCode;
  final String protocol;
  final String stationLocation;
  final String etaText;
  final PodStatus status;

  const PneumaticPodOrder({
    required this.id,
    required this.podNumber,
    required this.medicationName,
    required this.patientName,
    required this.bedCode,
    required this.protocol,
    required this.stationLocation,
    required this.etaText,
    required this.status,
  });

  PneumaticPodOrder copyWith({
    String? id,
    String? podNumber,
    String? medicationName,
    String? patientName,
    String? bedCode,
    String? protocol,
    String? stationLocation,
    String? etaText,
    PodStatus? status,
  }) {
    return PneumaticPodOrder(
      id: id ?? this.id,
      podNumber: podNumber ?? this.podNumber,
      medicationName: medicationName ?? this.medicationName,
      patientName: patientName ?? this.patientName,
      bedCode: bedCode ?? this.bedCode,
      protocol: protocol ?? this.protocol,
      stationLocation: stationLocation ?? this.stationLocation,
      etaText: etaText ?? this.etaText,
      status: status ?? this.status,
    );
  }
}

class PendingDoctorOrder {
  final String id;
  final String patientName;
  final String bedCode;
  final String regimenName;
  final String orderingDoctor;
  final String timeAgo;
  final String pharmacistReviewStatus;
  final bool isCleared;
  final bool isBroughtToPatient;

  const PendingDoctorOrder({
    required this.id,
    required this.patientName,
    required this.bedCode,
    required this.regimenName,
    required this.orderingDoctor,
    required this.timeAgo,
    this.pharmacistReviewStatus = 'Central Pharmacist Dosing Review',
    this.isCleared = true,
    this.isBroughtToPatient = false,
  });

  PendingDoctorOrder copyWith({
    String? id,
    String? patientName,
    String? bedCode,
    String? regimenName,
    String? orderingDoctor,
    String? timeAgo,
    String? pharmacistReviewStatus,
    bool? isCleared,
    bool? isBroughtToPatient,
  }) {
    return PendingDoctorOrder(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      bedCode: bedCode ?? this.bedCode,
      regimenName: regimenName ?? this.regimenName,
      orderingDoctor: orderingDoctor ?? this.orderingDoctor,
      timeAgo: timeAgo ?? this.timeAgo,
      pharmacistReviewStatus: pharmacistReviewStatus ?? this.pharmacistReviewStatus,
      isCleared: isCleared ?? this.isCleared,
      isBroughtToPatient: isBroughtToPatient ?? this.isBroughtToPatient,
    );
  }
}
