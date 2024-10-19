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

  const AuthUser({required this.emailVerified});

  @override
  String toString() {
    return "EmailVerfified: $emailVerified";
  }
}
