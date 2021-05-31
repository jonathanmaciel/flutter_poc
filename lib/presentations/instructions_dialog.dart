import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

Future<bool?> showInstructionsDialog(BuildContext context, bool status, String title, String content) async {
  return showDialog<bool>(
    context: context, 
    barrierDismissible: false, 
    builder: (BuildContext context) => InstructionsDialog(status, title, content)
  );
}

class InstructionsDialog extends StatefulWidget {

  final bool _status;

  final String _text;

  final String _title;

  InstructionsDialog(this._status, this._title, this._text);

  @override
  State<StatefulWidget> createState() => _InstructionsDialogState(this._status, this._title, this._text);
}

class _InstructionsDialogState extends State<InstructionsDialog> {

  bool _status;

  String _text;

  String _title;

  _InstructionsDialogState(this._status, this._title, this._text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this._title),

      content: Container(
        width: (MediaQuery.of(context).size.width),
        height: 340,
        child: Column(
          children: [
            Container(child: Html(data: _text)),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: CheckboxListTile(
                title: Text(
                  'Voce quer ser lembrado novamente no proximo contato?',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                value: _status,
                onChanged: (bool? value) {
                  setState(() {
                    _status = value??false;
                  });
                }
              )
            )
          ]
        )
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(_status), child: Text('Fechar'))],
    );
  }
}
