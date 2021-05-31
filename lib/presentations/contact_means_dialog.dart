import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_name_equal_exception.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:flutter_poc/main.dart';
import 'package:flutter_poc/presentations/commons.dart';

Future<bool?> showContactMeansFormDialog(BuildContext context, ContactMeans? contactMeans) async {
  ContactMeans contactMeansCloned = ContactMeans.clone(contactMeans);
  contactMeansCloned.contact = contactMeans?.contact;
  dynamic value = await showDialog(context: context, barrierDismissible: false, 
      builder: (_) => ContactMeansFormDialog(contactMeansCloned));
  if (value != null && value is ContactMeans) {
    contactMeans = value;
  }
  return true;
}

class ContactMeansFormDialog extends StatefulWidget {

  final ContactMeans contactMeans;

  ContactMeansFormDialog(this.contactMeans);

  @override
  State<StatefulWidget> createState() => _ContactMeansFormDialogState(this.contactMeans);
}

class _ContactMeansFormDialogState extends State<ContactMeansFormDialog> {

  bool _isNameInvalid = false;

  bool _isValueInvalid = false;

  bool _exception = false;

  String _exceptionMessage = '';
  
  final ContactMeans contactMeans;

  final GlobalKey<FormState> formId = GlobalKey<FormState>();

  _ContactMeansFormDialogState(this.contactMeans) {
    if ((contactMeans.contact?.isSingleContactMeans()??false) && !isNew) this.contactMeans.isMain = true;
  }

  get isNew => contactMeans.id == 0;

    @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Meio para Contato'),
      content: Container(
        width: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.height / 4,
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              _buildForm(context),
              Visibility(
                visible: _exceptionMessage.trim().isNotEmpty, 
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.bottomLeft,
                  width: MediaQuery.of(context).size.width,
                  child:Text(
                    _exceptionMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic
                    )
                  )
                )
              ) 
           ],
         ), 
        )
      ),
      actions: [
        Visibility(
          visible: _isNameInvalid || _isValueInvalid || _exception,
          child: TextButton(
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () async {
              Navigator.of(context).pop(null);
            }
          )
        ),
        TextButton(
          child: Text('Atualizar'),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final bool? isValid = formId.currentState?.validate();
            if (isValid != null && isValid) {
              formId.currentState?.save();
              ContactBook contactBook = instanceLocator<ContactBook>('contactBook');
              try {
                  await contactBook.addContactMean(contactMeans);
              } on ContactMeansNameEqualException catch (e) {
                setState(() {
                  _exception = true;
                  _exceptionMessage = e.message ?? '';
                });
                return;
              }
              showSnackBar(context, 'Meio para contato atualizado');
              Navigator.of(context).pop(contactMeans);
            }
          }
        )
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: formId,
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 40,
            child: TextFormField(
              initialValue: contactMeans.name,
              decoration: InputDecoration(
                hintText: _isNameInvalid ? 'digite meio para contato...' :'meio para contato...', 
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic, 
                  color: _isNameInvalid ? Colors.red : Colors.grey
                ),
                errorStyle: TextStyle(fontSize: 0, height: 0),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),  
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),  
                errorBorder: _isNameInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)), 
                focusedErrorBorder: _isNameInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)), 
              ),
              style: TextStyle(fontSize: 14, color: Colors.black),
              validator: (newValue) => (_isNameInvalid = (newValue?.trim().isEmpty??false)) ? '' : null,
              onSaved: (newValue) => contactMeans.name = newValue ?? '',
              onTap: () {
                if (_isNameInvalid) {
                  setState(() {
                    _isNameInvalid = false;
                  });
                }
              },
              onChanged: (value) {
                if (_exceptionMessage.isNotEmpty) setState(() {
                  _exceptionMessage = '';
                });
                if (_isNameInvalid) {
                  setState(() {
                    _isNameInvalid = false;
                  });
                }
              },
            )
          ),
          SizedBox(
            width: 200,
            height: 40,
            child: TextFormField(
              initialValue: contactMeans.value, 
              decoration: InputDecoration(
                hintText: _isValueInvalid ? 'digite o contato...' :'contato...', 
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic, 
                  color: _isValueInvalid ? Colors.red : Colors.grey
                ),
                errorStyle: TextStyle(fontSize: 0, height: 0),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),  
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),  
                errorBorder: _isValueInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)), 
                focusedErrorBorder: _isValueInvalid ? UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)), 
              ),
              style: TextStyle(fontSize: 14, color: Colors.black),
              validator: (newValue) => (_isValueInvalid = (newValue?.trim().isEmpty??false)) ? '' : null,
              onSaved: (newValue) => contactMeans.value = newValue ?? '',
              onTap: () {
                if (_isValueInvalid) {
                  setState(() {
                    _isValueInvalid = false;
                  });
                }                    
              },
              onChanged: (value) {
                if (_exceptionMessage.isNotEmpty) setState(() {
                  _exceptionMessage = '';
                });
                if (_isValueInvalid) {
                  setState(() {
                    _isValueInvalid = false;
                  });
                }
              },
            )
          ),
          SizedBox(height: 16,),
          TextButton(  
            onPressed: (contactMeans.contact?.isSingleContactMeans()??false) && !isNew
                     ? null
                     : () => setState(() {contactMeans.isMain = !(contactMeans.isMain ?? false);}),
            child: contactMeans.isMain??false
                 ? Row(
                     children: [
                       Icon(Icons.check_box, 
                         color: (contactMeans.contact?.isSingleContactMeans()??false) && !isNew
                              ? Colors.grey 
                              : Colors.blue
                       ),
                       Text('Principal')
                     ]
                   )
                 : Row(
                  children: [
                    Icon(Icons.check_box_outline_blank, color: Colors.grey),
                    Text('Principal ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                  ],
                )
          )
        ]
      )
    );
  }
}
