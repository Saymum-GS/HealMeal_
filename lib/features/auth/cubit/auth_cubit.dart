import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models.dart';
import '../../../core/utils/app_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial()) {
    restoreSession();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> restoreSession() async {
    if (AppSession.isLoggedIn) {
      final userId = AppSession.userId;
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data();
          emit(AuthAuthenticated(
            role: AppSession.currentUserRole,
            name: data?['name'] as String?,
            email: data?['email'] as String?,
            photoUrl: data?['photoUrl'] as String?,
          ));
          return;
        }
      }
      emit(AuthAuthenticated(role: AppSession.currentUserRole));
      return;
    }
    emit(const AuthUnauthenticated());
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = userCredential.user;
      
      if (user != null) {
        UserRole role = UserRole.patient;
        String? name;
        String? userEmail;
        
        // Fetch role and profile from Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          userEmail = data?['email'] as String?;
          name = data?['name'] as String?;
          final roleString = data?['role'] as String?;
          if (roleString != null) {
            role = UserRole.values.firstWhere(
              (e) => e.name == roleString,
              orElse: () => UserRole.patient,
            );
          }
        }

        await AppSession.persistLogin(
          role: role,
          phone: email.trim(), 
          userId: user.uid,
        );
        emit(AuthAuthenticated(
          role: role, 
          name: name, 
          email: userEmail,
          photoUrl: doc.data()?['photoUrl'] as String?,
        ));
      } else {
        emit(const AuthError(message: 'Sign in failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String name, UserRole role) async {
    emit(const AuthLoading());
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = userCredential.user;
      
      if (user != null) {
        // Enforce security: Only patient and business can be self-registered
        final finalRole = (role == UserRole.patient || role == UserRole.business) ? role : UserRole.patient;

        await _firestore.collection('users').doc(user.uid).set({
          'email': email.trim(),
          'name': name,
          'role': finalRole.name,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await AppSession.persistLogin(
          role: finalRole,
          phone: email.trim(),
          userId: user.uid,
        );
        emit(AuthAuthenticated(
          role: finalRole, 
          name: name, 
          email: email.trim(),
          photoUrl: null, // New user has no photo yet
        ));
      } else {
        emit(const AuthError(message: 'Sign up failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Registration failed'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await AppSession.clear();
    emit(const AuthUnauthenticated());
  }
}
