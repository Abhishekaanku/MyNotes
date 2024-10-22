import 'package:flutter/material.dart';
import 'package:learn_dart/service/constants/routes.dart';
import 'package:learn_dart/service/crud/notes_repository.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';
import 'package:learn_dart/util/alert_dialog.dart';
import 'package:learn_dart/views/notes/notes_list_item.dart';

enum NotesMenuAction { logOut, deRegister, profile }

class NotesLoadingView extends StatefulWidget {
  const NotesLoadingView({super.key});

  @override
  State<NotesLoadingView> createState() => _NotesLoadingViewState();
}

class _NotesLoadingViewState extends State<NotesLoadingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
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
  late final NotesService notesService;

  String get userEmail {
    return FirebaseAuthProvider.instance.getCurrentUser()!.email!;
  }

  @override
  void initState() {
    notesService = NotesService();
    super.initState();
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
              PopupMenuButton<NotesMenuAction>(onSelected: (value) async {
                switch (value) {
                  case NotesMenuAction.logOut:
                    var res = await yesNoDialog(
                      context: context,
                      title: "Logout Alert",
                      content: "Are you sure you want to Logout?",
                    );
                    if (res) {
                      await FirebaseAuthProvider.instance.signOut();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                  case NotesMenuAction.deRegister:
                    var res = await yesNoDialog(
                      context: context,
                      title: "DeRegister Alert",
                      content: "Are you sure you want to DeRegister?",
                    );
                    if (res) {
                      await notesService.deleteNotesForUser(
                        FirebaseAuthProvider.instance.getCurrentUser()!,
                      );
                      await FirebaseAuthProvider.instance.deleteCurUser();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                  case NotesMenuAction.profile:
                    await errorDialog(
                      context: context,
                      title: "Profile",
                      content: userEmail,
                    );
                }
              }, itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: NotesMenuAction.profile,
                    child: Text("Profile"),
                  ),
                  PopupMenuItem(
                    value: NotesMenuAction.logOut,
                    child: Text("Logout"),
                  ),
                  PopupMenuItem(
                      value: NotesMenuAction.deRegister,
                      child: Text("DeRegister")),
                ];
              })
            ],
            backgroundColor: Theme.of(context).primaryColor),
        body: FutureBuilder(
          future: notesService.getOrCreateUser(userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: notesService.noteStream,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text("Your notes are loading...");
                      case ConnectionState.active:
                        final dbNotes = snapshot.data!;
                        if (dbNotes.isEmpty) {
                          return const Text(
                              "Your Notes are empty!! Press + to add..");
                        }
                        return NotesListView(
                          notes: dbNotes,
                          onDelete: (note) async =>
                              await notesService.deleteNote(note),
                          onTap: (note) {
                            Navigator.of(context)
                                .pushNamed(addNotesRoute, arguments: note);
                          },
                        );
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
