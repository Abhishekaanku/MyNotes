import 'package:flutter/material.dart';
import 'package:learn_dart/extension/route_context.dart';
import 'package:learn_dart/service/crud/notes_repository.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';

class AddNotesView extends StatefulWidget {
  final String title;
  const AddNotesView({super.key, required this.title});

  @override
  State<AddNotesView> createState() => _AddNotesViewState();
}

class _AddNotesViewState extends State<AddNotesView> {
  late final NotesService _notesService;
  late final TextEditingController _notesController;
  DbNote? _dbNote;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _cleanUpOnExit();
    _notesController.removeListener(_controllerListener);
    // _notesController.clear();
    _notesController.dispose();
    super.dispose();
  }

  void _addListener() {
    _notesController.removeListener(_controllerListener);
    _notesController.addListener(_controllerListener);
  }

  Future<DbNote> _createNote(BuildContext context) async {
    var note = context.getArguments();
    if (note != null && note is DbNote) {
      _dbNote = note;
      _notesController.text = note.text;
      return note;
    }
    var user = FirebaseAuthProvider.instance.getCurrentUser();
    var dbUser = await _notesService.getUserByEmail(email: user!.email!);

    var dbNote = await _notesService.createNotes("", dbUser.userId);
    _dbNote = dbNote;
    return dbNote;
  }

  void _cleanUpOnExit() async {
    var text = _notesController.text;
    if (_dbNote != null && text.isEmpty) {
      await _notesService.deleteNote(_dbNote!);
      _dbNote = null;
    }
  }

  void _controllerListener() async {
    var text = _notesController.text;
    if (text.isNotEmpty && _dbNote != null) {
      var dbNote = await _notesService.updateNote(_dbNote!, text);
      _dbNote = dbNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: _createNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _addListener();
              return TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: "Enter Your Notes Here",
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
