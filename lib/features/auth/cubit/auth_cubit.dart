import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_role.dart';
import '../../../core/utils/app_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial()) {
    restoreSession();
  }

  AppRole _selectedRole = AppRole.user;

  AppRole get currentUserRole => _selectedRole;

  Future<void> restoreSession() async {
    if (AppSession.isLoggedIn) {
      _selectedRole = AppSession.currentUserRole;
      emit(AuthAuthenticated(role: _selectedRole));
      return;
    }
    emit(const AuthUnauthenticated());
  }

  void setRole(AppRole role) {
    _selectedRole = role;
  }

  Future<void> sendOtp(String phone) async {
    emit(const OtpSending());
    await Future<void>.delayed(const Duration(seconds: 1));
    emit(OtpSent(phone: phone));
  }

  Future<void> verifyOtp(String phone, String otp) async {
    emit(const OtpVerifying());
    await Future<void>.delayed(const Duration(seconds: 2));
    if (otp.length == 6) {
      await AppSession.persistLogin(role: _selectedRole, phone: phone);
      emit(AuthAuthenticated(role: _selectedRole));
    } else {
      emit(const OtpError(message: 'Invalid OTP. Try 123456 for demo.'));
    }
  }

  Future<void> logout() async {
    await AppSession.clear();
    emit(const AuthUnauthenticated());
  }
}
