import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  AppSession._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isReady => _prefs != null;

  static bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;

  static String get role => _prefs?.getString('user_role') ?? 'patient';

  static String? get phone => _prefs?.getString('user_phone');

  static Future<void> persistLogin({
    required String role,
    required String phone,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', role);
    await prefs.setString('user_phone', phone);
  }

  static Future<void> clear() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.remove('is_logged_in');
    await prefs.remove('user_role');
    await prefs.remove('user_phone');
  }

  static String homeRouteForRole(String role) {
    switch (role) {
      case 'pharmacist':
        return '/pharmacist';
      case 'rider':
        return '/rider';
      case 'admin':
        return '/admin';
      case 'lab_tech':
        return '/lab-tech';
      case 'business':
        return '/account/business';
      default:
        return '/home';
    }
  }
}
