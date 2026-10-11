// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 16: main() -> Application entry point; boots the app with HmsApp.
// - Line 24: HmsApp.build() -> Builds the root MaterialApp reacting to AuthService state changes.
// - Line 39: HmsApp._resolveHomeScreen() -> Determines initial screen (WelcomeScreen, DoctorPortalScaffold, NursePortalScaffold) by role.
// ============================================================================

import 'package:flutter/material.dart';
import 'core/translate/localizations/app_localizations.dart';
import 'models/user_model.dart';
import 'screens/doctor/doctor_portal_scaffold.dart';
import 'screens/nurse/nurse_portal_scaffold.dart';
import 'screens/welcome_screen.dart';
import 'services/app_settings_service.dart';
import 'services/auth_service.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const HmsApp());
}

typedef BaghdadMedicalCityApp = HmsApp;

class HmsApp extends StatelessWidget {
  const HmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AuthService(), AppSettingsService()]),
      builder: (context, _) {
        final auth = AuthService();
        final settings = AppSettingsService();

        return MaterialApp(
          title: 'H . M . S',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          locale: settings.currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return Directionality(
              textDirection: settings.textDirection,
              child: child ?? const SizedBox(),
            );
          },
          home: _resolveHomeScreen(auth),
        );
      },
    );
  }

  Widget _resolveHomeScreen(AuthService auth) {
    if (!auth.isAuthenticated) {
      return const WelcomeScreen();
    }
    if (auth.currentUser?.role == UserRole.doctor) {
      return const DoctorPortalScaffold();
    } else {
      return const NursePortalScaffold();
    }
  }
}
