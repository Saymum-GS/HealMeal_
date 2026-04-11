import 'package:shared_preferences/shared_preferences.dart';

import 'app_role.dart';

class AppSession {
  AppSession._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isReady => _prefs != null;

  static bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;

  static AppRole get currentUserRole =>
      AppRole.fromStorage(_prefs?.getString('user_role'));

  static String get roleId => currentUserRole.id;

  static String? get phone => _prefs?.getString('user_phone');

  static Future<void> persistLogin({
    required AppRole role,
    required String phone,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', role.id);
    await prefs.setString('user_phone', phone);
  }

  static Future<void> clear() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.remove('is_logged_in');
    await prefs.remove('user_role');
    await prefs.remove('user_phone');
  }

  static String homeRouteForRole(AppRole role) {
    return role.homeRoute;
  }
}
