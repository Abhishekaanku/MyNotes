import 'package:flutter/material.dart' show immutable;
import 'package:learn_dart/service/auth_service.dart';

@immutable
abstract class AuthBlocState {
  const AuthBlocState();
}

class AuthBlocStateAuthInitialising extends AuthBlocState {
  const AuthBlocStateAuthInitialising();
}

class AuthBlocStateUserNeedEmailVerify extends AuthBlocState {
  const AuthBlocStateUserNeedEmailVerify();
}

class AuthBlocStateUserLoggedIn extends AuthBlocState {
  final AuthUser authUser;
  const AuthBlocStateUserLoggedIn({required this.authUser});
}

class AuthBlocStateUserLoggedOut extends AuthBlocState {
  final Exception? exception;
  final bool isLoading;

  const AuthBlocStateUserLoggedOut({required this.isLoading, this.exception});
}

class AuthBlocStateUserRegistring extends AuthBlocState {
  final Exception? exception;
  final bool isLoading;

  const AuthBlocStateUserRegistring({
    this.exception,
    required this.isLoading,
  });
}
