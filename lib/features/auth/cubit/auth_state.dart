import 'package:equatable/equatable.dart';
import '../../../core/data/models.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.role,
    this.name,
    this.email,
    this.photoUrl,
  });

  final UserRole role;
  final String? name;
  final String? email;
  final String? photoUrl;

  @override
  List<Object?> get props => [role, name, email, photoUrl];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
