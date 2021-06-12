import 'package:equatable/equatable.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contact_model_states.dart';

abstract class ContactEvent extends Equatable {

  const ContactEvent();
}

class ContactAddEvent extends ContactEvent {

  const ContactAddEvent(this.contact);

  final Contact contact;

  @override
  List<Object> get props => [contact];
}

class ContactViewEvent extends ContactEvent {

  const ContactViewEvent(this.contact);

  final Contact contact;

  @override
  List<Object> get props => [contact];
}

enum ContactFieldValidatorResetEventTypes { contactName, contactMeansName, contactMeansValue }

class ContactFieldValidatorErrorResetEvent extends ContactEvent {

  const ContactFieldValidatorErrorResetEvent(this.state, this.type);

  factory ContactFieldValidatorErrorResetEvent.fromContactName(ContactState state) =>
      ContactFieldValidatorErrorResetEvent(state, ContactFieldValidatorResetEventTypes.contactName);

  factory ContactFieldValidatorErrorResetEvent.fromContactMeansName(ContactState state) =>
      ContactFieldValidatorErrorResetEvent(state, ContactFieldValidatorResetEventTypes.contactMeansName);

  factory ContactFieldValidatorErrorResetEvent.fromContactMeansValue(ContactState state) =>
      ContactFieldValidatorErrorResetEvent(state, ContactFieldValidatorResetEventTypes.contactMeansValue);

  final ContactState state;

  final ContactFieldValidatorResetEventTypes type;

  bool get isContactNameField => type == ContactFieldValidatorResetEventTypes.contactName;

  bool get isContactMeansNameField => type == ContactFieldValidatorResetEventTypes.contactMeansName;

  bool get isContactMeansValueField => type == ContactFieldValidatorResetEventTypes.contactMeansValue;

  @override
  List<Object> get props => [state, type];
}

class ContactUpdateEvent extends ContactEvent {

  const ContactUpdateEvent(this.state);

  final ContactState state;

  @override
  List<Object> get props => [state];
}

class ContactMeansDialogEvent extends ContactEvent {

  const ContactMeansDialogEvent(this.state);

  final ContactState state;

  @override
  List<Object> get props => [state];
}

class ContactMeansViewEvent extends ContactEvent {

  const ContactMeansViewEvent(this.state, this.contactMeans);

  final ContactState state;

  final ContactMeans contactMeans;

  @override
  List<Object> get props => [state, contactMeans];
}

class ContactMeansRemoveEvent extends ContactEvent {

  const ContactMeansRemoveEvent(this.state, this._contactMeans);

  final ContactState state;

  final ContactMeans _contactMeans;

  ContactMeans get contactMeans {
    _contactMeans.contact =  Contact(state.contact.id, state.contact.name, state.contact.description);
    return _contactMeans;
  }

  @override
  List<Object> get props => [_contactMeans, state];
}

class ContactRemoveEvent extends ContactEvent {

  const ContactRemoveEvent(this.state, this._contactMeans);

  final ContactState state;

  final ContactMeans _contactMeans;

  ContactMeans get contactMeans {
    _contactMeans.contact =  Contact(state.contact.id, state.contact.name, state.contact.description);
    return _contactMeans;
  }

  @override
  List<Object> get props => [state, contactMeans];
}

class ContactMeansMainSelectEvent extends ContactEvent {

  const ContactMeansMainSelectEvent(this.state, this.contactMeans);

  final ContactViewedState state;

  final ContactMeans contactMeans;

  @override
  List<Object> get props => [state, contactMeans];
}
