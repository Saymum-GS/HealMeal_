import 'package:equatable/equatable.dart';

import '../../../core/utils/app_role.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class OtpSending extends AuthState {
  const OtpSending();
}

class OtpSent extends AuthState {
  const OtpSent({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class OtpVerifying extends AuthState {
  const OtpVerifying();
}

class OtpError extends AuthState {
  const OtpError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.role});

  final AppRole role;

  @override
  List<Object?> get props => [role];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
