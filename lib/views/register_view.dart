import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_dart/firebase_options.dart';

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

  Future<FirebaseApp> future() async {
    // await Future.delayed(const Duration(seconds: 5), () => {});
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
              Text(emailAlreadyExist),
              TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final pass = _password.text;
                    print("$email $pass");
                    try {
                      final userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: pass,
                      );
                      print(userCredential);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        "/emailVerify",
                        (route) => false,
                      );
                    } on FirebaseAuthException catch (e) {
                      toggleEmailExist(e.code);
                    }
                  },
                  child: const Text("Register")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      "/login",
                      (_) => false,
                    );
                  },
                  child: const Text("Already Registered? Login Here!"))
            ],
          ),
        ));
  }
}
