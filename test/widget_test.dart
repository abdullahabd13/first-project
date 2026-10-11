import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training/main.dart';
import 'package:training/models/prescription_model.dart';
import 'package:training/models/user_model.dart';
import 'package:training/services/app_settings_service.dart';
import 'package:training/services/auth_service.dart';
import 'package:training/services/pharmacy_service.dart';
import 'package:training/services/prescription_service.dart';

void main() {
  setUp(() {
    AuthService().signOut();
  });

  testWidgets(
    'displays WelcomeScreen on initial launch and navigates to sign in',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      expect(find.text('H . M . S'), findsWidgets);
      expect(find.text('Hospital Management System'), findsOneWidget);
      expect(find.byKey(const Key('welcomeGetStarted')), findsOneWidget);

      // Tap Get Started -> RoleSelectionScreen
      await tester.tap(find.byKey(const Key('welcomeGetStarted')));
      await tester.pumpAndSettle();

      expect(find.text('Select Your Role'), findsOneWidget);
      expect(find.text('Doctor / Physician'), findsOneWidget);

      // Continue to Registration
      await tester.tap(find.byKey(const Key('roleContinue')));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);

      // Navigate to Sign In
      await tester.tap(find.byKey(const Key('goToSignIn')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byKey(const Key('quickLoginDoctor')), findsOneWidget);
      expect(find.byKey(const Key('quickLoginNurse')), findsOneWidget);
    },
  );

  testWidgets(
    'Doctor Portal: accessed only via login, displays all tabs and allows prescription editing',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. Sign in as Doctor
      AuthService().quickLogin(UserRole.doctor);

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      // Verify Doctor Portal header and tabs
      expect(find.text('DOCTOR CLINICAL PORTAL'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Beds & Ward'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify Patient Encounter screen (Screen 3)
      expect(find.text('Ahmed Tariq'), findsOneWidget);
      expect(find.text('Active Orders for Verification'), findsOneWidget);
      expect(find.text('Amlodipine 5mg'), findsOneWidget);
      expect(find.textContaining('Confirm & Save Orders'), findsOneWidget);

      await tester.tap(find.text('عربي'));
      await tester.pumpAndSettle();

      final arabicEncounter = find.text('معاينة المريض الحالية');
      expect(arabicEncounter, findsOneWidget);
      expect(find.text('فريق الرعاية وممرضو الردهة'), findsOneWidget);
      expect(
        Directionality.of(tester.element(arabicEncounter)),
        TextDirection.rtl,
      );

      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Active Patient Encounter'), findsOneWidget);

      // Verify Doctor prescription authority
      expect(PrescriptionService().canModifyPrescriptions, isTrue);

      // Doctor modifies a prescription
      final success = PrescriptionService().updatePrescription(
        'rx-01',
        'Amlodipine 10mg',
        'Oral • Increased dose',
        'Verified',
      );
      expect(success, isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Amlodipine 10mg'), findsOneWidget);

      // Switch to Beds & Ward tab (Screen 1 - Floor A, B, C structure)
      await tester.tap(find.text('Beds & Ward'));
      await tester.pumpAndSettle();

      expect(find.text('MAIN INPATIENT COMPLEX'), findsOneWidget);
      expect(find.text('Floor A'), findsWidgets);
      expect(find.text('Floor B'), findsWidgets);
      expect(find.text('Floor C'), findsWidgets);
      expect(find.text('Transfer'), findsWidgets);

      // Switch to Staff tab (Screen 2 - Floor roster & load filters)
      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();

      expect(find.text('Floor Nursing Roster'), findsOneWidget);
      expect(find.text('Fatima Ali, RN'), findsWidgets);
      expect(find.text('Omar Kareem, RN'), findsOneWidget);
      expect(find.text('Filter Staff Roster'), findsOneWidget);

      // Switch to Profile tab & Sign Out
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Level 4 Sign-Off (Full Rx Authority)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('doctorSignOutButton')));
      await tester.pumpAndSettle();

      // Verify returned to WelcomeScreen
      expect(find.byKey(const Key('welcomeGetStarted')), findsOneWidget);
    },
  );

  testWidgets(
    'Nurse Portal: 3-tab navigation, read-only prescriptions, pharmacy dispensing, and sign out',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Sign in as Nurse
      AuthService().quickLogin(UserRole.nurse);

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      // Verify Nurse Portal header
      expect(find.text('NURSE BEDSIDE & DISPENSARY PORTAL'), findsOneWidget);

      // Verify 3 bottom navigation tabs (Map removed)
      expect(find.text('Rounds'), findsOneWidget);
      expect(find.text('Map'), findsNothing);
      expect(find.text('Pharmacy'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Screen 1: Rounds — verify ward rounds content
      expect(find.text('Round 2 of 4'), findsOneWidget);
      expect(find.text('ACTIVE BEDSIDE CARE'), findsOneWidget);
      expect(find.text('Ahmed Tariq'), findsWidgets);
      expect(find.text('Log Bedside Vitals'), findsOneWidget);

      // Verify Nurse cannot modify prescriptions
      expect(PrescriptionService().canModifyPrescriptions, isFalse);

      // Attempting modification fails
      final addResult = PrescriptionService().addPrescription(
        PrescriptionItem(
          id: 'rx-unauth',
          medicationName: 'Unauthorized Med',
          dosageAndRoute: 'Oral',
          status: 'Pending',
          prescribedAt: DateTime.now(),
        ),
      );
      expect(addResult, isFalse);

      // Switch to Pharmacy tab (Screen 3)
      await tester.tap(find.text('Pharmacy'));
      await tester.pumpAndSettle();

      expect(find.text('Ward 3 Satellite Dispensary'), findsOneWidget);
      expect(find.text('SHIFT DISPENSING VELOCITY'), findsOneWidget);
      expect(find.text('Orders Pending Clearance'), findsOneWidget);

      // Switch to Profile tab and sign out
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('CLINICAL CREDENTIALS'), findsOneWidget);
      expect(find.text('Sign Out of Nurse Portal'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nurseSignOutButton')));
      await tester.pumpAndSettle();

      // Verify returned to WelcomeScreen
      expect(find.byKey(const Key('welcomeGetStarted')), findsOneWidget);
    },
  );

  test('PharmacyService: nurse medication retrieval, pneumatic pod delivery & restock workflows', () {
    final pharmacy = PharmacyService();
    final initialVended = pharmacy.dispensedAndVerified;

    // 1. Acknowledge Pneumatic Pod arrival at nurse station
    pharmacy.acknowledgePodReceipt();
    expect(pharmacy.activePod.stationLocation, contains('Received at Station'));

    // 2. Deliver Pod to patient
    pharmacy.deliverPodToPatient();
    expect(
      pharmacy.activePod.stationLocation,
      contains('Delivered to Bed 310-C'),
    );
    expect(pharmacy.dispensedAndVerified, initialVended + 1);

    // 3. Nurse brings Doctor's verified prescription from pharmacy to patient
    final beforePending = pharmacy.pendingCheck;
    pharmacy.bringPrescriptionToPatient();
    expect(pharmacy.doctorRxOrder.isBroughtToPatient, isTrue);
    expect(
      pharmacy.doctorRxOrder.pharmacistReviewStatus,
      contains('Nurse Fatima Ali'),
    );
    expect(pharmacy.dispensedAndVerified, initialVended + 2);
    expect(pharmacy.pendingCheck, (beforePending > 0) ? beforePending - 1 : 0);

    // 4. Request Restock
    final beforeRestock = pharmacy.pendingCheck;
    pharmacy.requestRestock();
    expect(pharmacy.pendingCheck, beforeRestock + 1);
  });

  test('AppSettingsService: theme mode and language toggling', () {
    final settings = AppSettingsService();
    // Default is light and English
    settings.setThemeMode(ThemeMode.light);
    settings.setLanguage(AppLanguage.english);

    expect(settings.isDarkMode, isFalse);
    expect(settings.isArabic, isFalse);
    expect(settings.textDirection, TextDirection.ltr);

    // Toggle theme to dark
    settings.toggleTheme();
    expect(settings.isDarkMode, isTrue);
    expect(settings.themeMode, ThemeMode.dark);

    // Toggle language to Arabic
    settings.toggleLanguage();
    expect(settings.isArabic, isTrue);
    expect(settings.language, AppLanguage.arabic);
    expect(settings.textDirection, TextDirection.rtl);
    expect(settings.currentLocale, const Locale('ar'));
    expect(settings.tr('BAGHDAD MEDICAL CITY'), 'مدينة الطب بغداد');

    // Toggle back to light and English
    settings.toggleTheme();
    expect(settings.isDarkMode, isFalse);
    settings.toggleLanguage();
    expect(settings.isArabic, isFalse);
    expect(settings.textDirection, TextDirection.ltr);
  });

  testWidgets(
    'Patients and Nurses Management: horizontal tracks, avatar trigger, clinical assessment, and discharge note',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Login as doctor
      AuthService().quickLogin(UserRole.doctor);

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      // 1. Verify Horizontal Carousels exist
      expect(find.textContaining('Queue & Profiles'), findsOneWidget);
      expect(find.text('Care Team & Floor Nurses'), findsOneWidget);
      expect(find.text('Ahmed Tariq'), findsOneWidget);
      expect(find.text('Mariam Al-Saadi'), findsOneWidget);
      expect(find.text('Nurse Fatima Ali, RN'), findsWidgets);
      expect(find.text('Nurse Sarah Kareem, BSN'), findsOneWidget);

      // 2. Verify In-Page Clinical Assessment and Discharge Note sections
      expect(find.text('Clinical Assessment'), findsOneWidget);
      expect(find.text('Discharge Note & Disposition'), findsOneWidget);
      expect(find.textContaining('Hypertensive Crisis'), findsOneWidget);
      expect(find.textContaining('Hypertensive Urgency'), findsOneWidget);

      // 3. Test interactive click trigger on patient avatar -> opens slide-over drawer
      final avatarTriggers = find.byTooltip(
        'Click avatar to view full patient dossier',
      );
      expect(avatarTriggers, findsWidgets);

      // Tap first avatar
      await tester.tap(avatarTriggers.first);
      await tester.pumpAndSettle();

      // Verify slide-over drawer content
      expect(find.text('Ahmed Tariq — Dossier'), findsOneWidget);
      expect(find.text('Clinical Assessment'), findsWidgets);
      expect(find.text('Discharge Note & Disposition'), findsWidgets);

      // Close the drawer
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 4. Test selecting another patient in the horizontal track
      await tester.tap(find.text('Mariam Al-Saadi'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Mariam Al-Saadi'), findsWidgets);

      // 5. Test Nurse quick assignment in horizontal track
      final assignButtons = find.text('Assign to Active Patient');
      if (assignButtons.evaluate().isNotEmpty) {
        await tester.tap(assignButtons.first);
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets(
    'Nurse Portal: Bedside Medication administration workflow, patient queue, multi-select, Confirm & Save, and auto-advance',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Login as nurse
      AuthService().quickLogin(UserRole.nurse);
      AppSettingsService().setLanguage(AppLanguage.english);
      AppSettingsService().setThemeMode(ThemeMode.light);

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      // Switch to Pharmacy tab
      await tester.tap(find.text('Pharmacy'));
      await tester.pumpAndSettle();

      // 1. Verify Bedside Medication Administration section exists
      expect(find.text('Bedside Medication Administration'), findsOneWidget);
      expect(find.textContaining('Patients in Queue'), findsOneWidget);

      // 2. Initial selected patient is Ahmed Tariq (Bed 304-A) with active orders
      expect(find.text('Ahmed Tariq (Bed 304-A)'), findsOneWidget);
      expect(find.text('Amlodipine 5mg'), findsWidgets);
      expect(find.text('Confirm & Save'), findsOneWidget);
      expect(find.text('Transfer / Handover'), findsOneWidget);

      // 3. Test selecting another patient in the queue: Layla Abbas
      await tester.tap(find.text('Layla Abbas'));
      await tester.pumpAndSettle();
      expect(find.text('Layla Abbas (Bed 305-B)'), findsOneWidget);
      expect(find.text('Cefazolin 1g IV'), findsOneWidget);

      // 4. Test multi-select: uncheck all then check one
      await tester.tap(find.text('Deselect All'));
      await tester.pumpAndSettle();
      expect(find.text('Select All'), findsOneWidget);

      // Tap Cefazolin order to select it
      await tester.tap(find.text('Cefazolin 1g IV'));
      await tester.pumpAndSettle();

      // 5. Tap Confirm & Save: animates out and auto-advances to next patient
      await tester.tap(find.text('Confirm & Save'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Verify auto-advanced to Zainab Noor (Bed 310-C)
      expect(find.text('Zainab Noor (Bed 310-C)'), findsOneWidget);
      expect(find.text('Ceftriaxone 1g IV'), findsWidgets);

      // 6. Test Transfer / Handover action on Zainab Noor
      await tester.tap(find.text('Transfer / Handover'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Verify auto-advanced to Hussein K. (Bed 306-A)
      expect(find.text('Hussein K. (Bed 306-A)'), findsOneWidget);
    },
  );

  testWidgets(
    'Nurse Portal: Rounds dashboard timeline, Overdue/Upcoming status indicators, and quick-action status toggles',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Login as nurse
      AuthService().quickLogin(UserRole.nurse);
      AppSettingsService().setLanguage(AppLanguage.english);

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      // 1. Verify Rounds dashboard header & timeline
      expect(find.text('Round 2 of 4'), findsOneWidget);
      expect(find.text('R1 (07:00)'), findsOneWidget);
      expect(find.text('R2 (09:30)'), findsOneWidget);
      expect(find.text('R3 (11:30)'), findsOneWidget);

      // 2. Verify Overdue status card for Bed 310-C exists
      expect(find.text('Overdue'), findsOneWidget);
      expect(find.text('BED 310-C'), findsOneWidget);
      expect(find.text('Administer STAT'), findsOneWidget);

      // 3. Toggle Overdue round status to Done
      await tester.tap(find.text('Administer STAT'));
      await tester.pumpAndSettle();
      expect(find.text('Done ✓'), findsOneWidget);

      // 4. Verify Active Bedside Care Ahmed Tariq (Bed 304-A)
      expect(find.text('ACTIVE BEDSIDE CARE'), findsOneWidget);
      expect(find.text('Ahmed Tariq'), findsWidgets);
      expect(find.text('Administer'), findsOneWidget);

      // Tap Administer Lisinopril
      await tester.tap(find.text('Administer'));
      await tester.pumpAndSettle();
      expect(find.text('Administered ✓'), findsOneWidget);

      // 5. Verify Upcoming beds (305-B, 306-A) and toggle status
      expect(find.text('BED 305-B'), findsOneWidget);
      expect(find.text('Start Round'), findsOneWidget);
      await tester.tap(find.text('Start Round'));
      await tester.pumpAndSettle();
      expect(find.text('Completed ✓'), findsOneWidget);
    },
  );

  testWidgets(
    'Nurse Portal: Theme Engine & Arabic RTL localization consistency',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Login as nurse
      AuthService().quickLogin(UserRole.nurse);
      final settings = AppSettingsService();
      settings.setThemeMode(ThemeMode.light);
      settings.setLanguage(AppLanguage.english);

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      // 1. Switch to Dark Mode
      settings.toggleTheme();
      await tester.pumpAndSettle();
      expect(settings.isDarkMode, isTrue);

      // Verify dark mode components render with dark card / dark surface
      expect(find.text('Round 2 of 4'), findsOneWidget);
      expect(find.text('ACTIVE BEDSIDE CARE'), findsOneWidget);

      // 2. Switch to Arabic (RTL)
      settings.toggleLanguage();
      await tester.pumpAndSettle();
      expect(settings.isArabic, isTrue);
      expect(settings.textDirection, TextDirection.rtl);

      // 3. Verify clinical healthcare terms in Arabic
      expect(find.text('جولات تمريضية'), findsOneWidget);
      expect(find.text('إدارة الأدوية'), findsOneWidget);
      expect(find.text('الرعاية السريرية الفعالة'), findsOneWidget);
      expect(find.text('تسجيل المؤشرات الحيوية'), findsOneWidget);

      // Switch to Pharmacy tab in Arabic
      await tester.tap(find.text('إدارة الأدوية'));
      await tester.pumpAndSettle();

      expect(find.text('صيدلية الردهة 3 المؤتمتة'), findsOneWidget);
      expect(find.text('إدارة وتوزيع الأدوية السريرية'), findsOneWidget);
      expect(find.text('تأكيد وحفظ'), findsOneWidget);
      expect(find.text('تسليم الشفت'), findsOneWidget);

      // Switch back to English & Light mode
      settings.toggleLanguage();
      settings.toggleTheme();
      await tester.pumpAndSettle();
      expect(settings.isArabic, isFalse);
      expect(settings.isDarkMode, isFalse);
    },
  );

  testWidgets(
    'Doctor Portal: Metrics ribbon, EMR timeline, diagnostic labs, SOAP workflow & Telehealth toggle',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Sign in as Doctor
      AuthService().quickLogin(UserRole.doctor);
      final settings = AppSettingsService();
      settings.setThemeMode(ThemeMode.light);
      settings.setLanguage(AppLanguage.english);

      await tester.pumpWidget(const BaghdadMedicalCityApp());
      await tester.pumpAndSettle();

      // 1. Verify Top Quick Metrics Ribbon
      expect(find.text('Total Patients Today'), findsOneWidget);
      expect(find.text('Pending Lab Results'), findsOneWidget);
      expect(find.text('Unsigned SOAP Notes'), findsOneWidget);
      expect(find.text('High Acuity / Critical'), findsOneWidget);

      // 2. Verify Emergency Clinical Alert Banner
      expect(find.text('Emergency Clinical Alert'), findsOneWidget);
      expect(find.text('Critical'), findsWidgets);

      // 3. Verify Active Allergies ribbon
      expect(find.text('Active Allergies: '), findsOneWidget);
      expect(find.text('Penicillin (Anaphylaxis)'), findsOneWidget);

      // 4. Verify Clinical History Timeline
      expect(find.text('Clinical History Timeline'), findsOneWidget);
      expect(find.text('ER Acute Admission'), findsOneWidget);
      expect(find.text('Laparoscopic Cholecystectomy'), findsOneWidget);

      // 5. Verify Diagnostic & Lab Viewer Grid with highlighted parameters
      expect(find.text('Diagnostic & Lab Viewer'), findsOneWidget);
      expect(find.text('Serum Creatinine'), findsOneWidget);
      expect(find.text('1.4 mg/dL'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Cardiac Troponin T'), findsOneWidget);
      expect(find.text('Negative'), findsOneWidget);

      // 6. Verify SOAP Notes form & Telehealth toggle
      expect(find.text('SOAP Clinical Notes'), findsOneWidget);
      expect(find.text('In-Person Bedside'), findsWidgets);
      expect(find.text('Telehealth Video'), findsWidgets);

      // Switch encounter mode to Telehealth
      await tester.tap(find.text('Telehealth Video').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Telehealth Video'), findsWidgets);

      // Test Quick-Insert diagnostic chip
      expect(find.text('Acute BP Spike'), findsOneWidget);
      expect(find.text('Rule out TIA'), findsOneWidget);
      await tester.tap(find.text('Rule out TIA'));
      await tester.pumpAndSettle();

      // 7. Verify Drug Safety & Interaction Warning banner
      expect(find.text('Drug-Drug Interaction Warning'), findsOneWidget);

      // 8. Verify Order Pad quick action buttons
      expect(find.text('Order Lab Test'), findsOneWidget);
      expect(find.text('Order Radiology'), findsOneWidget);
      await tester.tap(find.text('Order Lab Test'));
      await tester.pumpAndSettle();
      expect(find.textContaining('CBC, Electrolytes'), findsOneWidget);
    },
  );

  testWidgets('Doctor Portal: Dark Mode and Arabic RTL localization', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Sign in as Doctor
    AuthService().quickLogin(UserRole.doctor);
    final settings = AppSettingsService();
    settings.setThemeMode(ThemeMode.light);
    settings.setLanguage(AppLanguage.english);

    await tester.pumpWidget(const BaghdadMedicalCityApp());
    await tester.pumpAndSettle();

    // 1. Switch to Dark Mode
    settings.toggleTheme();
    await tester.pumpAndSettle();
    expect(settings.isDarkMode, isTrue);

    // Verify dark mode components render cleanly
    expect(find.text('DOCTOR CLINICAL PORTAL'), findsOneWidget);
    expect(find.text('Total Patients Today'), findsOneWidget);

    // 2. Switch to Arabic (RTL)
    settings.toggleLanguage();
    await tester.pumpAndSettle();
    expect(settings.isArabic, isTrue);
    expect(settings.textDirection, TextDirection.rtl);

    // 3. Verify formal medical Arabic terminology
    expect(find.text('البوابة السريرية للأطباء'), findsOneWidget);
    expect(find.text('إجمالي المرضى اليوم'), findsOneWidget);
    expect(find.text('نتائج مختبرية معلقة'), findsOneWidget);
    expect(find.text('ملاحظات سريرية غير موقعة'), findsOneWidget);
    expect(find.text('تنبيه سريري طارئ'), findsOneWidget);
    expect(find.text('الحساسية النشطة: '), findsOneWidget);
    expect(find.text('الجدول الزمني للتاريخ السريري'), findsOneWidget);
    expect(find.text('الفحوصات المخبرية والتشخيصية'), findsOneWidget);
    expect(find.text('التوثيق السريري SOAP'), findsOneWidget);
    expect(find.text('تحذير تداخل دوائي'), findsOneWidget);
    expect(find.text('طلب فحص مخبري'), findsOneWidget);
    expect(find.text('طلب أشعة وسونار'), findsOneWidget);

    // Switch back
    settings.toggleLanguage();
    settings.toggleTheme();
    await tester.pumpAndSettle();
  });
}
