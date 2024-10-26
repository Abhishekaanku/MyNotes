import 'package:flutter/material.dart';
import 'package:learn_dart/extension/route_context.dart';
import 'package:learn_dart/service/firebase_auth_provider.dart';
import 'package:learn_dart/service/firestore/notes_firestore.dart';
import 'package:share_plus/share_plus.dart';

class AddNotesView extends StatefulWidget {
  final String title;
  const AddNotesView({super.key, required this.title});

  @override
  State<AddNotesView> createState() => _AddNotesViewState();
}

class _AddNotesViewState extends State<AddNotesView> {
  late final CloudStoreService _cloudStoreService;
  late final TextEditingController _notesController;
  CloudNote? _cloudNote;

  @override
  void initState() {
    super.initState();
    _cloudStoreService = CloudStoreService();
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

  Future<CloudNote> _createNote(BuildContext context) async {
    var note = context.getArguments();
    if (note != null && note is CloudNote) {
      _cloudNote = note;
      _notesController.text = note.text;
      return note;
    }
    var user = FirebaseAuthProvider.instance.getCurrentUser();

    var cloudNote = await _cloudStoreService.createNotes(user!);
    _cloudNote = cloudNote;

    return cloudNote;
  }

  void _cleanUpOnExit() async {
    var text = _notesController.text;
    if (_cloudNote != null && text.isEmpty) {
      await _cloudStoreService.deleteNote(_cloudNote!.notesId);
      _cloudNote = null;
    }
  }

  void _controllerListener() async {
    var text = _notesController.text;
    if (text.isNotEmpty && _cloudNote != null) {
      var dbNote =
          await _cloudStoreService.updateNote(_cloudNote!.notesId, text);
      _cloudNote = dbNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              if (_cloudNote != null) {
                Share.share(_cloudNote!.text);
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
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
