import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthBlocEvent {
  const AuthBlocEvent();
}

class AuthBlocEventAuthInitialise extends AuthBlocEvent {
  const AuthBlocEventAuthInitialise();
}

class AuthBlocEventUserLogin extends AuthBlocEvent {
  final String email;
  final String password;

  const AuthBlocEventUserLogin({required this.email, required this.password});
}

class AuthBlocEventUserLogout extends AuthBlocEvent {
  const AuthBlocEventUserLogout();
}

class AuthBlocEventUserSendEmail extends AuthBlocEvent {
  const AuthBlocEventUserSendEmail();
}

class AuthBlocEventUserRegister extends AuthBlocEvent {
  final String email;
  final String password;

  const AuthBlocEventUserRegister(
      {required this.email, required this.password});
}

class AuthBlocEventUserDelete extends AuthBlocEvent {
  const AuthBlocEventUserDelete();
}

class AuthBlocEventUserRegistering extends AuthBlocEvent {
  const AuthBlocEventUserRegistering();
}

class AuthBlocEventOpenPasswordReset extends AuthBlocEvent {
  const AuthBlocEventOpenPasswordReset();
}

class AuthBlocEventSendPasswordReset extends AuthBlocEvent {
  final String email;
  const AuthBlocEventSendPasswordReset({required this.email});
}
