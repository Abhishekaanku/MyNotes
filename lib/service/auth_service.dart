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
  final String userId;
  final bool emailVerified;
  final String email;

  AuthUser.firebase(User user)
      : emailVerified = user.emailVerified,
        email = user.email!,
        userId = user.uid;

  @override
  String toString() {
    return "UserId: $userId, Email: $email, EmailVerfified: $emailVerified";
  }
}
