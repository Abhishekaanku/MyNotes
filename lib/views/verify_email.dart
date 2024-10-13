import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
              TextButton(
                  onPressed: () async {
                    try {
                      var user = FirebaseAuth.instance.currentUser;
                      await user?.sendEmailVerification();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil("/login", (_) => false);
                    } catch (e) {
                      print("ttttt ${e.runtimeType}");
                      setEmailVerifyError(e.toString());
                    }
                  },
                  child: const Text("Verify Your Email First!")),
              TextButton(
                  onPressed: () {
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
