import 'package:flutter/material.dart' show immutable;
import 'package:learn_dart/service/auth_service.dart';

@immutable
abstract class AuthBlocState {
  final bool isLoading;
  final String loadingContent;
  const AuthBlocState(
      {required this.isLoading, this.loadingContent = "Please wait a while!!"});
}

class AuthBlocStateAuthInitialising extends AuthBlocState {
  const AuthBlocStateAuthInitialising({required super.isLoading});
}

class AuthBlocStateUserNeedEmailVerify extends AuthBlocState {
  const AuthBlocStateUserNeedEmailVerify({required super.isLoading});
}

class AuthBlocStateUserLoggedIn extends AuthBlocState {
  final AuthUser authUser;
  const AuthBlocStateUserLoggedIn({
    required this.authUser,
    required super.isLoading,
  });
}

class AuthBlocStateUserLoggedOut extends AuthBlocState {
  final Exception? exception;

  const AuthBlocStateUserLoggedOut(
      {required super.isLoading, super.loadingContent = '', this.exception});
}

class AuthBlocStateUserRegistring extends AuthBlocState {
  final Exception? exception;

  const AuthBlocStateUserRegistring({
    required super.isLoading,
    super.loadingContent = '',
    this.exception,
  });
}

class AuthBlocStateUserPasswordReset extends AuthBlocState {
  final Exception? exception;
  final bool isSuccess;

  const AuthBlocStateUserPasswordReset({
    required super.isLoading,
    super.loadingContent = '',
    this.exception,
    this.isSuccess = false,
  });
}
