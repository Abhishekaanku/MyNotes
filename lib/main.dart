import 'package:flutter/material.dart';
import 'package:learn_dart/views/home_view.dart';
import 'package:learn_dart/views/login_view.dart';
import 'package:learn_dart/views/register_view.dart';
import 'package:learn_dart/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(title: 'Home Screen'),
      routes: {
        "/home": (context) => const HomeView(title: "Home"),
        "/login": (context) => const LoginView(title: "Login"),
        "/register": (context) => const RegisterView(title: "Register"),
        "/emailVerify": (context) =>
            const VerifyEmailView(title: "Verify Email"),
      },
    );
  }
}
