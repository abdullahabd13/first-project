import 'package:flutter/material.dart';

enum AppLanguage { english, arabic }

class AppSettingsService extends ChangeNotifier {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.english;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppLanguage get language => _language;
  bool get isArabic => _language == AppLanguage.arabic;
  Locale get currentLocale =>
      _language == AppLanguage.arabic ? const Locale('ar') : const Locale('en');
  TextDirection get textDirection =>
      _language == AppLanguage.arabic ? TextDirection.rtl : TextDirection.ltr;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _language = _language == AppLanguage.arabic
        ? AppLanguage.english
        : AppLanguage.arabic;
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  /// Translation lookup dictionary by English key
  String tr(String key) {
    if (_language == AppLanguage.arabic) {
      final direct = _arabicTranslations[key];
      if (direct != null) return direct;
      final trimmed = _arabicTranslations[key.trim()];
      if (trimmed != null) return trimmed;
    }
    return key;
  }

  static const Map<String, String> _arabicTranslations = {
    // Branding & General
    'H . M . S': 'H . M . S',
    'BAGHDAD MEDICAL CITY': 'مدينة الطب بغداد',
    'Hospital Management System': 'نظام إدارة المستشفيات',
    'Get Started': 'ابدأ الآن',
    'Sign In': 'تسجيل الدخول',
    'Sign Up': 'إنشاء حساب جديد',
    'I Already Have an Account': 'لدي حساب بالفعل',
    'Welcome Back': 'مرحباً بعودتك',
    'Welcome': 'مرحباً',
    'Sign in to access your H . M . S\nclinical portal.':
        'سجل الدخول للوصول إلى بوابتك السريرية في H . M . S.',
    'Email & Password': 'البريد الإلكتروني وكلمة المرور',
    'Phone & OTP (Iraq 🇮🇶)': 'رقم الهاتف ورمز التحقق (العراق 🇮🇶)',
    'Email or Clinical ID': 'البريد أو المعرف السريري',
    'Password': 'كلمة المرور',
    'Phone Number': 'رقم الهاتف',
    'SMS Verification (OTP)': 'رمز التحقق عبر الرسائل (OTP)',
    'Remember me': 'تذكرني',
    'Forgot Password?': 'نسيت كلمة المرور؟',
    'Quick Demo Access (Mock Data)': 'الدخول التجريبي السريع (بيانات تجريبية)',
    '👨‍⚕️ Doctor Login': '👨‍⚕️ دخول الطبيب',
    '👩‍⚕️ Nurse Login': '👩‍⚕️ دخول التمريض',
    'Don\'t have an account? ': 'ليس لديك حساب؟ ',
    'Already registered? ': 'مسجل بالفعل؟ ',
    'Continue to Registration': 'المتابعة إلى التسجيل',
    'STEP 1 OF 2 • ROLE PROFILE': 'الخطوة 1 من 2 • الملف الوظيفي',
    'Hospital credentials and department assignment will be verified during profile fill in the next step.': 'سيتم التحقق من بيانات المستشفى والقسم أثناء إكمال الملف في الخطوة التالية.',

    // Role Selection
    'Select Your Role': 'حدد صفتك الوظيفية',
    'Choose your clinical portal profile to\nproceed with account registration.':
        'اختر ملفك السريري للمتابعة مع تسجيل الحساب.',
    'Doctor / Physician': 'طبيب / اختصاصي',
    'Consultations, patient diagnostics, clinical care orders & medication prescriptions.':
        'استشارات، تشخيص المرضى، الأوامر السريرية ووصفات الأدوية.',
    'Patient Schedule': 'جدول المرضى',
    'Care Orders': 'الأوامر السريرية',
    'Nurse / Bedside Care': 'تمريض / رعاية سريرية',
    'Bedside ward rounds, vitals telemetry logging, med administration & floor med triage.':
        'جولات الردهات، تسجيل المؤشرات الحيوية، إعطاء الأدوية وفرز الردهة.',
    'Ward Rounds': 'جولات الردهات',
    'Med Stock': 'رصيد الأدوية',
    'Continue': 'متابعة',
    'Create Account': 'إنشاء حساب جديد',

    // Doctor Portal
    'DOCTOR CLINICAL PORTAL': 'البوابة السريرية للأطباء',
    'Shift 1': 'الوردية 1',
    'Patients': 'المرضى',
    'Beds & Ward': 'الأسرة والردهة',
    'Staff': 'الكادر التمريضي',
    'Profile': 'الملف الشخصي',
    'Active Patient Encounter': 'معاينة المريض الحالية',
    'Active Patient': 'المريض النشط',
    'Patients Queue': 'قائمة المرضى',
    'Cardiology Inpatients Shift': 'وردية مرضى القلب الراقدين',
    'Ward 3B • Morning Shift (08:00 - 14:00)':
        'ردهة 3B • الوردية الصباحية (08:00 - 14:00)',
    'BEDSIDE ROUND': 'جولة سريرية',
    'In Consultation': 'قيد المعاينة',
    'BLOOD PRESS': 'ضغط الدم',
    'HEART RATE': 'نبض القلب',
    'SPO2': 'نسبة الأكسجين',
    'Clinical Assessment': 'التقييم السريري',
    'Hypertensive Crisis / Stage 2 — Responsive to initial IV labetalol infusion. Baseline symptoms resolving, headache dissipated, no acute target-organ damage observed.': 'أزمة ارتفاع ضغط الدم / المرحلة الثانية — استجابت للتسريب الوريدي الأولي للابيتالول. الأعراض الأساسية في تحسن، وزال الصداع، ولم تُلاحظ أضرار حادة في الأعضاء المستهدفة.',
    'Discharge Note & Disposition': 'ملاحظة التخريج والوجهة',
    'Hypertensive Urgency — Resolved. Essential Hypertension Stage 2.': 'ارتفاع ضغط الدم العاجل — زالت الحالة. ارتفاع ضغط الدم الأساسي، المرحلة الثانية.',
    'Stable, Afebrile, Normotensive on Oral Regimen':
        'الحالة مستقرة، دون حمى، وضغط الدم طبيعي مع العلاج الفموي.',
    '1. Continue Amlodipine 5mg PO daily at 08:00.\n2. Low sodium diet (<2g/day) & daily BP logging.\n3. Return to Cardiology Clinic in 10 days for follow-up.\n4. Seek ER immediately if severe headache or chest tightness recurs.': '1. الاستمرار بتناول أملوديبين 5 ملغ عن طريق الفم يومياً الساعة 08:00.\n2. اتباع حمية قليلة الصوديوم (أقل من 2 غرام يومياً) وتسجيل ضغط الدم يومياً.\n3. مراجعة عيادة القلب بعد 10 أيام للمتابعة.\n4. مراجعة الطوارئ فوراً إذا عاد الصداع الشديد أو ضيق الصدر.',
    'Signed & Finalized': 'موقعة ومعتمدة',
    'Draft / Pending Review': 'مسودة / قيد المراجعة',
    'Author & Sign Discharge Note': 'تحرير وتوقيع ملاحظة التخريج',
    'Edit / View Discharge Note': 'تعديل / عرض ملاحظة التخريج',
    'Active Orders for Verification': 'الوصفات الجارية للتدقيق',
    'Order Rx': 'إضافة وصفة',
    'Confirm & Save Orders': 'تأكيد وحفظ الأوامر السريرية',
    'Upcoming Patients Queue': 'قائمة المرضى القادمين',
    'Attending Physician': 'طبيب استشاري / اختصاصي',
    'CLINICAL CREDENTIALS': 'البيانات والاعتمادات المهنية',
    'Sign Out of Doctor Portal': 'تسجيل الخروج من بوابة الأطباء',
    'Change Nurse': 'تغيير الممرضة',
    'Assigned Nurse': 'الممرضة المعينة',
    'Transfer Patient': 'نقل المريض',
    'Next Patient': 'المريض التالي',
    'Edit Clinical Assessment': 'تعديل التقييم السريري',
    'Save & Next Patient': 'حفظ والانتقال للمريض التالي',
    '6 Patients': '6 مرضى',
    'Shift Progress: 38%': 'تقدم الوردية: 38%',
    'All (8)': 'الكل (8)',
    'In Consultation (1)': 'قيد الاستشارة (1)',
    'Upcoming (5)': 'القادمون (5)',
    'Completed (2)': 'المكتملون (2)',

    // Doctor Portal Redesign & Clinical Terminology
    'Doctor Dashboard & Clinical Overview': 'لوحة تحكم الطبيب والنظرة السريرية',
    'Total Patients Today': 'إجمالي المرضى اليوم',
    'Pending Lab Results': 'نتائج مختبرية معلقة',
    'Unsigned SOAP Notes': 'ملاحظات سريرية غير موقعة',
    'High Acuity / Critical': 'حالات حرجة عالية الخطورة',
    'Critical': 'حرج',
    'Urgent': 'عاجل',
    'Routine': 'روتيني',
    'Waiting': 'في الانتظار',
    'In-Consultation': 'قيد المعاينة',
    'Emergency Clinical Alert': 'تنبيه سريري طارئ',
    'Emergency Alert': 'تنبيه طارئ',
    'Patient Clinical File & EMR': 'الملف السريري والسجل الطبي',
    'Active Allergies': 'الحساسية النشطة',
    'Critical Alerts': 'تنبيهات حرجة',
    'Clinical History Timeline': 'الجدول الزمني للتاريخ السريري',
    'Diagnostic & Lab Viewer': 'الفحوصات المخبرية والتشخيصية',
    'SOAP Clinical Notes': 'التوثيق السريري SOAP',
    'Subjective': 'الأعراض والشكوى (Subjective)',
    'Objective': 'الفحص والمؤشرات (Objective)',
    'Assessment': 'التشخيص الطبي (Assessment)',
    'Plan': 'الخطة العلاجية (Plan)',
    'Medical Diagnosis': 'التشخيص الطبي',
    'Treatment Plan': 'الخطة العلاجية',
    'Lab Tests': 'الفحوصات المخبرية',
    'Medical Prescription': 'التذكرة الطبية',
    'Quick Insert Diagnostic Chips': 'إدراج سريع للمصطلحات التشخيصية',
    'Encounter Mode': 'نمط المعاينة',
    'In-Person Bedside': 'سريري / حضوري',
    'Telehealth Video': 'استشارة عن بُعد',
    'Order Pad': 'لوحة الأوامر السريرية',
    'Quick Order Pad': 'لوحة الطلبات السريعة',
    'Order Lab Test': 'طلب فحص مخبري',
    'Order Radiology': 'طلب أشعة وسونار',
    'Drug Safety & Interaction Alert': 'تنبيه التداخلات الدوائية والسلامة',
    'Drug-Drug Interaction Warning': 'تحذير تداخل دوائي',
    'Patient Allergy Conflict': 'تعارض مع حساسية المريض',
    'Severe Allergy Warning': 'تحذير حساسية شديدة',

    // Beds & Wards
    'MAIN INPATIENT COMPLEX': 'مجمع المرضى الراقدين العام',
    'Ward Inpatient Operations': 'عمليات الردهات والأسرة',
    'Floors A, B, C • Bed Allocation & Transfer Hub':
        'الطوابق أ، ب، ج • مركز توزيع ونقل الأسرة',
    'Floor A': 'الطابق أ',
    'Floor B': 'الطابق ب',
    'Floor C': 'الطابق ج',
    'All Floors': 'جميع الطوابق',
    'Available': 'متاح',
    'Occupied': 'مشغول',
    'Patient Load': 'حمل المريض',
    'Staff On Floor': 'الطاقم في الطابق',
    'Filter Beds': 'فلترة وتصفية الأسرة',
    'Transfer Room': 'نقل إلى غرفة أخرى',
    'TRIAGE ACTION REQUIRED': 'إجراء فرز مطلوب عاجل',
    'Approve Transfer': 'الموافقة على النقل',
    'Defer': 'تأجيل',
    'Capacity': 'السعة',
    'Total': 'الإجمالي',
    'Beds': 'أسرة',
    'Ready': 'جاهز',
    'Pending': 'معلق',
    'Reserve': 'حجز',
    'Transfer': 'نقل',
    'All States': 'جميع الحالات',
    '🟢 Available Only': '🟢 المتاحة فقط',
    '🔴 Occupied Only': '🔴 المشغولة فقط',

    // Staff
    'MORNING SHIFT • 07:00 - 15:00': 'الوردية الصباحية • 07:00 - 15:00',
    'Floor Nursing Roster': 'جدول كادر التمريض للطوابق',
    'Floor 3 & 4 Nursing Roster': 'جدول تمريض الطابقين 3 و 4',
    'On Duty': 'في الخدمة',
    'Active Floor': 'الطابق النشط',
    'On Break': 'في استراحة',
    'Handover': 'تسليم واستلام',
    '+ Assign to Patient': '+ تعيين لمريض',
    '+ Assign': '+ تعيين',
    'Broadcast Alert to On-Duty Nurses': 'إرسال نداء عاجل لكادر التمريض',
    'Live Sync': 'مزامنة مباشرة',
    'Search nurse, bed, or skill...': 'بحث عن ممرض، سرير أو مهارة...',
    'Available to Assign': 'متاح للتعيين',
    'On Floor': 'في الردهة',
    'High Load': 'حمل مرتفع',
    'Optimal Availability': 'جاهزية مثالية',
    'My Assigned Patient Pairs': 'المرضى المعينين لي',
    'Charge Nurse': 'مسؤول الوردية',
    'Ward Shift Supervisor • Extension #4301':
        'مشرف وردية الردهة • تحويلة #4301',
    'Filter Staff Roster': 'تصفية جدول الكادر',
    'All Load States': 'جميع أحمال العمل',
    '🟢 Available': '🟢 متاح',
    '🔴 High Load': '🔴 حمل مرتفع',

    // Nurse Portal
    'NURSE BEDSIDE & DISPENSARY PORTAL': 'بوابة التمريض والصيدلية السريرية',
    '• Morning Shift (Ward 3)': '• الوردية الصباحية (ردهة 3)',
    'Rounds': 'جولات تمريضية',
    'Nurse Rounds': 'جولات تمريضية',
    'Pharmacy': 'إدارة الأدوية',
    'Pharmacy & Medication': 'إدارة الأدوية',
    'Medication Management': 'إدارة الأدوية',
    'Transfer / Handover': 'تسليم الشفت',
    'Shift Handover': 'تسليم الشفت',
    'Round 2 of 4': 'الجولة 2 من 4',
    '6 of 10 completed (60%)': '6 من 10 مكتملة (60%)',
    'ACTIVE BEDSIDE CARE': 'الرعاية السريرية الفعالة',
    'Round Timer: 08:24': 'مؤقت الجولة: 08:24',
    'Log Bedside Vitals': 'تسجيل المؤشرات الحيوية',
    'UPCOMING IN THIS ROUND': 'القادمون في هذه الجولة',
    '2 Beds Remaining': 'سريران متبقيان',
    'CLINICAL SHORTCUTS': 'اختصارات سريرية سريعة',
    'Scan\nWristband': 'مسح\nالسوار',
    'Call\nAttending': 'اتصال\nبالطبيب',
    'Ward\nIncident': 'بلاغ\nحادثة',
    'Ward 3 Satellite Dispensary': 'صيدلية الردهة 3 المؤتمتة',
    'Automated Hub Active': 'المركز المؤتمت نشط',
    'Pneumatic Tube Online': 'الأنبوب الهوائي متصل',
    'SHIFT DISPENSING VELOCITY': 'حركة صرف الأدوية في الوردية',
    'Ward Med Dispenser Units': 'وحدات صرف أدوية الردهة',
    'Orders Pending Clearance': 'وصفات قيد موافقة الصيدلي',
    'Sign Out of Nurse Portal': 'تسجيل الخروج من بوابة التمريض',
    'Bedside Medication Administration': 'إدارة وتوزيع الأدوية السريرية',
    'Patient Queue & Medication Administration': 'قائمة المرضى وإدارة الأدوية',
    'Patient Selection & Medication View': 'اختيار المريض والأوامر الدوائية',
    'Active Medication Orders': 'الأوامر الدوائية النشطة',
    'Prescription Details': 'تفاصيل الوصفة الطبية',
    'Select Prescribed Medications': 'تحديد الأدوية الموصوفة',
    'Pick, Confirm & Transfer': 'انتقاء، تأكيد وتسليم',
    'Confirm & Save': 'تأكيد وحفظ',
    'Confirm & Administer': 'تأكيد وإعطاء الدواء',
    'Transfer to Next Shift': 'تسليم للوردية التالية',
    'Overdue': 'متأخر',
    'Upcoming': 'قادم',
    'Completed': 'مكتمل',
    'In Progress': 'قيد الإجراء',
    'Scheduled': 'مجدول',
    'Select All': 'تحديد الكل',
    'Deselect All': 'إلغاء التحديد',
    'Scheduled Clinical Rounds': 'الجولات السريرية المجدولة',
    'Clinical Rounds Timeline': 'الجدول الزمني للجولات السريرية',
    'Mark as Completed': 'تعيين كمكتمل',
    'Quick Status Toggle': 'تغيير الحالة السريع',
    'Vitals Recorded': 'تم تسجيل المؤشرات',
    'Bedside Care Queue': 'قائمة الرعاية السريرية',
    'All Patients Processed': 'تمت معالجة جميع المرضى',
    'Reset Patient Queue': 'إعادة تعيين القائمة',
    'Overdue Rounds': 'جولات متأخرة',
    'Upcoming Rounds': 'جولات قادمة',
    'Completed Rounds': 'جولات مكتملة',
    'Administer': 'إعطاء الدواء',
    'Administered ✓': 'تم الإعطاء ✓',
    'Start Round': 'بدء الجولة',
    'Review eMAR': 'مراجعة السجل الدوائي',

    // Controls
    'Theme': 'المظهر',
    'Dark Mode': 'الوضع الداكن',
    'Light Mode': 'الوضع الفاتح',
    'Language': 'اللغة',
    'English': 'الإنجليزية',
    'Arabic': 'العربية',
    'APP PREFERENCES & LOCALIZATION': 'تفضيلات التطبيق واللغة',
    'Display Theme': 'مظهر الشاشة',
    'Portal Language': 'لغة البوابة السريرية',

    // Actions & Dialogs
    'Cancel': 'إلغاء',
    'Close': 'إغلاق',
    'Save': 'حفظ',
    'Confirm': 'تأكيد',
    'Delete': 'حذف',
    'Edit': 'تعديل',
    'Assign': 'تعيين',
    'Submit': 'إرسال',
    'Sign & Finalize Note': 'توقيع واعتماد الملاحظة',
    'Direct Admit': 'دخول مباشر',
    'Shift / Transfer': 'نقل وردية',
    'Ward Team': 'فريق الردهة',
    'Emergency Ward Alert': 'تنبيه طوارئ الردهة',
    'Code Blue (Cardiac Arrest)': 'نداء أزرق (إنعاش قلبي)',
    'Rapid Response / STAT Consultation': 'فريق الاستجابة السريعة',
    'Blood Pressure': 'ضغط الدم',
    'Pulse': 'نبض القلب',
    'SpO2 (Pulse Ox)': 'نسبة الأكسجين',
    'Temperature': 'درجة الحرارة',
    'All Beds (10)': 'جميع الأسرة (10)',
    'Pending Vitals (2)': 'مؤشرات معلقة (2)',
    'Due Meds (1)': 'أدوية مستحقة (1)',
    'All Medications': 'جميع الأدوية',
    'IV Solutions': 'محاليل وريدية',
    'Oral Antibiotics': 'مضادات فموية',

    // Doctors
    'Dr. Ahmed Al-Saadi': 'د. أحمد الساعدي',
    'Dr. Zaid Al-Husseini': 'د. زيد الحسيني',
    'Dr. Ahmed': 'د. أحمد',
    'Dr. Sarah': 'د. سارة',
    'Dr. Tariq': 'د. طارق',
    'Level 4 Sign-Off (Full Rx Authority)':
        'اعتماد المستوى 4 (صلاحية كاملة للوصفات)',
    'Cardiology & Clinical Inpatients': 'أمراض القلب والمرضى الراقدين',
    'Active Doctor Session': 'جلسة الطبيب النشطة',

    // Nurses
    'Nurse Fatima Ali, RN': 'الممرضة فاطمة علي',
    'Fatima Ali, RN': 'فاطمة علي',
    'Nurse Sarah Kareem, BSN': 'الممرضة سارة كريم',
    'Sarah Kareem, BSN': 'سارة كريم',
    'Sarah Kareem, RN': 'سارة كريم',
    'Nurse Sarah': 'الممرضة سارة',
    'Nurse Noor Al-Hassan, RN': 'الممرضة نور الحسن',
    'Noor Al-Hassan, RN': 'نور الحسن',
    'Nurse Zainab Omran, RN': 'الممرضة زينب عمران',
    'Zainab Omran, RN': 'زينب عمران',
    'Omar Kareem, RN': 'عمر كريم',
    'Hussein Tariq, RN': 'حسين طارق',
    'Lead Nurse • Acute Ward 1': 'المسؤول التمريضي • ردهة الطوارئ 1',
    'Floor Float • Ward 1': 'تمريض متحرك • ردهة 1',
    'Observation Lead • Ward 2': 'مسؤول الملاحظة • ردهة 2',
    'Staff Nurse • Ward 2': 'ممرض سريري • ردهة 2',
    'ICU Step-down Specialist': 'اختصاصي عناية مركزة',
    'Night Cover • Ward 3': 'تغطية ليلية • ردهة 3',
    'Assigned Ward Nurse': 'ممرضة الردهة المعينة',
    'Floor Lead': 'مسؤولة الطابق',
    'ICU Float': 'متحرك العناية المركزة',
    'Ward 4 - Bedside Monitoring & ICU':
        'ردهة 4 - المراقبة السريرية والعناية المركزة',

    // Patients
    'Ahmed Tariq': 'أحمد طارق',
    'Mariam Al-Saadi': 'مريم الساعدي',
    'Mariam Hassan': 'مريم حسن',
    'Hussein K.': 'حسين ك.',
    'Zainab Omran': 'زينب عمران',
    'Zainab Noor': 'زينب نور',
    'Hassan J. Al-Rubaie': 'حسن ج. الربيعي',
    'Layla Abbas': 'ليلى عباس',
    'Omar Kareem': 'عمر كريم',
    'Omar Farooq': 'عمر فاروق',
    'Mustafa Saad': 'مصطفى سعد',
    'Available Bed': 'سرير متاح',
    'Room 304 • Bed A': 'غرفة 304 • سرير A',
    'Room 306 • Bed B': 'غرفة 306 • سرير B',
    'Room 304 • Bed B': 'غرفة 304 • سرير B',
    'Room 301 • Bed A': 'غرفة 301 • سرير A',
    'Bedside Round': 'جولة سريرية',

    // Doctor Patient Encounter
    'Active': 'نشط',
    'Assign to Active Patient': 'تعيين للمريض النشط',
    'Assigned to Patient': 'معين للمريض',
    'Calling {name} ({ext})...': 'جارٍ الاتصال بـ {name} ({ext})...',
    'Care Team & Floor Nurses': 'فريق الرعاية وممرضو الردهة',
    'Click avatar to view full patient dossier':
        'انقر على الصورة لعرض الملف الطبي الكامل للمريض',
    'Collapse Inspector': 'طي لوحة التفاصيل',
    'Contact Nurse': 'الاتصال بالممرضة',
    'Dossier ›': 'الملف الطبي ›',
    'Expand Inspector': 'توسيع لوحة التفاصيل',
    'Inpatients': 'المرضى الراقدون',
    'Instructions': 'التعليمات',
    'Open Full Slide-Over Dossier': 'فتح الملف الطبي الكامل',
    'Order Lab Test: CBC, Electrolytes & Cardiac Enzymes requested.':
        'تم طلب فحص تعداد الدم الكامل والشوارد وإنزيمات القلب.',
    'Order Radiology: Chest X-Ray & Echo requested.':
        'تم طلب تصوير الصدر بالأشعة السينية وتخطيط صدى القلب.',
    'Order Verification Status': 'حالة التحقق من الطلبات',
    'Save Assessment': 'حفظ التقييم',
    'Set as Active Patient Encounter': 'تعيين كمقابلة المريض النشطة',
    'Switched active encounter to': 'تم تغيير المقابلة النشطة إلى',
    'Tap to view': 'اضغط للعرض',
    'Update clinical findings and diagnostic plan for':
        'تحديث النتائج السريرية والخطة التشخيصية للمريض',

    // Rooms & Beds
    'Room 101': 'غرفة 101',
    'Room 102': 'غرفة 102',
    'Room 201': 'غرفة 201',
    'Room 202': 'غرفة 202',
    'Room 301': 'غرفة 301',
    'Room 302': 'غرفة 302',
    'Room 304': 'غرفة 304',
    'Room 305': 'غرفة 305',
    'Room 306': 'غرفة 306',
    'Room 310': 'غرفة 310',
    'Bed 101-A': 'سرير 101-A',
    'Bed 101-B': 'سرير 101-B',
    'Bed 102-A': 'سرير 102-A',
    'Bed 102-B': 'سرير 102-B',
    'Bed 103-A': 'سرير 103-A',
    'Bed 201-A': 'سرير 201-A',
    'Bed 201-B': 'سرير 201-B',
    'Bed 202-A': 'سرير 202-A',
    'Bed 202-B': 'سرير 202-B',
    'Bed 301-A': 'سرير 301-A',
    'Bed 301-B': 'سرير 301-B',
    'Bed 302-A': 'سرير 302-A',
    'Bed 302-B': 'سرير 302-B',
    'Bed 304-A': 'سرير 304-A',
    'Bed 304-B': 'سرير 304-B',
    'Bed 305-B': 'سرير 305-B',
    'Bed 306-B': 'سرير 306-B',
    'Bed 310-C': 'سرير 310-C',

    // Clinical Tags & Badges
    'Telemetry': 'مراقبة حيوية',
    'Wall O2 Ready': 'أكسجين جداري جاهز',
    'Post-Op': 'بعد العملية',
    'Sanitized': 'معقم وجاهز',
    'Ward 3B': 'ردهة 3B',
    'Tele-ready': 'جاهز للمراقبة',
    'Adult Bed': 'سرير بالغين',
    'IV Infusing': 'حقن وريدي جاري',
    'Drain Monitored': 'مراقبة المفجر',
    'ICU Step-down': 'تحويل العناية المركزة',
    'Ventilator Ready': 'جهاز تنفس جاهز',
    'Post-op review': 'متابعة بعد العملية',
    'Diabetic Check': 'فحص السكري',
    'Observation': 'ملاحظة سريرية',
    'Needs Vitals': 'بانتظار المؤشرات',
    'Stat Med Due': 'دواء عاجل مستحق',
    'Stable': 'مستقر',
    'Auto-Reordered': 'طلب تلقائي',
    'Optimal': 'مثالي',
    'Normal': 'طبيعي',
    '3/5 (Moderate)': '3/5 (متوسط)',
    '5/5 (Max)': '5/5 (أقصى)',
    '2/5 (Light)': '2/5 (خفيف)',
    '4/5 (Moderate)': '4/5 (متوسط)',
    '1/5 (Light)': '1/5 (خفيف)',

    // Dialog & Action Strings
    'Current Bed': 'السرير الحالي',
    'Target Bed': 'السرير الهدف',
    'Select target bed for transfer': 'اختر السرير المطلوب للنقل إليه',
    'Confirm Transfer': 'تأكيد النقل',
    'Patient transferred successfully': 'تم نقل المريض بنجاح',
    'Bed reserved': 'تم حجز السرير',
    'Assign Nurse to Patient': 'تعيين ممرضة لمريض',
    'Select Patient to Assign': 'اختر المريض للتعيين',
    'Confirm Assignment': 'تأكيد التعيين',
    'Assigned successfully': 'تم التعيين بنجاح',
    'Contact Staff Nurse': 'الاتصال بممرض الردهة',
    'Direct Ward Call': 'اتصال مباشر بالردهة',
    'Send Priority Message': 'إرسال رسالة عاجلة',
    'Call': 'اتصال',
    'Send': 'إرسال',
    'Calling': 'جارٍ الاتصال بـ',
    'Message sent to': 'تم إرسال الرسالة إلى',
    'Alert broadcasted to all on-duty nurses':
        'تم إرسال النداء إلى جميع الممرضين في الخدمة',
    'Bedside vitals recorded and logged to hospital EHR.':
        'تم تسجيل المؤشرات الحيوية وحفظها في السجل الطبي.',
    'Confirm Vitals': 'تأكيد المؤشرات الحيوية',
    'Clinical Assessment updated.': 'تم تحديث التقييم السريري.',
    'Nurse assigned': 'تم تعيين الممرضة',
    'Patient': 'المريض',
    'Discharge Primary Diagnosis': 'التشخيص الأولي للتخريج',
    'Condition on Discharge': 'حالة المريض عند الخروج',
    'Disposition / Destination': 'وجهة الخروج / المكان',
    'Home with Outpatient Follow-up': 'المنزل مع متابعة خارجية',
    'Transfer to Step-Down Ward': 'نقل إلى ردهة انتقالية',
    'Rehabilitation Center': 'مركز إعادة التأهيل',
    'Post-Discharge Instructions & Follow-up': 'التعليمات بعد الخروج والمتابعة',
    'Discharge summary note signed & transmitted to Ward Team.':
        'تم توقيع وتوصيل ملحوظة التخريج لفريق الردهة.',
    'Medication & Strength': 'الدواء والجرعة',
    'Dosage, Route & Frequency': 'الجرعة والطريقة والتكرار',
    'Order Status': 'حالة الطلب',
    'Verified': 'مؤكد',
    'New Dose': 'جرعة جديدة',
    'Active Order': 'طلب نشط',
    'Pending Review': 'قيد المراجعة',
    'Prescription removed.': 'تم حذف الوصفة.',
    'Prescription updated successfully.': 'تم تحديث الوصفة بنجاح.',
    'Save Order': 'حفظ الطلب',
    'Orders confirmed & transferred to Nurse Portal. Switched to next patient:': 'تم تأكيد الطلبات ونقلها إلى بوابة الممرضين. تم التحويل إلى المريض التالي:',
    'Notifications — active shift online.': 'الإشعارات — الوردية النشطة متصلة.',
    'Edit Assessment': 'تعديل التقييم',
    'Diagnosis': 'التشخيص',
    'Condition': 'الحالة',
    'Disposition': 'وجهة الخروج',
    'Remaining': 'المتبقي',
    'New Doctor Order': 'طلب طبي جديد',
    'Edit Prescription': 'تعديل الوصفة',
    'Discharge Note Finalized & Signed': 'تم اعتماد وتوقيع ملاحظة التخريج',
    'Orders transferred to Central Dispensary. Proceeding to next patient.':
        'تم تحويل الأوامر إلى الصيدلية المركزية والانتقال للمريض التالي.',
    'All inpatient encounters completed for this shift.':
        'تمت معاينة جميع المرضى الراقدين لهذه الوردية.',
    'Pneumatic Pod delivered to Bed 310-C.':
        'تم تسليم الكبسولة إلى السرير 310-C.',
    'Restock request dispatched to Central Pharmacy.':
        'تم إرسال طلب إعادة التعبئة إلى الصيدلية المركزية.',
    'Order brought to bedside and administered.':
        'تم جلب الوصفة للسرير وإعطاؤها للمريض.',
    'Dispensary unit vended': 'تم صرف الدواء من الوحدة',
    'Email': 'البريد الإلكتروني',
  };
}

/// Global convenience function to translate any text key
String tr(String key) => AppSettingsService().tr(key);
