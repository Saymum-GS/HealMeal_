import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  String _selectedRole = 'patient';

  String get selectedRole => _selectedRole;

  void setRole(String role) {
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
      emit(Authenticated(role: _selectedRole));
    } else {
      emit(const OtpError(message: 'Invalid OTP. Try 123456 for demo.'));
    }
  }

  Future<void> logout() async {
    await AppSession.clear();
    emit(const Unauthenticated());
  }
}
