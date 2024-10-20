import 'package:flutter/material.dart';
import 'package:learn_dart/service/constants/routes.dart';
import 'package:learn_dart/views/notes/add_notes_view.dart';
import 'package:learn_dart/views/notes/notes_view.dart';
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
        homeRoute: (context) => const HomeView(title: "Home"),
        loginRoute: (context) => const LoginView(title: "Login"),
        registerRoute: (context) => const RegisterView(title: "Register"),
        verifyEmailRoute: (context) =>
            const VerifyEmailView(title: "Verify Email"),
        addNotesRoute: (context) => const AddNotesView(
              title: "Add Notes",
            ),
      },
    );
  }
}
