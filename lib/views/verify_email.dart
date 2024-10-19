import 'package:flutter/material.dart';
import 'package:learn_dart/exception/auth_exceptions.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';

class VerifyEmailView extends StatefulWidget {
  final String title;
  const VerifyEmailView({super.key, required this.title});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  String emailVerifyError = "";

  void setEmailVerifyError(String text) {
    setState(() {
      emailVerifyError = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(
          child: Column(
            children: [
              const Text(
                  "We have sent you an email verfication link. Please use that to verify your email."),
              TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuthProvider.instance
                          .sendEmailVerificationLink();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil("/login", (_) => false);
                    } on GenericAuthException catch (e) {
                      setEmailVerifyError(e.code);
                    }
                  },
                  child: const Text("Not Received Yet? Resend!")),
              TextButton(
                  onPressed: () async {
                    await FirebaseAuthProvider.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil("/login", (_) => false);
                  },
                  child: const Text("Login with different ID")),
              Text(emailVerifyError),
            ],
          ),
        ));
  }
}
