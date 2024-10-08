import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
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
      home: const MyHomePage(title: 'Register Screen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
      body: FutureBuilder(
          future: future(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Center(
                  child: Column(
                    children: [
                      TextField(
                        decoration:
                            const InputDecoration(hintText: "Enter Email"),
                        keyboardType: TextInputType.emailAddress,
                        controller: _email,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      TextField(
                        decoration:
                            const InputDecoration(hintText: "Enter Password"),
                        controller: _password,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      const Text("Hello"),
                      TextButton(
                          onPressed: () async {
                            final email = _email.text;
                            final pass = _password.text;
                            print("$email $pass");
                            final UserCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: email, password: pass);
                            print(UserCredential);
                          },
                          child: const Text("Register"))
                    ],
                  ),
                );
              default:
                return const Text("Loading...");
            }
          }),
    );
  }
}
