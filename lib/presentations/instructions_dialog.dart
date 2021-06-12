import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:flutter_poc/main.dart';

Future<bool?> showInstructionFisrtContactAddDialog(BuildContext context,
    String title, String content) async {
  final bool? value = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InstructionsDialog(true, title, content)
  );
  final ContactBook contactBook = instanceLocator<ContactBook>('contactBook');
  await contactBook.setInstructionFisrtContactAddStatus(value ?? false);
}

Future<bool?> showInstructionFisrtContactMeansAddDialog(BuildContext context,
    String title, String content) async {
  final bool? value = await showDialog<bool>(
    context: context, 
    barrierDismissible: false, 
    builder: (context) => InstructionsDialog(true, title, content)
  );
  final ContactBook contactBook = instanceLocator<ContactBook>('contactBook');
  await contactBook.setInstructionFisrtContactMeansAddStatus(value ?? false);
}

class InstructionsDialog extends StatefulWidget {

  const InstructionsDialog(this._status, this._title, this._text);

  final bool _status;

  final String _text;

  final String _title;

  @override
  State<StatefulWidget> createState() => _InstructionsDialogState(_status, _title, _text);
}

class _InstructionsDialogState extends State<InstructionsDialog> {

  _InstructionsDialogState(this._status, this._title, this._text);

  bool _status;

  final String _title;

  final String _text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title),
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: 340,
        child: Column(
          children: [
            Html(data: _text),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: CheckboxListTile(
                title: const Text(
                  'Voce quer ser lembrado novamente no proximo contato?',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                value: _status,
                onChanged: (value) {
                  /* TODO */ setState(() {
                    _status = value??false;
                  });
                }
              )
            )
          ]
        )
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(_status), child: const Text('Fechar'))],
    );
  }
}
