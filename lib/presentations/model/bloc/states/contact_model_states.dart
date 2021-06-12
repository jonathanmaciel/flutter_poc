import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/presentations/model/bloc/states/states.dart';

abstract class ContactState extends State {

  const ContactState(this.contact);

  final Contact contact;

  @override
  List<Object> get props => [contact];
}

abstract class ContactStateListener extends ContactState implements /* TODO */ StateListener<ContactState> {

  const ContactStateListener(this._state, Contact contact): super(contact);

  final ContactState _state;

  @override
  bool isEmited(Type type) {
    return state.runtimeType == type;
  }

  @override
  ContactState get state => _state;

  @override
  List<Object> get props => [_state];
}

class ContactLoadingState extends ContactState {

  const ContactLoadingState(Contact contact) : super(contact);
}

class ContactFormState extends ContactState {

  const ContactFormState(Contact contact) : super(contact);
}

class ContactAddedState extends ContactFormState {

  const ContactAddedState(Contact contact, this.isShowInstructionsDialog) : super(contact);

  final bool isShowInstructionsDialog;
}

class ContactViewedState extends ContactFormState {

  const ContactViewedState(Contact contact) : super(contact);
}

class ContactFormFormatErrorStateListener extends ContactStateListener {

  const ContactFormFormatErrorStateListener(ContactState state, Contact contact, this.status): super(state, contact);

  factory ContactFormFormatErrorStateListener.copy(ContactState state, bool status) {
    return ContactFormFormatErrorStateListener(state, state.contact, status);
  }

  final bool status;

  @override
  List<Object> get props => [state, contact, this.status];
}

class ContactUpdatedListener extends ContactStateListener {

  const ContactUpdatedListener(ContactState state, Contact contact, this.isShowInstructionsDialog) : super(state, contact);

  final bool isShowInstructionsDialog;

  @override
  List<Object> get props => [state, contact, isShowInstructionsDialog];
}

class ContactFormExceptionListener extends ContactStateListener {

  const ContactFormExceptionListener(ContactState state, Contact contact, this.message): super(state, contact);

  final String message;

  @override
  List<Object> get props => [state, contact, message];
}

class ContactMeansDialogListener extends ContactStateListener {

  const ContactMeansDialogListener(ContactState state, Contact contact) : super(state, contact);

  ContactMeans get contactMeans => ContactMeans.newInstanceFromJson(contact);
}

class ContactMeansViewedListener extends ContactStateListener {

  const ContactMeansViewedListener(ContactState state, Contact contact, this.contactMeans) : super(state, contact);

  final ContactMeans contactMeans;

  @override
  List<Object> get props => [state, contact, contactMeans];
}

class ContactMeansRemovedListener extends ContactStateListener {

  const ContactMeansRemovedListener(ContactState state, Contact contact, this.contactMeans) : super(state, contact);

  final ContactMeans contactMeans;

  @override
  List<Object> get props => [state, contact, contactMeans];
}

class ContactRemovedListener extends ContactStateListener {

  const ContactRemovedListener(ContactState state, Contact contact, this.contactMeans) : super(state, contact);

  final ContactMeans contactMeans;

  @override
  List<Object> get props => [state, contact, contactMeans];
}

class ContactMeansMainRemoveExceptionListener extends ContactStateListener {

  const ContactMeansMainRemoveExceptionListener(ContactState state, Contact contact,
      this.contactMeans, this.message) : super(state, contact);

  final ContactMeans contactMeans;

  final String message;

  @override
  List<Object> get props => [state, contact, contactMeans, message];
}

class ContactMeansSingleRemoveExceptionListener extends ContactStateListener {

  const ContactMeansSingleRemoveExceptionListener(ContactState state, Contact contact,
      this.contactMeans, this.message) : super(state, contact);

  final ContactMeans contactMeans;

  final String message;

  @override
  List<Object> get props => [state, contact, contactMeans, message];
}

class ContactMeansMainSelectedListener extends ContactStateListener {

  const ContactMeansMainSelectedListener(ContactViewedState state, Contact contact,
      this.contactMeans) : super(state, contact);

  final ContactMeans contactMeans;

  @override
  List<Object> get props => [state, contact, contactMeans];
}
