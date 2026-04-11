import 'package:equatable/equatable.dart';

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

class Authenticated extends AuthState {
  const Authenticated({required this.role});

  final String role;

  @override
  List<Object?> get props => [role];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}
