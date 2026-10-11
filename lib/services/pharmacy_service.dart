// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 37: PharmacyService.vendMedication() -> Vends medication unit from satellite vault and updates inventory.
// - Line 52: PharmacyService.acknowledgePodReceipt() -> Acknowledges arrival of pneumatic tube canister at ward station.
// - Line 61: PharmacyService.deliverPodToPatient() -> Records bedside delivery and administration of STAT pneumatic order.
// - Line 72: PharmacyService.bringPrescriptionToPatient() -> Nurse retrieves doctor-approved prescription from pharmacy for bedside delivery.
// - Line 82: PharmacyService.requestRestock() -> Dispatches restock request to Central Pharmacy department.
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/pharmacy_item_model.dart';
import '../references/mock_hospital_data.dart';

class PharmacyService extends ChangeNotifier {
  static final PharmacyService _instance = PharmacyService._internal();
  factory PharmacyService() => _instance;
  PharmacyService._internal();

  int _dispensedAndVerified = 14;
  int _pendingCheck = 3;
  int _statUrgents = 1;
  final int _stockOuts = 0;

  int get dispensedAndVerified => _dispensedAndVerified;
  int get pendingCheck => _pendingCheck;
  int get statUrgents => _statUrgents;
  int get stockOuts => _stockOuts;

  final List<DispenserMedication> _dispenserItems = List.from(MockHospitalData.initialDispensaryVault);
  PneumaticPodOrder _activePod = MockHospitalData.activePodOrder;
  PendingDoctorOrder _doctorRxOrder = MockHospitalData.pendingDoctorRx;

  List<DispenserMedication> get dispenserItems => List.unmodifiable(_dispenserItems);
  PneumaticPodOrder get activePod => _activePod;
  PendingDoctorOrder get doctorRxOrder => _doctorRxOrder;

  bool vendMedication(String id, {int quantity = 1, String? patientBed}) {
    final idx = _dispenserItems.indexWhere((m) => m.id == id);
    if (idx != -1 && _dispenserItems[idx].unitsAvailable >= quantity) {
      final current = _dispenserItems[idx];
      _dispenserItems[idx] = current.copyWith(
        unitsAvailable: current.unitsAvailable - quantity,
        isVended: true,
      );
      _dispensedAndVerified += quantity;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool logUsage(String id, int quantity, {String? patientBed, String? reason}) {
    final idx = _dispenserItems.indexWhere((m) => m.id == id);
    if (idx != -1 && _dispenserItems[idx].unitsAvailable >= quantity) {
      final current = _dispenserItems[idx];
      _dispenserItems[idx] = current.copyWith(
        unitsAvailable: current.unitsAvailable - quantity,
      );
      _dispensedAndVerified += quantity;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool unlockVault(String id, {required String witnessName, required String pin}) {
    final idx = _dispenserItems.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final current = _dispenserItems[idx];
      if (current.unitsAvailable > 0) {
        _dispenserItems[idx] = current.copyWith(
          unitsAvailable: current.unitsAvailable - 1,
          isVended: true,
        );
        _dispensedAndVerified++;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void acknowledgePodReceipt() {
    _activePod = _activePod.copyWith(
      status: PodStatus.receivedAtStation,
      stationLocation: 'Received at Station W3-PYX-02',
      etaText: 'Ready for Patient Delivery',
    );
    notifyListeners();
  }

  void deliverPodToPatient() {
    _activePod = _activePod.copyWith(
      status: PodStatus.deliveredToPatient,
      stationLocation: 'Delivered to Bed 310-C',
      etaText: 'Administered by Nurse',
    );
    _statUrgents = (_statUrgents > 0) ? _statUrgents - 1 : 0;
    _dispensedAndVerified++;
    notifyListeners();
  }

  void bringPrescriptionToPatient() {
    _doctorRxOrder = _doctorRxOrder.copyWith(
      isBroughtToPatient: true,
      pharmacistReviewStatus: 'Delivered to Bed 304-A by Nurse Fatima Ali',
    );
    _pendingCheck = (_pendingCheck > 0) ? _pendingCheck - 1 : 0;
    _dispensedAndVerified++;
    notifyListeners();
  }

  void addDoctorRxOrder({
    required String patientName,
    required String bedCode,
    required String regimenName,
    required String doctorName,
  }) {
    _doctorRxOrder = PendingDoctorOrder(
      id: 'rx-${DateTime.now().millisecondsSinceEpoch}',
      patientName: patientName,
      bedCode: bedCode,
      regimenName: regimenName,
      orderingDoctor: doctorName,
      timeAgo: 'Just now',
    );
    _pendingCheck++;
    notifyListeners();
  }

  void requestRestock() {
    _pendingCheck++;
    notifyListeners();
  }
}
