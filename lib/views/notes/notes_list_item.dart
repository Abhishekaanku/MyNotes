import 'package:flutter/material.dart';
import 'package:learn_dart/service/firestore/notes_firestore.dart';
import 'package:learn_dart/util/alert_dialog.dart';

typedef NotesCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final List<CloudNote> notes;
  final NotesCallBack onDelete;
  final NotesCallBack onTap;
  const NotesListView(
      {super.key,
      required this.notes,
      required this.onDelete,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
              notes[index].text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onTap(notes[index]),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await yesNoDialog(
                  context: context,
                  title: "Delete Note",
                  content: "Do You want to delete the Note?",
                );
                if (shouldDelete) {
                  onDelete(notes[index]);
                }
              },
              icon: const Icon(Icons.delete),
            ));
      },
      itemCount: notes.length,
    );
  }
}
