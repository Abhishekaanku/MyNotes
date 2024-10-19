import 'package:flutter/material.dart';
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
              return NotesView(
                widget: widget,
                loading: false,
              );
            default:
              return NotesView(
                widget: widget,
                loading: true,
              );
          }
        });
  }
}

class NotesView extends StatelessWidget {
  const NotesView({
    super.key,
    required this.widget,
    required this.loading,
  });

  final HomeView widget;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton<HomeMenuAction>(onSelected: (value) async {
              switch (value) {
                case HomeMenuAction.logOut:
                  var res = await showLogOutAlert(context);
                  if (res) {
                    await FirebaseAuthProvider.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil("/home", (_) => false);
                  }
                case HomeMenuAction.deRegister:
                  var res = await showDeleteUserAlert(context);
                  if (res) {
                    await FirebaseAuthProvider.instance.deleteCurUser();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil("/home", (_) => false);
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
      body: getBody(),
    );
  }

  Widget getBody() {
    if (!loading) {
      return const Center(
        child: Text("You are logged in!!"),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
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
