import 'package:flutter/material.dart';
import 'package:learn_dart/exception/auth_exceptions.dart';
import 'package:learn_dart/service/constants/routes.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';

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
                      var user = await FirebaseAuthProvider.instance.loginUser(
                        email: email,
                        password: pass,
                      );
                      if (!user.emailVerified) {
                        await FirebaseAuthProvider.instance
                            .sendEmailVerificationLink();
                        Navigator.of(context).pushNamed(verifyEmailRoute);
                      } else {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            homeRoute, (route) => false);
                      }
                    } on GenericAuthException catch (e) {
                      toggleInvalidCredential(e.code);
                    }
                  },
                  child: const Text("Login")),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(registerRoute, (route) => false),
                  child: const Text("Not Registered? Signup here!"))
            ],
          ),
        ));
  }
}
