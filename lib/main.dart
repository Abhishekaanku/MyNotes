import 'package:flutter/material.dart';
import 'package:learn_dart/service/constants/routes.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';
import 'package:learn_dart/views/notes/create_update_notes.dart';
import 'package:learn_dart/views/notes/notes_view.dart';
import 'package:learn_dart/views/login_view.dart';
import 'package:learn_dart/views/register_view.dart';
import 'package:learn_dart/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

Future<void> future() async {
  await Future.delayed(const Duration(seconds: 2), () => {});
  await Future.sync(() => FirebaseAuthProvider.instance.initialize());

  var user = FirebaseAuthProvider.instance.getCurrentUser();
  if (user != null && !user.emailVerified) {
    await FirebaseAuthProvider.instance.sendEmailVerificationLink();
  }
  return;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              late final Widget homeWidget;
              var user = FirebaseAuthProvider.instance.getCurrentUser();
              if (user == null) {
                homeWidget = const LoginView(title: "Login");
              } else if (!user.emailVerified) {
                homeWidget = const VerifyEmailView(title: "Verify Email");
              } else {
                homeWidget = const NotesView(title: "Notes");
              }
              return AppWidget(homeWidget: homeWidget);
            default:
              return const AppWidget(homeWidget: NotesLoadingView());
          }
        });
  }
}

class AppWidget extends StatelessWidget {
  final Widget homeWidget;
  const AppWidget({
    super.key,
    required this.homeWidget,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: homeWidget,
      routes: {
        notesRoute: (context) => const NotesView(title: "Notes"),
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
