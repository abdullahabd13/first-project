// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 49: PrescriptionService.canModifyPrescriptions -> Verifies that active user is an Attending Doctor.
// - Line 54: PrescriptionService.addPrescription() -> Adds new medication order; rejects if caller is not a doctor.
// - Line 63: PrescriptionService.updatePrescription() -> Modifies dosage, route, or status with doctor authority check.
// - Line 81: PrescriptionService.removePrescription() -> Discontinues and deletes prescription order.
// - Line 90: PrescriptionService.confirmAndSaveOrders() -> Finalizes active orders as Verified for pharmacy transmission.
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/prescription_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class PrescriptionService extends ChangeNotifier {
  static final PrescriptionService _instance = PrescriptionService._internal();
  factory PrescriptionService() => _instance;
  PrescriptionService._internal();

  final List<PrescriptionItem> _prescriptions = [
    PrescriptionItem(
      id: 'rx-01',
      medicationName: 'Amlodipine 5mg',
      dosageAndRoute: 'Oral • Once daily at 08:00',
      status: 'Verified',
      prescribedBy: 'Dr. Zaid Al-Husseini',
      prescribedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    PrescriptionItem(
      id: 'rx-02',
      medicationName: 'Lisinopril 10mg',
      dosageAndRoute: 'Oral • Morning titration',
      status: 'New Dose',
      prescribedBy: 'Dr. Zaid Al-Husseini',
      prescribedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PrescriptionItem(
      id: 'rx-03',
      medicationName: 'Labetalol 20mg IV',
      dosageAndRoute: 'IV Bolus • Q4H PRN for SBP > 160',
      status: 'Active Order',
      prescribedBy: 'Dr. Zaid Al-Husseini',
      prescribedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  List<PrescriptionItem> get prescriptions => List.unmodifiable(_prescriptions);

  bool get canModifyPrescriptions {
    final currentUser = AuthService().currentUser;
    return currentUser != null && currentUser.role == UserRole.doctor;
  }

  bool addPrescription(PrescriptionItem item) {
    if (!canModifyPrescriptions) {
      return false;
    }
    _prescriptions.add(item);
    notifyListeners();
    return true;
  }

  bool updatePrescription(String id, String newName, String newDosage, String newStatus) {
    if (!canModifyPrescriptions) {
      return false;
    }
    final index = _prescriptions.indexWhere((p) => p.id == id);
    if (index != -1) {
      _prescriptions[index] = _prescriptions[index].copyWith(
        medicationName: newName,
        dosageAndRoute: newDosage,
        status: newStatus,
        prescribedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool removePrescription(String id) {
    if (!canModifyPrescriptions) {
      return false;
    }
    _prescriptions.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }

  bool confirmAndSaveOrders() {
    if (!canModifyPrescriptions) {
      return false;
    }
    for (int i = 0; i < _prescriptions.length; i++) {
      _prescriptions[i] = _prescriptions[i].copyWith(status: 'Verified');
    }
    notifyListeners();
    return true;
  }
}
