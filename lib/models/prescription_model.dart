// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 23: PrescriptionItem.copyWith() -> Returns updated clone of medication order.
// ============================================================================

class PrescriptionItem {
  final String id;
  final String medicationName;
  final String dosageAndRoute;
  final String status;
  final String prescribedBy;
  final DateTime prescribedAt;

  const PrescriptionItem({
    required this.id,
    required this.medicationName,
    required this.dosageAndRoute,
    required this.status,
    this.prescribedBy = 'Dr. Zaid Al-Husseini',
    required this.prescribedAt,
  });

  PrescriptionItem copyWith({
    String? id,
    String? medicationName,
    String? dosageAndRoute,
    String? status,
    String? prescribedBy,
    DateTime? prescribedAt,
  }) {
    return PrescriptionItem(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      dosageAndRoute: dosageAndRoute ?? this.dosageAndRoute,
      status: status ?? this.status,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      prescribedAt: prescribedAt ?? this.prescribedAt,
    );
  }
}
