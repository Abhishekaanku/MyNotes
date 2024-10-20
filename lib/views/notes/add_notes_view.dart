import 'package:flutter/material.dart';

class AddNotesView extends StatefulWidget {
  final String title;
  const AddNotesView({super.key, required this.title});

  @override
  State<AddNotesView> createState() => _AddNotesViewState();
}

class _AddNotesViewState extends State<AddNotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: const Text("Add your notes here"),
    );
  }
}
