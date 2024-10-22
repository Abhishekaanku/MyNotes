import 'package:flutter/material.dart' show ModalRoute, BuildContext;

extension RouteArgumentContext on BuildContext {
  T? getArguments<T>() {
    var args = ModalRoute.of(this)?.settings.arguments;
    if (args != null && args is T) {
      return args as T;
    }
    return null;
  }
}
