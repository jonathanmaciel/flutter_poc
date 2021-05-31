import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:flutter_poc/presentations/commons.dart';
import 'package:flutter_html/flutter_html.dart';

Future<bool?> showPreferencesDialog(BuildContext context, Preference preference) async {
  bool? value = await showDialog(context: context, barrierDismissible: false, 
    builder: (context) => PreferencesDialog(preference));
  return value;
}

class PreferencesDialog extends StatefulWidget {
  
  final Preference _preference;

  PreferencesDialog(this._preference);

  @override
  State<StatefulWidget> createState() => _PreferencesDialogState(this._preference);
}

class _PreferencesDialogState extends State<PreferencesDialog> {

  final GlobalKey<FormState> formId = GlobalKey<FormState>();
  
  final Preference _preference;
  
  int? _radio = 1;

  bool _isHttpURLInvalid = false;

  _PreferencesDialogState(this._preference) {
    _radio = _preference.environment;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Parametros'),
      content: Container(
        height: MediaQuery.of(context).size.height/3, 
        width: MediaQuery.of(context).size.width - 20, 
        child: _buildForm(context)
      ),
      actions: [
        Visibility(
          visible: _isHttpURLInvalid,
          child: TextButton(
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () async {
              Navigator.of(context).pop(true);
            }
          )
        ),
        TextButton(
          onPressed: () {
            final bool? isValid = formId.currentState?.validate();
            setState(() { });
            if (isValid != null && isValid) {
              formId.currentState?.save();
              _preference.environment = _radio??Preference.ENVIRONMENT_LOCAL;
              showSnackBar(context, 'Parametros atualizados');
              Navigator.of(context).pop(true);
            }
          }, 
          child: Text('Atualizar')
        )
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: formId,
      child: Column(
        children: [
          Text('Selecione o meio para manter/interagir com os dados na aplicacao:',
          style: TextStyle(fontSize: 14, color: Colors.black)),
          Row(
            children: [
              new Radio(
                value: Preference.ENVIRONMENT_LOCAL,
                groupValue: _radio,
                onChanged: (int? value) => _handleRadioValueChange(value)
              ),
              new Text(
                'SQLite', style: new TextStyle(fontSize: 16.0, 
                  fontWeight: _radio == Preference.ENVIRONMENT_LOCAL ? FontWeight.bold : FontWeight.normal,
                  color: _radio == Preference.ENVIRONMENT_LOCAL ? Colors.blue : Colors.black
                ),
              ),
              new Radio(
                value: Preference.ENVIRONMENT_REMOTE,
                groupValue: _radio,
                onChanged: (int? value) =>_handleRadioValueChange(value),
              ),
              new Text(
                'HTTP',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: _radio == Preference.ENVIRONMENT_LOCAL ? FontWeight.normal : FontWeight.bold,
                  color: _radio == Preference.ENVIRONMENT_LOCAL ? Colors.black : Colors.blue
                ),
              ),
            ],
          ),
          Container(
            child: _radio == Preference.ENVIRONMENT_LOCAL
                 ? Html(
                    data: """
                        <p>Um arquivo de banco de dados sera criado neste dispositivo e os dados
                        serao tratados a partir de um repository SQL.</p>
                        <p><i>Este metodo e suportado apenas em <br/><u>emuladores e dispositivos<u></i></p>
                    """)
                 : Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Html(
                         data: """
                             <p>Os dados serao tratados a partir de um repository HTTP.</p>
                             <p><u>O <i>host</i> e a <i>porta</i> devem ser confirmados:</u></p>
                         """),
                       SizedBox(
                         width: 200,
                         height: 40,
                         child: TextFormField(
                           initialValue: _preference.httpHostURL,
                           decoration: InputDecoration(
                             hintText: _isHttpURLInvalid ? 'digite a URL...' :'localhost:3000', 
                             prefixText: _isHttpURLInvalid? '' :'http://',
                             hintStyle: TextStyle(
                               fontStyle: FontStyle.italic, 
                               color: _isHttpURLInvalid ? Colors.red : Colors.grey
                             ),
                             errorStyle: TextStyle(fontSize: 0, height: 0),
                             enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),  
                             focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),  
                             errorBorder: _isHttpURLInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)), 
                             focusedErrorBorder: _isHttpURLInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))
                           ),
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            validator: (newValue) => (_isHttpURLInvalid = (newValue?.trim().isEmpty??false)) ? '' : null,
                            onSaved: (newValue) => _preference.httpHostURL = newValue ?? '',
                            onChanged: (value) {
                              if (_isHttpURLInvalid) {
                                setState(() {
                                  _isHttpURLInvalid = false;
                                });
                              }
                            },
                            onTap: () {
                              if (_isHttpURLInvalid) {
                                setState(() {
                                  _isHttpURLInvalid = false;
                                });
                              }
                            },
                         )
                       ),
                     ],
                   )
          )
        ]
      )    
    );
  }

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radio = value;
      if (value == Preference.ENVIRONMENT_LOCAL) _isHttpURLInvalid = false;
    });
  }
}
