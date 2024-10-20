import 'package:flutter/material.dart';
import 'package:learn_dart/service/constants/routes.dart';
import 'package:learn_dart/service/crud/notes_repository.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';
import 'package:learn_dart/views/login_view.dart';
import 'package:learn_dart/views/verify_email.dart';

Future<void> future() async {
  await Future.delayed(const Duration(seconds: 2), () => {});
  await Future.sync(() => FirebaseAuthProvider.instance.initialize());

  var user = FirebaseAuthProvider.instance.getCurrentUser();
  if (user != null && !user.emailVerified) {
    await FirebaseAuthProvider.instance.sendEmailVerificationLink();
  }
  return;
}

enum HomeMenuAction { logOut, deRegister }

class HomeView extends StatefulWidget {
  final String title;
  const HomeView({super.key, required this.title});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              var user = FirebaseAuthProvider.instance.getCurrentUser();
              if (user == null) {
                return const LoginView(title: "Login");
              } else {
                if (!user.emailVerified) {
                  return const VerifyEmailView(title: "Verify Email");
                }
              }
              return const NotesView(
                title: "Notes",
              );
            default:
              return const NotesLoadingView(title: "Notes");
          }
        });
  }
}

class NotesLoadingView extends StatefulWidget {
  final String title;
  const NotesLoadingView({super.key, required this.title});

  @override
  State<NotesLoadingView> createState() => _NotesLoadingViewState();
}

class _NotesLoadingViewState extends State<NotesLoadingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class NotesView extends StatefulWidget {
  final String title;
  const NotesView({super.key, required this.title});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  NotesService? notesService;

  String get userEmail {
    return FirebaseAuthProvider.instance.getCurrentUser()!.email!;
  }

  @override
  void initState() {
    notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    notesService?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, addNotesRoute);
                  },
                  icon: const Icon(Icons.add)),
              PopupMenuButton<HomeMenuAction>(onSelected: (value) async {
                switch (value) {
                  case HomeMenuAction.logOut:
                    var res = await showLogOutAlert(context);
                    if (res) {
                      await FirebaseAuthProvider.instance.signOut();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(homeRoute, (_) => false);
                    }
                  case HomeMenuAction.deRegister:
                    var res = await showDeleteUserAlert(context);
                    if (res) {
                      await FirebaseAuthProvider.instance.deleteCurUser();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(homeRoute, (_) => false);
                    }
                }
              }, itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: HomeMenuAction.logOut,
                    child: Text("Logout"),
                  ),
                  PopupMenuItem(
                      value: HomeMenuAction.deRegister,
                      child: Text("DeRegister")),
                ];
              })
            ],
            backgroundColor: Theme.of(context).primaryColor),
        body: FutureBuilder(
          future: notesService!.getOrCreateUser(userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: notesService!.noteStream,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Text(
                            """Welcome ${userEmail.substring(0, userEmail.lastIndexOf('@'))}
                            Your Notes have been loaded""");
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}

Future<bool> showLogOutAlert(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Logout Alert"),
        content: const Text("Are you sure you want to Logout"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Logout"))
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<bool> showDeleteUserAlert(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("DeRegister Alert"),
        content: const Text("Are you sure you want to DeRegister"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DeRegister"))
        ],
      );
    },
  ).then((value) => value ?? false);
}
