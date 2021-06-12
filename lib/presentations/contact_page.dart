import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/presentations/commons.dart';
import 'package:flutter_poc/presentations/contact_means_dialog.dart';
import 'package:flutter_poc/presentations/instructions_dialog.dart';
import 'package:flutter_poc/presentations/model/bloc/contact_bloc.dart';
import 'package:flutter_poc/presentations/model/bloc/events/contact_events.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contact_model_states.dart';
import 'package:provider/provider.dart';

class ContactForm extends StatefulWidget {

  const ContactForm(this.contact);

  final Contact contact;

  @override
  State<StatefulWidget> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {

  ContactBloc get contactPageModel => context.read<ContactBloc>();

  /* TODO */ int _lifecycleState = 0;

  @override
  void initState() {
    super.initState();
    if (widget.contact.id == 0) contactPageModel.add(ContactAddEvent(Contact.newInstanceWithOneContactMeans()));
    else contactPageModel.add(ContactViewEvent(widget.contact));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) {
      return Scaffold(
        appBar: _buildAppbar(state),
        backgroundColor: Colors.grey[300],
        resizeToAvoidBottomInset: false,
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.bottomCenter,
              colorFilter: contactPageModel.backgroundImageColorFilter,
              image: const AssetImage("assets/contact.means.add2.png"),
            )
          ),
          child: BlocConsumer<ContactBloc, ContactState> (
            builder: (context, state) {
              final ContactState content = (state is ContactStateListener) ? state.state : state;
              if (content is ContactAddedState) return _buildForNewContact(content);
              if (content is ContactViewedState) return _buildForViewContact(content);
              else return Container(color: Colors.transparent, child: const Center(child: Text('loading...')));
            },
            listener: (context, state) async => state is ContactStateListener ? await _onModelStateListener(context, state) : null
          )
        ),
        floatingActionButton: state is ContactAddedState ? null : _buildFloatingActionButton(state),
        floatingActionButtonLocation: state is ContactAddedState ? null : FloatingActionButtonLocation.endFloat,
      );
    });
  }

  PreferredSizeWidget _buildAppbar(ContactState state) {
    final ContactState content = (state is ContactStateListener) ? state.state : state;
    return AppBar(
      shadowColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contactPageModel.title),
          Text(contactPageModel.subtitle, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10)
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(contactPageModel.updateIcon, size: 30),
          onPressed: () => contactPageModel.add(ContactUpdateEvent(content))
        )
      ]
    );
  }

  Future<void> _onModelStateListener(BuildContext context, ContactStateListener stateListener) async {
    if (stateListener is! ContactFormFormatErrorStateListener) FocusScope.of(context).unfocus();
    if (stateListener is ContactMeansDialogListener) {
      final ContactMeans? contactMeans = await showContactMeansFormDialog(context, stateListener.contact, stateListener.contactMeans);
      if (contactMeans != null) {
        showSnackBar(context, 'Meio para contato atualizado');
        contactPageModel.add(ContactViewEvent(stateListener.contact));
      }
    } else if (stateListener is ContactUpdatedListener) {
      showSnackBar(context, 'Contato atualizado');
      if (stateListener.isShowInstructionsDialog) {
        await showInstructionFisrtContactMeansAddDialog(context,
            'Meios para contato...', ContactBloc.instructionsFirstContactMeansText);
      }
      contactPageModel.add(ContactViewEvent(stateListener.contact));
    } else if (stateListener is ContactMeansViewedListener) {
      await showContactMeansFormDialog(context, stateListener.contact, stateListener.contactMeans);
      contactPageModel.add(ContactViewEvent(stateListener.contact));
    } else if (stateListener is ContactFormExceptionListener) {
      showSnackBar(context, stateListener.message, error: true);
      if (stateListener.state is ContactAddedState) contactPageModel.add(ContactAddEvent(stateListener.contact));
      else if (stateListener.state is ContactViewedState) contactPageModel.add(ContactViewEvent(stateListener.contact));
    } else if (stateListener is ContactMeansRemovedListener) {
      showSnackBar(context, 'Meio para contato removido');
      contactPageModel.add(ContactViewEvent(stateListener.contact));
    } else if (stateListener is ContactRemovedListener) {
      showSnackBar(context, 'Contato removido');
      Navigator.of(context).pop(true);
    } else if (stateListener is ContactMeansMainRemoveExceptionListener) {
      showSnackBar(context, stateListener.message, error: true);
    } else if (stateListener is ContactMeansSingleRemoveExceptionListener) {
      final bool isRemove = await showConfirmDialog(context, title: 'Aviso!', content: stateListener.message);
      if (isRemove) contactPageModel.add(ContactRemoveEvent(stateListener, stateListener.contactMeans));
    } else if (stateListener is ContactMeansMainSelectedListener) {
      showSnackBar(context, 'Meio para contato principal atualizado para \n${stateListener.contactMeans.name}: ${stateListener.contactMeans.value}');
    }
  }

  Widget _buildForNewContact(ContactAddedState state) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (state is ContactAddedState && state.isShowInstructionsDialog && /* TODO */ _lifecycleState == 0) {
        FocusScope.of(context).unfocus();
        showInstructionFisrtContactAddDialog(context, 'Primeiro contato...', ContactBloc.instructionsFirstContactText);
      }
      /* TODO */ _lifecycleState = 1;
    });
    return Column(
      children: [
        _buildForm(state),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.dashboard_customize, color: Colors.blue, size: 64),
                onPressed: () => contactPageModel.add(ContactUpdateEvent(state))
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Html(data: '<p style="text-align:center;">Informe os dados para contato e <u>clique aqui</u>!</p>')
              )
            ],
          )
        ),
      ]
    );
  }

  Widget _buildForm(ContactState state) {
    return Container(
      margin: EdgeInsets.only(bottom: state is ContactAddedState ? 30 : 0),
      height: state is ContactAddedState ? ContactBloc.heightSizeContactAdd : ContactBloc.heightSizeContactUpdated,
      width: MediaQuery.of(context).size.width,
      decoration: ShapeDecoration(shape: _ContactFormShapeBorder(), color: Colors.blue),
      child: Form(
        key: contactPageModel.formId,
        child: Column(
          children: [
            const CircleAvatar(backgroundImage: AssetImage("assets/user.png")),
            _buildTextFormField(
              controller: contactPageModel.contactNameTextController,
              isValid: contactPageModel.isContactNameValid,
              hintTextValid: 'nome...',
              hintTextInvalid: 'digite o nome...',
              validator: (value) => (contactPageModel.isContactNameValid = value?.trim().isNotEmpty??false) ? null : '',
              onSaved: (value) => state.contact.name = value ?? '',
              onTap: () => contactPageModel.add(ContactFieldValidatorErrorResetEvent.fromContactName(state)),
              onChanged: (value) => contactPageModel.add(ContactFieldValidatorErrorResetEvent.fromContactName(state))
            ),
            _buildTextFormField(
              controller: contactPageModel.contactDescriptionTextController,
              hintTextValid: 'descricao...',
              onSaved: (value) => state.contact.description = value ?? ''
            ),
            if (state is ContactAddedState) _buildTextFormField(
              controller: contactPageModel.contactMeansNameTextController,
              isValid: contactPageModel.isContactMeansNameValid,
              hintTextValid: 'meio para contato...',
              hintTextInvalid: 'digite meio para contato...',
              validator: (value) => (contactPageModel.isContactMeansNameValid = value?.trim().isNotEmpty??false) ? null : '',
              onSaved: (value) => state.contact.means?.first.name = value ?? '',
              onTap: () => contactPageModel.add(ContactFieldValidatorErrorResetEvent.fromContactMeansName(state)),
              onChanged: (value) => contactPageModel.add(ContactFieldValidatorErrorResetEvent.fromContactMeansName(state))
            ),
            if (state is ContactAddedState) _buildTextFormField(
              controller: contactPageModel.contactMeansValueTextController,
              isValid: contactPageModel.isContactMeansValueValid,
              hintTextValid: 'contato...',
              hintTextInvalid: 'digite o contato...',
              validator: (value) => (contactPageModel.isContactMeansValueValid = value?.trim().isNotEmpty??false) ? null : '',
              onSaved: (value) => state.contact.means?.first.value = value ?? '',
              onTap: () => contactPageModel.add(ContactFieldValidatorErrorResetEvent.fromContactMeansValue(state)),
              onChanged: (value) => contactPageModel.add(ContactFieldValidatorErrorResetEvent.fromContactMeansValue(state))
            ),
          ],
        ),
      )
    );
  }

  Widget _buildTextFormField({String? initialValue, bool isValid = false, String? hintTextValid,
      String? hintTextInvalid, FormFieldSetter<String>? onSaved, GestureTapCallback? onTap, TextEditingController? controller,
      ValueChanged<String>? onChanged, FormFieldValidator<String>? validator}) {
    const UnderlineInputBorder validUnderlineInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue));
    const UnderlineInputBorder invalidUnderlineInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.red));
    const UnderlineInputBorder focusUnderlineInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF42A5F5)));
    return SizedBox(
      width: 200,
      height: 40,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: validator != null ? (isValid ? hintTextValid : hintTextInvalid) : hintTextValid,
          hintStyle: TextStyle(
            fontStyle: FontStyle.italic,
            color: validator != null ? (isValid ? Colors.white : Colors.red) : Colors.white
          ),
          errorStyle: const TextStyle(fontSize: 0, height: 0),
          enabledBorder: validUnderlineInputBorder,
          focusedBorder: focusUnderlineInputBorder,
          errorBorder: validator != null ? (isValid ? validUnderlineInputBorder : invalidUnderlineInputBorder) : null,
          focusedErrorBorder: validator != null ? (isValid ? validUnderlineInputBorder : invalidUnderlineInputBorder) : null,
        ),
        style: const TextStyle(fontSize: 14, color: Colors.white),
        validator: validator,
        onSaved: onSaved,
        onTap: onTap,
        onChanged: onChanged,
      )
    );
  }

  Widget _buildForViewContact(ContactViewedState state) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          _buildForm(state),
          ListView.builder(
            shrinkWrap: true,
            itemCount: state.contact.means?.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5 / 2,
                    blurRadius: 7 / 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _buildListTile(state, index)
            ),
          )
        ]
      )
    );
  }

  Widget _buildListTile(ContactViewedState state, int index) {
    final ContactMeans? contactMeans = state.contact.means?.elementAt(index);
    contactMeans?.contact = Contact.copyWithoutContactMeans(state.contact);
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 18, right: 18),
      leading: const CircleAvatar(backgroundImage: AssetImage("assets/user.png")),
      title: Text(contactMeans?.name ?? '', style: const TextStyle(fontSize: 14)),
      subtitle: Text(contactMeans?.value ?? '', style: const TextStyle(fontSize: 12)),
      trailing: Container(
        width: 120,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                icon: const Icon(Icons.edit_road, color: Colors.blue),
                onPressed: () => contactPageModel.add(ContactMeansViewEvent(state, ContactMeans.copy(contactMeans)))
              )
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () async {
                  /* TODO */
                  FocusScope.of(context).unfocus();
                  final bool isConfirmation = await showConfirmDialog(context,
                      title: 'Aviso!', content: 'Voce confirma a exclusao deste contato?');
                  if (isConfirmation) contactPageModel.add(ContactMeansRemoveEvent(state, ContactMeans.copy(contactMeans)));
                }
              )
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon:
                contactMeans?.isMain??false || (state.contact.isSingleContactMeans())
                    ? const Icon(Icons.check_box, color: Colors.blue)
                    :
                const Icon(Icons.check_box_outline_blank),
                  onPressed: () => contactPageModel.add(ContactMeansMainSelectEvent(state, ContactMeans.copy(contactMeans)))
              )
            )
          ],
        )
      ),
    );
  }

  Padding _buildFloatingActionButton(ContactState state) {
    final ContactState content = (state is ContactStateListener) ? state.state : state;
    return Padding(
      padding: const EdgeInsets.only(right: 27, bottom: 13),
      child: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: ()  => contactPageModel.add(ContactMeansDialogEvent(content)),
        child: const Icon(Icons.add, color: Colors.white)
      )
    );
  }
}

class _ContactFormShapeBorder extends ContinuousRectangleBorder {

  static const double innerCircleRadius = 150;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double q1Width = rect.width / 12;
    final double cWidth = rect.width / 2;
    final double q2Width = rect.width / 2;
    final double height = rect.height == ContactBloc.heightSizeContactAdd
                 ? rect.height 
                 : rect.height - (rect.height / 4);
    final Path path = Path();
    path.lineTo(0, height);
    path.quadraticBezierTo(q1Width - (innerCircleRadius / 10) - 30, height + 15, q1Width - 75, height + 70);
    path.cubicTo(cWidth, height + innerCircleRadius - 40, cWidth + 40, 
        height + innerCircleRadius - 40, cWidth + 80, height + 80);
    path.quadraticBezierTo(q2Width + (innerCircleRadius / 2) + 60, height + 40, rect.width + 160, height + 120);
    path.lineTo(rect.width, 0);
    path.close();
    return path;
  }
}
