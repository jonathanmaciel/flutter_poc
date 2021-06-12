import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/presentations/commons.dart';
import 'package:flutter_poc/presentations/model/bloc/contact_means_bloc.dart';
import 'package:flutter_poc/presentations/model/bloc/events/contact_means_events.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contact_means_states.dart';

Future<ContactMeans?> showContactMeansFormDialog(BuildContext context, Contact contact, ContactMeans? contactMeans) async {

  final ContactMeans contactMeansCloned = ContactMeans.copy(contactMeans);
  contactMeansCloned.contact = contactMeans?.contact;
  final ContactMeans? value = await showDialog(context: context, barrierDismissible: false,
    builder: (_) => BlocProvider<ContactMeansBloc>(
      create: (context) => ContactMeansBloc(),
      child: ContactMeansFormDialog(contact, contactMeansCloned)
    )
  );
  return value;
}

class ContactMeansFormDialog extends StatefulWidget {

  const ContactMeansFormDialog(this.contact, this.contactMeans);

  final ContactMeans contactMeans;

  final Contact contact;

  @override
  State<StatefulWidget> createState() => _ContactMeansFormDialogState();
}

class _ContactMeansFormDialogState extends State<ContactMeansFormDialog> {

  ContactMeansBloc get contactMeansPageModel => context.read<ContactMeansBloc>();

  @override
  void initState() {
    super.initState();
    /* TODO */ contactMeansPageModel.emit(ContactMeansFormState(widget.contactMeans, widget.contact));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactMeansBloc, ContactMeansState>(
      builder: (context, state) {
        final ContactMeansState content = state is ContactMeansStateListener ? state.state : state;
        return AlertDialog(
          title: const Text('Meio para Contato'),
          content: Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 4,
            child: BlocConsumer<ContactMeansBloc, ContactMeansState>(
              builder: (context, state) {
                return Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      _buildForm(content),
                      Visibility(
                        visible: contactMeansPageModel.exceptionMessage.trim().isNotEmpty,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          alignment: Alignment.bottomLeft,
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            contactMeansPageModel.exceptionMessage,
                            style: const TextStyle(
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
                );
              },
              listener: (context, state) async {
                if (state is ContactMeansUpdatedListener) {
                  FocusScope.of(context).unfocus();
                  showSnackBar(context, 'Meio para contato atualizado');
                  Navigator.of(context).pop(state.contactMeans);
                }
              }
            )
          ),
          actions: [
            Visibility(
              visible: contactMeansPageModel.isNameInvalid || contactMeansPageModel.isValueInvalid || contactMeansPageModel.exception,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey))
              )
            ),
            TextButton(
              onPressed: () => {
                if (content is ContactMeansFormState) contactMeansPageModel.add(ContactMeansUpdateEvent(content))
              },
              child: const Text('Atualizar')
            )
          ],
        );
      }
    );
  }

  Widget _buildForm(ContactMeansState state) {
    return Form(
      key: contactMeansPageModel.formId,
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 40,
            child: TextFormField(
              initialValue: state.contactMeans.name,
              decoration: InputDecoration(
                hintText: contactMeansPageModel.isNameInvalid ? 'digite meio para contato...' :'meio para contato...', 
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic, 
                  color: contactMeansPageModel.isNameInvalid ? Colors.red : Colors.grey
                ),
                errorStyle: const TextStyle(fontSize: 0, height: 0),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                errorBorder: contactMeansPageModel.isNameInvalid ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedErrorBorder: contactMeansPageModel.isNameInvalid ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black),
              validator: (newValue) => (contactMeansPageModel.isNameInvalid = newValue?.trim().isEmpty??false) ? '' : null,
              onSaved: (newValue) => state.contactMeans.name = newValue ?? '',
              onTap: () {
                if (state is ContactMeansFormState) contactMeansPageModel.add(ContactMeansFieldValidatorResetEvent.fromContactMeansName(state));
              },
              onChanged: (value) {
                if (state is ContactMeansFormState) contactMeansPageModel.add(ContactMeansFieldValidatorResetEvent.fromContactMeansName(state));
              }
            )
          ),
          SizedBox(
            width: 200,
            height: 40,
            child: TextFormField(
              initialValue: state.contactMeans.value,
              decoration: InputDecoration(
                hintText: contactMeansPageModel.isValueInvalid ? 'digite o contato...' :'contato...', 
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic, 
                  color: contactMeansPageModel.isValueInvalid ? Colors.red : Colors.grey
                ),
                errorStyle: const TextStyle(fontSize: 0, height: 0),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                errorBorder: contactMeansPageModel.isValueInvalid ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedErrorBorder: contactMeansPageModel.isValueInvalid ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)) : const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black),
              validator: (newValue) => (contactMeansPageModel.isValueInvalid = newValue?.trim().isEmpty??false) ? '' : null,
              onSaved: (newValue) => state.contactMeans.value = newValue ?? '',
              onTap: () {
                if (state is ContactMeansFormState) contactMeansPageModel.add(ContactMeansFieldValidatorResetEvent.fromContactMeansValue(state));
              },
              onChanged: (value) {
                if (state is ContactMeansFormState) contactMeansPageModel.add(ContactMeansFieldValidatorResetEvent.fromContactMeansValue(state));
              }
            )
          ),
          const SizedBox(height: 16,),
          TextButton(
            onPressed: state.isSingleContactMeansAndNew ? null : () => setState(() {state.contactMeans.isMain = !(state.contactMeans.isMain ?? false);}),
            child: state.contactMeans.isMain??false
                 ? Row(
                     children: [
                       Icon(Icons.check_box, 
                         color: state.isSingleContactMeansAndNew
                              ? Colors.grey 
                              : Colors.blue
                       ),
                       const Text('Principal')
                     ]
                   )
                 : Row(
                  children: [
                    const Icon(Icons.check_box_outline_blank, color: Colors.grey),
                    const Text('Principal ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                  ],
                )
          )
        ]
      )
    );
  }
}
