import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class NotesAuthProvider {
  void initialize();

  Future<AuthUser> registerUser({
    required String email,
    required String password,
  });

  Future<AuthUser> loginUser({
    required String email,
    required String password,
  });

  AuthUser? getCurrentUser();

  void sendEmailVerificationLink();

  void signOut();

  void deleteCurUser();
}

@immutable
class AuthUser {
  final bool emailVerified;
  final String? email;

  AuthUser.firebase(User user)
      : emailVerified = user.emailVerified,
        email = user.email;

  @override
  String toString() {
    return "Email: $email, EmailVerfified: $emailVerified";
  }
}
