import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:flutter_poc/main.dart';
import 'package:flutter_poc/presentations/commons.dart';

Future<bool> showPreferencesDialog(BuildContext context) async {
  final Preference preference = instanceLocator<Preference>('preference');
  final int environment = preference.environment;
  await showDialog(context: context, barrierDismissible: false, builder: (context) => PreferencesDialog(preference));
  final int currentEnvironment = preference.environment;
  final bool isEnvironmentUpated = environment != currentEnvironment;
  await configureInstanceLocatorEnvironment(preference.sharedPreferences);
  return isEnvironmentUpated;
}

class PreferencesDialog extends StatefulWidget {

  const PreferencesDialog(this._preference);

  final Preference _preference;

  @override
  State<StatefulWidget> createState() => _PreferencesDialogState(_preference);
}

class _PreferencesDialogState extends State<PreferencesDialog> {

  _PreferencesDialogState(this._preference) {
    _radio = _preference.environment;
  }

  final GlobalKey<FormState> formId = GlobalKey<FormState>();
  
  final Preference _preference;
  
  int? _radio = 1;

  bool _isHttpURLInvalid = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Parametros'),
      content: Container(
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width - 20, 
        child: _buildForm(context)
      ),
      actions: [
        Visibility(
          visible: _isHttpURLInvalid,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)))
        ),
        TextButton(
          onPressed: () /* TODO */ {
            final bool? isValid = formId.currentState?.validate();
            setState(() { });
            if (isValid != null && isValid) {
              formId.currentState?.save();
              _preference.environment = _radio??Preference.environmentLocalId;
              showSnackBar(context, 'Parametros atualizados');
              Navigator.of(context).pop(true);
            }
          }, 
          child: const Text('Atualizar')
        )
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: formId,
      child: Column(
        children: [
          const Text('Selecione o meio para manter/interagir com os dados na aplicacao:',
          style: TextStyle(fontSize: 14, color: Colors.black)),
          Row(
            children: [
              Radio(
                value: Preference.environmentLocalId,
                groupValue: _radio,
                onChanged: _handleRadioValueChange
              ),
              Text(
                'SQLite',
                style: TextStyle(fontSize: 16,
                  fontWeight: _radio == Preference.environmentLocalId ? FontWeight.bold : FontWeight.normal,
                  color: _radio == Preference.environmentLocalId ? Colors.blue : Colors.black
                ),
              ),
              Radio(
                value: Preference.environmentRemoteHttpId,
                groupValue: _radio,
                onChanged: _handleRadioValueChange,
              ),
              Text(
                'HTTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _radio == Preference.environmentRemoteHttpId ? FontWeight.bold : FontWeight.normal,
                  color: _radio == Preference.environmentRemoteHttpId ? Colors.blue : Colors.black
                ),
              ),
              Radio(
                value: Preference.environmentRemoteDioId,
                groupValue: _radio,
                onChanged: _handleRadioValueChange
              ),
              Text(
                'DIO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _radio == Preference.environmentRemoteDioId ? FontWeight.bold : FontWeight.normal,
                  color: _radio == Preference.environmentRemoteDioId ? Colors.blue : Colors.black
                ),
              ),
            ],
          ),
          Container(
            child: _radio == Preference.environmentLocalId
                 ? Html(data: '<p>Um arquivo de banco de dados sera criado neste dispositivo e os dados '
                              'serao tratados a partir de um repository SQL.</p> '
                              '<p><i>Este metodo e suportado apenas em <br/><u>emuladores e dispositivos<u></i></p> '
                   )
                 : Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Html(data: '<p>Os dados serao tratados a partir de um repository HTTP.</p> '
                                  '<p><u>O <i>host</i> e a <i>porta</i> devem ser confirmados:</u></p> '
                       ),
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
                             errorStyle: const TextStyle(fontSize: 0, height: 0),
                             enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                             focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                             errorBorder: _isHttpURLInvalid ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                             focusedErrorBorder: _isHttpURLInvalid ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))
                           ),
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                            validator: (newValue) => (_isHttpURLInvalid = newValue?.trim().isEmpty??false) ? '' : null,
                            onSaved: (newValue) => _preference.httpHostURL = newValue ?? '',
                            onChanged: (value) /* TODO */ {
                              if (_isHttpURLInvalid) {
                                setState(() {
                                  _isHttpURLInvalid = false;
                                });
                              }
                            },
                            onTap: () /* TODO */ {
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
      if (value == Preference.environmentLocalId) _isHttpURLInvalid = false;
    });
  }
}

