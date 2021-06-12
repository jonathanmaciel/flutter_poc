import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/presentations/model/bloc/states/states.dart';

abstract class ContactMeansState extends State {

  const ContactMeansState(this.contactMeans);

  final ContactMeans contactMeans;

  bool get isSingleContactMeansAndNew => contactMeans.contact?.isSingleContactMeansAndNew??false;

  @override
  List<Object> get props => [contactMeans];
}

abstract class ContactMeansStateListener extends ContactMeansState implements /* TODO */ StateListener<ContactMeansState> {

  const ContactMeansStateListener(this._state, ContactMeans contactMeans): super(contactMeans);

  final ContactMeansState _state;

  @override
  bool isEmited(Type type) => state.runtimeType == type;

  @override
  ContactMeansState get state => _state;

  @override
  List<Object> get props => [_state, contactMeans];
}

class ContactMeansLoadingState extends ContactMeansState {

  const ContactMeansLoadingState(ContactMeans contactMeans) : super(contactMeans);
}

class ContactMeansFormState extends ContactMeansState {

  const ContactMeansFormState(ContactMeans contactMeans, this.contact): super(contactMeans);

  final Contact contact;

  bool get isSingleContactMeans => contactMeans.contact?.isSingleContactMeans()??false;

  bool get isNew => contactMeans.id == 0;

  @override
  List<Object> get props => [contactMeans, contact];
}

class ContactMeansFormFormatErrorListener extends ContactMeansStateListener {

  const ContactMeansFormFormatErrorListener(ContactMeansState state, ContactMeans contactMeans): super(state, contactMeans);

  factory ContactMeansFormFormatErrorListener.copy(ContactMeansFormState state) => ContactMeansFormFormatErrorListener(state, state.contactMeans);

  @override
  List<Object> get props => [state, contactMeans];
}

class ContactMeansFormExceptionListener extends ContactMeansStateListener {

  const ContactMeansFormExceptionListener(ContactMeansState state, ContactMeans contactMeans, this.message): super(state, contactMeans);

  final String message;

  @override
  List<Object> get props => [state, contactMeans, message];
}

class ContactMeansUpdatedListener extends ContactMeansFormState {

  const ContactMeansUpdatedListener(ContactMeans contactMeans, Contact contact) : super(contactMeans, contact);
}
