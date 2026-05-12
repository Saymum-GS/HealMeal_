import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';

class AppSession {
  AppSession._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isReady => _prefs != null;

  static bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;

  static UserRole get currentUserRole {
    final raw = _prefs?.getString('user_role');
    switch (raw) {
      case 'patient':
      case 'user':
        return UserRole.patient;
      case 'pharmacist':
        return UserRole.pharmacist;
      case 'rider':
        return UserRole.rider;
      case 'admin':
        return UserRole.admin;
      case 'labTech':
      case 'lab_tech':
        return UserRole.labTech;
      case 'business':
        return UserRole.business;
      default:
        return UserRole.patient;
    }
  }

  static String get roleId => currentUserRole.id;

  static String? get phone => _prefs?.getString('user_phone');

  static String? get userId => _prefs?.getString('user_id');

  static Future<void> persistLogin({
    required UserRole role,
    required String phone,
    required String userId,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', role.id);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_id', userId);
  }

  static Future<void> clear() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.remove('is_logged_in');
    await prefs.remove('user_role');
    await prefs.remove('user_phone');
    await prefs.remove('user_id');
  }

  static String homeRouteForRole(UserRole role) {
    return role.homeRoute;
  }
}
