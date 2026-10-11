// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 14: MockHospitalData.primaryActiveBed -> Initial bedside patient dataset for Ward 3 (Bed 304-A).
// - Line 37: MockHospitalData.upcomingBedsInRound -> Patient records for remaining beds in current round.
// - Line 72: MockHospitalData.initialDispensaryVault -> Inventory stock for satellite medicine dispenser units.
// - Line 112: MockHospitalData.activePodOrder -> STAT pneumatic tube transfer order in transit.
// - Line 124: MockHospitalData.pendingDoctorRx -> Verified physician prescription order awaiting delivery.
// ============================================================================

import '../models/pharmacy_item_model.dart';
import '../models/ward_bed_model.dart';

class MockHospitalData {
  static const WardBedPatient primaryActiveBed = WardBedPatient(
    bedCode: '304-A',
    patientName: 'Ahmed Tariq',
    demographics: 'Male, 45y • Post-cholecystectomy',
    condition: 'Post-Op Recovery & Hypertension',
    attendingPhysician: 'Dr. Zaid Al-Husseini',
    statusBadge: 'Stable',
    roomWing: 'Observation Wing • Direct Sightline',
    vitals: BedsideVitals(
      bloodPressure: '135/88',
      pulse: '78 bpm',
      spo2: '98%',
      temperature: '37.1 °C',
      bpTimeAgo: '15m ago',
      rhythm: 'Regular rhythm',
      o2Mode: 'Room air',
      tempMode: 'Tympanic • Afebrile',
    ),
    activeInfusion: 'Saline 0.9% Normal (60 mL/hr • 300 mL remaining)',
    pendingMedication: 'Lisinopril 10mg Oral (Due in 30m • Hypertension protocol)',
    isMedDue: true,
  );

  static const List<WardBedPatient> upcomingBedsInRound = [
    WardBedPatient(
      bedCode: '305-B',
      patientName: 'Layla Abbas',
      demographics: 'Female, 52y • Surgical Day 1',
      condition: 'Post-op inspection & drain check',
      attendingPhysician: 'Dr. Zaid Al-Husseini',
      statusBadge: 'Needs Vitals',
      roomWing: 'Observation Wing',
      vitals: BedsideVitals(
        bloodPressure: '128/82',
        pulse: '74 bpm',
        spo2: '99%',
        temperature: '36.8 °C',
      ),
      isVitalsPending: true,
    ),
    WardBedPatient(
      bedCode: '310-C',
      patientName: 'Zainab Noor',
      demographics: 'Female, 38y • Sepsis Protocol',
      condition: 'Ceftriaxone 1g IV due 11:30',
      attendingPhysician: 'Dr. Zaid Al-Husseini',
      statusBadge: 'Stat Med Due',
      roomWing: 'Acute Care Bay 2',
      vitals: BedsideVitals(
        bloodPressure: '118/76',
        pulse: '88 bpm',
        spo2: '96%',
        temperature: '38.2 °C',
      ),
      isMedDue: true,
    ),
  ];

  static const List<DispenserMedication> initialDispensaryVault = [
    DispenserMedication(
      id: 'disp-01',
      name: 'Amlodipine 5mg',
      form: 'Tablets',
      drawer: 'Drawer 2B',
      unitsAvailable: 48,
      statusBadge: 'Normal',
      actionType: 'Vend',
    ),
    DispenserMedication(
      id: 'disp-02',
      name: 'Lisinopril 10mg',
      form: 'Oral Tab',
      drawer: 'Drawer 3A',
      unitsAvailable: 12,
      statusBadge: 'Auto-Reordered',
      actionType: 'Details',
    ),
    DispenserMedication(
      id: 'disp-03',
      name: 'Normal Saline 0.9%',
      form: '24 bags (500mL)',
      drawer: 'Warmer Bay 1',
      unitsAvailable: 24,
      statusBadge: 'Optimal',
      actionType: 'Log Use',
    ),
    DispenserMedication(
      id: 'disp-04',
      name: 'Morphine 4mg/mL',
      form: 'Sch-II • 6 ampules',
      drawer: 'Vault Safe',
      unitsAvailable: 6,
      statusBadge: 'Dual Witness',
      actionType: 'Unlock',
      isControlled: true,
    ),
  ];

  static const PneumaticPodOrder activePodOrder = PneumaticPodOrder(
    id: 'pod-07',
    podNumber: 'Pneumatic Pod #07',
    medicationName: 'Ceftriaxone 1g IV Piggyback',
    patientName: 'Zainab Noor',
    bedCode: 'Bed 310-C',
    protocol: 'Severe Sepsis Protocol',
    stationLocation: 'In transit • Station 3',
    etaText: 'ETA 4 mins',
    status: PodStatus.inTransit,
  );

  static const PendingDoctorOrder pendingDoctorRx = PendingDoctorOrder(
    id: 'clr-rx-01',
    patientName: 'Ahmed Tariq',
    bedCode: 'Bed 304-A',
    regimenName: 'Antihypertensive Titration Regimen',
    orderingDoctor: 'Dr. Zaid Al-Husseini, MD (Cardiology)',
    timeAgo: '10m ago',
    pharmacistReviewStatus: 'Central Pharmacist Dosing Review Passed',
    isCleared: true,
    isBroughtToPatient: false,
  );
}
