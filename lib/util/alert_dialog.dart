import 'package:flutter/material.dart';

typedef ActionFunction<T> = Map<String, T?> Function();

Future<T?> genericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required ActionFunction<T> actionFunction,
}) {
  final actionMap = actionFunction();
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: actionMap.keys
          .map(
            (key) => TextButton(
              onPressed: () => Navigator.of(context).pop(actionMap[key]),
              child: Text(key),
            ),
          )
          .toList(),
    ),
  );
}

Future<void> errorDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return genericDialog(
    context: context,
    title: title,
    content: content,
    actionFunction: () => {
      "OK": null,
    },
  );
}

Future<bool> yesNoDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return genericDialog(
    context: context,
    title: title,
    content: content,
    actionFunction: () => {
      "Cancel": false,
      "Yes": true,
    },
  ).then(
    (value) => value ?? false,
  );
}

void Function() showProgressDialog({
  required BuildContext context,
  required String content,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 10,
          ),
          Text(content),
        ],
      ),
    ),
    barrierDismissible: false,
  );
  return () => Navigator.of(context).pop();
}
