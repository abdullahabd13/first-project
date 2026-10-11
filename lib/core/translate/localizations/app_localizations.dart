import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localizations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Baghdad Medical City'**
  String get appName;

  /// No description provided for @hospitalManagementSystem.
  ///
  /// In en, this message translates to:
  /// **'Hospital Management System'**
  String get hospitalManagementSystem;

  /// No description provided for @baghdadMedicalCity.
  ///
  /// In en, this message translates to:
  /// **'BAGHDAD MEDICAL CITY'**
  String get baghdadMedicalCity;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @iAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I Already Have an Account'**
  String get iAlreadyHaveAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your Baghdad Medical City\nclinical portal.'**
  String get signInSubtitle;

  /// No description provided for @emailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get emailAndPassword;

  /// No description provided for @phoneAndOtp.
  ///
  /// In en, this message translates to:
  /// **'Phone & OTP (Iraq 🇮🇶)'**
  String get phoneAndOtp;

  /// No description provided for @emailOrClinicalId.
  ///
  /// In en, this message translates to:
  /// **'Email or Clinical ID'**
  String get emailOrClinicalId;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @smsVerification.
  ///
  /// In en, this message translates to:
  /// **'SMS Verification (OTP)'**
  String get smsVerification;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @quickDemoAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Demo Access (Mock Data)'**
  String get quickDemoAccess;

  /// No description provided for @doctorLogin.
  ///
  /// In en, this message translates to:
  /// **'👨‍⚕️ Doctor Login'**
  String get doctorLogin;

  /// No description provided for @nurseLogin.
  ///
  /// In en, this message translates to:
  /// **'👩‍⚕️ Nurse Login'**
  String get nurseLogin;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectYourRole;

  /// No description provided for @roleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your clinical portal profile to\nproceed with account registration.'**
  String get roleSubtitle;

  /// No description provided for @doctorPhysician.
  ///
  /// In en, this message translates to:
  /// **'Doctor / Physician'**
  String get doctorPhysician;

  /// No description provided for @doctorRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Consultations, patient diagnostics, clinical care orders & medication prescriptions.'**
  String get doctorRoleDesc;

  /// No description provided for @registeredNurse.
  ///
  /// In en, this message translates to:
  /// **'Nurse / Bedside Care'**
  String get registeredNurse;

  /// No description provided for @nurseRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Bedside ward rounds, vitals telemetry logging, med administration & floor med triage.'**
  String get nurseRoleDesc;

  /// No description provided for @continueToRegistration.
  ///
  /// In en, this message translates to:
  /// **'Continue to Registration'**
  String get continueToRegistration;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered? '**
  String get alreadyRegistered;

  /// No description provided for @step1Of2.
  ///
  /// In en, this message translates to:
  /// **'STEP 1 OF 2 • ROLE PROFILE'**
  String get step1Of2;

  /// No description provided for @credentialNotice.
  ///
  /// In en, this message translates to:
  /// **'Hospital credentials and department assignment will be verified during profile fill in the next step.'**
  String get credentialNotice;

  /// No description provided for @doctorClinicalPortal.
  ///
  /// In en, this message translates to:
  /// **'DOCTOR CLINICAL PORTAL'**
  String get doctorClinicalPortal;

  /// No description provided for @shift1.
  ///
  /// In en, this message translates to:
  /// **'Shift 1'**
  String get shift1;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @bedsAndWard.
  ///
  /// In en, this message translates to:
  /// **'Beds & Ward'**
  String get bedsAndWard;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @activePatientEncounter.
  ///
  /// In en, this message translates to:
  /// **'Active Patient Encounter'**
  String get activePatientEncounter;

  /// No description provided for @bedsideRound.
  ///
  /// In en, this message translates to:
  /// **'BEDSIDE ROUND'**
  String get bedsideRound;

  /// No description provided for @inConsultation.
  ///
  /// In en, this message translates to:
  /// **'In Consultation'**
  String get inConsultation;

  /// No description provided for @bloodPress.
  ///
  /// In en, this message translates to:
  /// **'BLOOD PRESS'**
  String get bloodPress;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'HEART RATE'**
  String get heartRate;

  /// No description provided for @spo2.
  ///
  /// In en, this message translates to:
  /// **'SPO2'**
  String get spo2;

  /// No description provided for @clinicalAssessment.
  ///
  /// In en, this message translates to:
  /// **'Clinical Assessment'**
  String get clinicalAssessment;

  /// No description provided for @dischargeNote.
  ///
  /// In en, this message translates to:
  /// **'Discharge Note & Disposition'**
  String get dischargeNote;

  /// No description provided for @signedAndFinalized.
  ///
  /// In en, this message translates to:
  /// **'Signed & Finalized'**
  String get signedAndFinalized;

  /// No description provided for @draftPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Draft / Pending Review'**
  String get draftPendingReview;

  /// No description provided for @authorSignDischargeNote.
  ///
  /// In en, this message translates to:
  /// **'Author & Sign Discharge Note'**
  String get authorSignDischargeNote;

  /// No description provided for @editViewDischargeNote.
  ///
  /// In en, this message translates to:
  /// **'Edit / View Discharge Note'**
  String get editViewDischargeNote;

  /// No description provided for @activeOrdersVerification.
  ///
  /// In en, this message translates to:
  /// **'Active Orders for Verification'**
  String get activeOrdersVerification;

  /// No description provided for @orderRx.
  ///
  /// In en, this message translates to:
  /// **'Order Rx'**
  String get orderRx;

  /// No description provided for @confirmSaveOrders.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Save Orders'**
  String get confirmSaveOrders;

  /// No description provided for @upcomingPatientsQueue.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Patients Queue'**
  String get upcomingPatientsQueue;

  /// No description provided for @attendingPhysician.
  ///
  /// In en, this message translates to:
  /// **'Attending Physician'**
  String get attendingPhysician;

  /// No description provided for @clinicalCredentials.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL CREDENTIALS'**
  String get clinicalCredentials;

  /// No description provided for @signOutDoctor.
  ///
  /// In en, this message translates to:
  /// **'Sign Out of Doctor Portal'**
  String get signOutDoctor;

  /// No description provided for @changeNurse.
  ///
  /// In en, this message translates to:
  /// **'Change Nurse'**
  String get changeNurse;

  /// No description provided for @assignedNurse.
  ///
  /// In en, this message translates to:
  /// **'Assigned Nurse'**
  String get assignedNurse;

  /// No description provided for @transferPatient.
  ///
  /// In en, this message translates to:
  /// **'Transfer Patient'**
  String get transferPatient;

  /// No description provided for @nextPatient.
  ///
  /// In en, this message translates to:
  /// **'Next Patient'**
  String get nextPatient;

  /// No description provided for @editClinicalAssessment.
  ///
  /// In en, this message translates to:
  /// **'Edit Clinical Assessment'**
  String get editClinicalAssessment;

  /// No description provided for @saveAndNextPatient.
  ///
  /// In en, this message translates to:
  /// **'Save & Next Patient'**
  String get saveAndNextPatient;

  /// No description provided for @mainInpatientComplex.
  ///
  /// In en, this message translates to:
  /// **'MAIN INPATIENT COMPLEX'**
  String get mainInpatientComplex;

  /// No description provided for @floorA.
  ///
  /// In en, this message translates to:
  /// **'Floor A'**
  String get floorA;

  /// No description provided for @floorB.
  ///
  /// In en, this message translates to:
  /// **'Floor B'**
  String get floorB;

  /// No description provided for @floorC.
  ///
  /// In en, this message translates to:
  /// **'Floor C'**
  String get floorC;

  /// No description provided for @allFloors.
  ///
  /// In en, this message translates to:
  /// **'All Floors'**
  String get allFloors;

  /// No description provided for @availableBeds.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableBeds;

  /// No description provided for @occupiedBeds.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupiedBeds;

  /// No description provided for @filterBeds.
  ///
  /// In en, this message translates to:
  /// **'Filter Beds'**
  String get filterBeds;

  /// No description provided for @transferRoom.
  ///
  /// In en, this message translates to:
  /// **'Transfer Room'**
  String get transferRoom;

  /// No description provided for @triageActionRequired.
  ///
  /// In en, this message translates to:
  /// **'TRIAGE ACTION REQUIRED'**
  String get triageActionRequired;

  /// No description provided for @approveTransfer.
  ///
  /// In en, this message translates to:
  /// **'Approve Transfer'**
  String get approveTransfer;

  /// No description provided for @deferTransfer.
  ///
  /// In en, this message translates to:
  /// **'Defer'**
  String get deferTransfer;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @totalBeds.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalBeds;

  /// No description provided for @occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @morningShift.
  ///
  /// In en, this message translates to:
  /// **'MORNING SHIFT • 07:00 - 15:00'**
  String get morningShift;

  /// No description provided for @floorNursingRoster.
  ///
  /// In en, this message translates to:
  /// **'Floor Nursing Roster'**
  String get floorNursingRoster;

  /// No description provided for @onDuty.
  ///
  /// In en, this message translates to:
  /// **'On Duty'**
  String get onDuty;

  /// No description provided for @activeFloor.
  ///
  /// In en, this message translates to:
  /// **'Active Floor'**
  String get activeFloor;

  /// No description provided for @onBreak.
  ///
  /// In en, this message translates to:
  /// **'On Break'**
  String get onBreak;

  /// No description provided for @handover.
  ///
  /// In en, this message translates to:
  /// **'Handover'**
  String get handover;

  /// No description provided for @assignToPatient.
  ///
  /// In en, this message translates to:
  /// **'+ Assign to Patient'**
  String get assignToPatient;

  /// No description provided for @broadcastAlert.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Alert to On-Duty Nurses'**
  String get broadcastAlert;

  /// No description provided for @liveSync.
  ///
  /// In en, this message translates to:
  /// **'Live Sync'**
  String get liveSync;

  /// No description provided for @searchNurse.
  ///
  /// In en, this message translates to:
  /// **'Search nurse, bed, or skill...'**
  String get searchNurse;

  /// No description provided for @availableToAssign.
  ///
  /// In en, this message translates to:
  /// **'Available to Assign'**
  String get availableToAssign;

  /// No description provided for @onFloor.
  ///
  /// In en, this message translates to:
  /// **'On Floor'**
  String get onFloor;

  /// No description provided for @highLoad.
  ///
  /// In en, this message translates to:
  /// **'High Load'**
  String get highLoad;

  /// No description provided for @myAssignedPatientPairs.
  ///
  /// In en, this message translates to:
  /// **'My Assigned Patient Pairs'**
  String get myAssignedPatientPairs;

  /// No description provided for @nurseBesidePortal.
  ///
  /// In en, this message translates to:
  /// **'NURSE BEDSIDE & DISPENSARY PORTAL'**
  String get nurseBesidePortal;

  /// No description provided for @morningShiftWard3.
  ///
  /// In en, this message translates to:
  /// **'• Morning Shift (Ward 3)'**
  String get morningShiftWard3;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @round2of4.
  ///
  /// In en, this message translates to:
  /// **'Round 2 of 4'**
  String get round2of4;

  /// No description provided for @activeBesideCare.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE BEDSIDE CARE'**
  String get activeBesideCare;

  /// No description provided for @logBesideVitals.
  ///
  /// In en, this message translates to:
  /// **'Log Bedside Vitals'**
  String get logBesideVitals;

  /// No description provided for @clinicalShortcuts.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL SHORTCUTS'**
  String get clinicalShortcuts;

  /// No description provided for @scanWristband.
  ///
  /// In en, this message translates to:
  /// **'Scan\nWristband'**
  String get scanWristband;

  /// No description provided for @callAttending.
  ///
  /// In en, this message translates to:
  /// **'Call\nAttending'**
  String get callAttending;

  /// No description provided for @wardIncident.
  ///
  /// In en, this message translates to:
  /// **'Ward\nIncident'**
  String get wardIncident;

  /// No description provided for @wardSatelliteDispensary.
  ///
  /// In en, this message translates to:
  /// **'Ward 3 Satellite Dispensary'**
  String get wardSatelliteDispensary;

  /// No description provided for @shiftDispensingVelocity.
  ///
  /// In en, this message translates to:
  /// **'SHIFT DISPENSING VELOCITY'**
  String get shiftDispensingVelocity;

  /// No description provided for @wardMedDispenserUnits.
  ///
  /// In en, this message translates to:
  /// **'Ward Med Dispenser Units'**
  String get wardMedDispenserUnits;

  /// No description provided for @ordersPendingClearance.
  ///
  /// In en, this message translates to:
  /// **'Orders Pending Clearance'**
  String get ordersPendingClearance;

  /// No description provided for @signOutNurse.
  ///
  /// In en, this message translates to:
  /// **'Sign Out of Nurse Portal'**
  String get signOutNurse;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'APP PREFERENCES & LOCALIZATION'**
  String get appPreferences;

  /// No description provided for @displayTheme.
  ///
  /// In en, this message translates to:
  /// **'Display Theme'**
  String get displayTheme;

  /// No description provided for @portalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Portal Language'**
  String get portalLanguage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @defer.
  ///
  /// In en, this message translates to:
  /// **'Defer'**
  String get defer;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @signAndFinalize.
  ///
  /// In en, this message translates to:
  /// **'Sign & Finalize Note'**
  String get signAndFinalize;

  /// No description provided for @directAdmit.
  ///
  /// In en, this message translates to:
  /// **'Direct Admit'**
  String get directAdmit;

  /// No description provided for @shiftTransfer.
  ///
  /// In en, this message translates to:
  /// **'Shift / Transfer'**
  String get shiftTransfer;

  /// No description provided for @wardTeam.
  ///
  /// In en, this message translates to:
  /// **'Ward Team'**
  String get wardTeam;

  /// No description provided for @leadCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge Nurse'**
  String get leadCharge;

  /// No description provided for @emergencyWardAlert.
  ///
  /// In en, this message translates to:
  /// **'Emergency Ward Alert'**
  String get emergencyWardAlert;

  /// No description provided for @codeBlue.
  ///
  /// In en, this message translates to:
  /// **'Code Blue (Cardiac Arrest)'**
  String get codeBlue;

  /// No description provided for @rapidResponse.
  ///
  /// In en, this message translates to:
  /// **'Rapid Response / STAT Consultation'**
  String get rapidResponse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
