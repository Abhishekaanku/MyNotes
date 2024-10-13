import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_dart/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.title});
  final String title;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  String invalidCredential = "";

  void toggleInvalidCredential(String text) {
    setState(() {
      invalidCredential = text;
    });
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<FirebaseApp> future() async {
    await Future.delayed(const Duration(seconds: 5), () => {});
    return Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Enter Email"),
                keyboardType: TextInputType.emailAddress,
                controller: _email,
                autocorrect: false,
                enableSuggestions: false,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Enter Password"),
                controller: _password,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
              ),
              Text(invalidCredential),
              TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final pass = _password.text;
                    try {
                      var userCredential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: pass);
                      var user = userCredential.user;
                      var emailVerified = user?.emailVerified ?? false;
                      if (!emailVerified) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            "/emailVerify", (route) => false);
                      } else {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil("/home", (route) => false);
                      }
                    } on FirebaseAuthException catch (e) {
                      toggleInvalidCredential(e.code);
                    }
                  },
                  child: const Text("Login")),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil("/register", (route) => false),
                  child: const Text("Not Registered? Signup here!"))
            ],
          ),
        ));
  }
}
