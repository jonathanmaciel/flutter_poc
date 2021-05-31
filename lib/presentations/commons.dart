import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, {bool error: false}) {
  final SnackBar snackBar = SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, 
      backgroundColor: error ? Colors.red : Colors.green, duration: Duration(seconds: error ? 2 : 1));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool?> showConfirmDialog(BuildContext context, {String? title, String? content}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title??''),
      content: Text(content??''),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('NAO')),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('SIM'))
      ],
    )
  );
}
