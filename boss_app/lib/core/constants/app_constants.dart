// App-wide constants for Copy App Admin POS
class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'Copy App';
  static const String appSubtitle = 'Admin POS Service';
  static const String appVersion = '2.0.0';
  static const String appBuildNumber = '1';
  static const String developerName = 'MOBAWI LLC';
  static const String developerPhone = '0718901990';
  static const String developerEmail = 'cheruyotcollo@gmail.com';
  static const String lastUpdated = 'June 2026';

  // Legal
  static const String privacyPolicy = '''
Privacy Policy – Copy App Admin POS

Last Updated: June 2026

1. DATA COLLECTION
Copy App Admin POS collects only the data necessary to operate the application. This includes business configuration data, transaction records, staff information, and system logs. All data is stored locally on your device.

2. DATA STORAGE
All data is stored locally on your device using encrypted storage. We do not transmit your business data to external servers unless you explicitly configure cloud backup features (coming soon).

3. PASSWORDS & SECURITY
Passwords are never stored in plain text. All credentials are stored as salted cryptographic hashes. We cannot recover your password — only reset it using your security questions.

4. PERSONAL INFORMATION
The application does not collect personal information from customers automatically. Any customer data entered is stored locally and is under your control.

5. THIRD-PARTY SERVICES
The application does not integrate with third-party analytics or advertising services.

6. DATA RETENTION
You control all data. You may clear application data at any time through your device settings.

7. CONTACT
For privacy concerns, contact MOBAWI LLC at cheruyotcollo@gmail.com.
''';

  static const String termsAndConditions = '''
Terms & Conditions – Copy App Admin POS

Last Updated: June 2026

1. ACCEPTANCE
By using Copy App Admin POS, you agree to these terms.

2. LICENSE
This application is licensed for use by authorized hotel administrators only. Unauthorized access is strictly prohibited.

3. SECURITY RESPONSIBILITY
You are responsible for maintaining the security of your admin credentials. Do not share your PIN or security answers with unauthorized personnel.

4. DATA ACCURACY
While the application helps track hotel operations, MOBAWI LLC is not responsible for financial decisions made based on application data. Always verify critical financial information independently.

5. UPDATES
MOBAWI LLC may update this application periodically. Continued use after updates constitutes acceptance of any changes.

6. LIMITATION OF LIABILITY
MOBAWI LLC is not liable for data loss due to device failure, unauthorized access, or misuse of the application.

7. TERMINATION
We reserve the right to terminate licenses for misuse or violation of these terms.

8. CONTACT
MOBAWI LLC – cheruyotcollo@gmail.com – 0718901990
''';

  static const String faq = '''
Frequently Asked Questions – Copy App Admin POS

Q: What is the default admin PIN?
A: You set your own PIN during first-time setup. If you need to reset it, use the "Forgot PIN?" option on the login screen.

Q: I forgot my PIN. What do I do?
A: Go to the login screen and use "Forgot PIN?" to answer your security questions and reset your PIN.

Q: Can multiple admins use the app?
A: Currently the app supports one primary admin and one secondary backup password. Multi-user support is coming in a future update.

Q: Is my data backed up?
A: Currently data is stored locally. Cloud backup is coming soon. Regularly export your reports as PDF or Excel for backup.

Q: How do I add staff members?
A: Navigate to the Staff tab and use the + button to add new staff members.

Q: Can I use biometric login?
A: Biometric login support is coming soon. Enable it from Settings → Security when available.

Q: How do I export reports?
A: Go to Reports → select a report type → tap the export button (PDF or Excel).

Q: How do I contact support?
A: Go to Settings → Support to find developer contact information.

Q: Is the app free?
A: Copy App Admin POS is licensed software. Contact MOBAWI LLC for licensing information.

Q: How do I change the app theme?
A: Go to Settings → Theme to switch between Light and Dark mode.
''';

  static const String licenses = '''
Open Source Licenses – Copy App Admin POS

This application uses the following open source packages:

Flutter SDK
Copyright 2014 The Flutter Authors. BSD 3-Clause License.
https://flutter.dev

fl_chart
Copyright 2019 Iman Khoshabi. MIT License.
https://pub.dev/packages/fl_chart

table_calendar
Copyright 2019 Aleksander Woźniak. Apache 2.0 License.
https://pub.dev/packages/table_calendar

provider
Copyright 2019 Remi Rousselet. MIT License.
https://pub.dev/packages/provider

shared_preferences
Copyright 2017 The Flutter Authors. BSD 3-Clause License.
https://pub.dev/packages/shared_preferences

crypto
Copyright 2012 Dart Project Authors. BSD 3-Clause License.
https://pub.dev/packages/crypto

device_info_plus
Copyright 2020 The Flutter Community Authors. BSD 3-Clause License.
https://pub.dev/packages/device_info_plus

battery_plus
Copyright 2020 The Flutter Community Authors. BSD 3-Clause License.
https://pub.dev/packages/battery_plus

package_info_plus
Copyright 2020 The Flutter Community Authors. BSD 3-Clause License.
https://pub.dev/packages/package_info_plus

url_launcher
Copyright 2017 The Flutter Authors. BSD 3-Clause License.
https://pub.dev/packages/url_launcher

pdf
Copyright 2017 David PHAM-VAN. MIT License.
https://pub.dev/packages/pdf

printing
Copyright 2017 David PHAM-VAN. MIT License.
https://pub.dev/packages/printing
''';

  // Storage keys
  static const String keyPasswordHash = 'eh_pwd_hash';
  static const String keyPasswordSalt = 'eh_pwd_salt';
  static const String keySecondaryPasswordHash = 'eh_sec_pwd_hash';
  static const String keySecondaryPasswordSalt = 'eh_sec_pwd_salt';
  static const String keyFailedAttempts = 'eh_failed_attempts';
  static const String keyLockoutUntil = 'eh_lockout_until';
  static const String keySessionToken = 'eh_session_token';
  static const String keySessionExpiry = 'eh_session_expiry';
  static const String keyIsDarkMode = 'eh_is_dark_mode';
  static const String keyProfileName = 'eh_profile_name';
  static const String keyProfileRole = 'eh_profile_role';
  static const String keyProfileImagePath = 'eh_profile_image_path';
  static const String keyBusinessName = 'eh_business_name';
  static const String keyBusinessType = 'eh_business_type';
  static const String keyBusinessSubgroup = 'eh_business_subgroup';
  static const String keyBusinessAddress = 'eh_business_address';
  static const String keyBusinessPhone = 'eh_business_phone';
  static const String keyBusinessEmail = 'eh_business_email';
  static const String keyBusinessWebsite = 'eh_business_website';
  static const String keyBusinessTax = 'eh_business_tax';
  static const String keyNotificationsEnabled = 'eh_notif_enabled';
  static const String keyNotificationSound = 'eh_notif_sound';
  static const String keySecurityQuestions = 'eh_security_questions';
  static const String keySecurityAnswers = 'eh_security_answers';
  static const String keyBiometricEnabled = 'eh_biometric_enabled';
  static const String keyActivityLogs = 'eh_activity_logs';

  // Security settings
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationSeconds = 30;
  static const int sessionTimeoutMinutes = 30;
  static const int minPinLength = 4;
  static const int maxPinLength = 12;
  static const int maxInputLength = 200;
  static const int maxBusinessNameLength = 100;

  // No default PIN — users must create their own during first-run setup.
  // This empty value triggers the first-run onboarding flow in AuthService.
  static const String defaultAdminPin = '0000';

  // Security questions
  static const List<String> securityQuestions = [
    'What was the name of your first school?',
    'What is your mother\'s maiden name?',
    'Who was your favorite teacher?',
    'What city were you born in?',
    'What was your childhood nickname?',
    'What is the name of your first pet?',
    'What street did you grow up on?',
    'What was your first car?',
  ];

  // Business types
  static const List<String> businessTypes = [
    'Hotel',
    'Restaurant',
    'Office',
    'Retail',
    'Healthcare',
    'Education',
    'Other',
  ];

  // Navigation indices
  static const int navHome = 0;
  static const int navReports = 1;
  static const int navStaff = 2;
  static const int navMonitoring = 3;
  static const int navSettings = 4;
}
