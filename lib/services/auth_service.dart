// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 47: AuthService.signInWithEmail() -> Authenticates user via email/password; assigns Doctor or Nurse session.
// - Line 64: AuthService.signInWithPhone() -> Authenticates user via phone number and OTP verification.
// - Line 76: AuthService.signUp() -> Registers new clinician account with selected role and credentials.
// - Line 104: AuthService.quickLogin() -> Fast-tracks demo sign in directly into Doctor or Nurse portal.
// - Line 113: AuthService.signOut() -> Ends active session and resets user to unauthenticated state.
// ============================================================================

import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  static const UserModel mockDoctor = UserModel(
    id: 'doc-001',
    name: 'Dr. Ahmed Al-Saadi',
    email: 'ahmed.alsaadi@bmc.iq',
    phone: '+964 770 123 4567',
    role: UserRole.doctor,
    department: 'Cardiology & Clinical Inpatients',
    hospital: 'H . M . S',
    badgeNumber: 'BMC-DOC-102',
  );

  static const UserModel mockNurse = UserModel(
    id: 'nur-002',
    name: 'Sarah Kareem, RN',
    email: 'sarah.kareem@bmc.iq',
    phone: '+964 780 987 6543',
    role: UserRole.nurse,
    department: 'Ward 4 - Bedside Monitoring & ICU',
    hospital: 'H . M . S',
    badgeNumber: 'BMC-NUR-308',
  );

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 650));

    if (email.toLowerCase().contains('nurse')) {
      _currentUser = mockNurse.copyWith(email: email);
    } else {
      _currentUser = mockDoctor.copyWith(email: email);
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithPhone(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 650));

    _currentUser = mockDoctor.copyWith(phone: phone);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    String? password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? (role == UserRole.doctor ? 'Dr. John Doe' : 'Nurse Jane Doe') : name.trim(),
      email: email.trim().isEmpty ? 'clinician@bmc.iq' : email.trim(),
      phone: phone.trim().isEmpty ? '+964 770 123 4567' : phone.trim(),
      role: role,
      department: role == UserRole.doctor ? 'Clinical Consultations & Diagnostics' : 'Bedside Care & Floor Triage',
      hospital: 'H . M . S',
      badgeNumber: 'BMC-${1000 + DateTime.now().millisecond}',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void quickLogin(UserRole role) {
    if (role == UserRole.doctor) {
      _currentUser = mockDoctor;
    } else {
      _currentUser = mockNurse;
    }
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
