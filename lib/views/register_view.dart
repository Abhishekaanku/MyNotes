import 'package:flutter/material.dart';
import 'package:learn_dart/exception/auth_exceptions.dart';
import 'package:learn_dart/service/constants/routes.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.title});
  final String title;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  String emailAlreadyExist = "";

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

  void toggleEmailExist(String text) {
    setState(() {
      emailAlreadyExist = text;
    });
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
              Text(emailAlreadyExist),
              TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final pass = _password.text;
                    print("$email $pass");
                    try {
                      await FirebaseAuthProvider.instance.registerUser(
                        email: email,
                        password: pass,
                      );
                      await FirebaseAuthProvider.instance
                          .sendEmailVerificationLink();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute,
                        (route) => false,
                      );
                    } on GenericAuthException catch (e) {
                      toggleEmailExist(e.code);
                    }
                  },
                  child: const Text("Register")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  },
                  child: const Text("Already Registered? Login Here!"))
            ],
          ),
        ));
  }
}
