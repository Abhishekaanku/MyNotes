class UserNotLoggedInException implements Exception {
  final String code;

  UserNotLoggedInException() : code = "user_not_logged_in";
}

class UserAlreadyRegisteredException implements Exception {
  final String code;

  UserAlreadyRegisteredException({required this.code});
}

class PasswordTooSimpleException implements Exception {
  final String code;

  PasswordTooSimpleException({required this.code});
}

class InvalidCredentialExcepton implements Exception {
  final String code;

  InvalidCredentialExcepton({required this.code});
}

class GenericAuthException implements Exception {
  final String code;

  GenericAuthException({required this.code});
}
