import 'package:equatable/equatable.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contact_means_states.dart';

abstract class ContactMeansEvent extends Equatable {

  const ContactMeansEvent();
}

enum ContactFieldValidatorResetEventTypes { contactMeansName, contactMeansValue }

class ContactMeansFieldValidatorResetEvent extends ContactMeansEvent {

  const ContactMeansFieldValidatorResetEvent(this.state, this.type);

  factory ContactMeansFieldValidatorResetEvent.fromContactMeansName(ContactMeansFormState state) =>
      ContactMeansFieldValidatorResetEvent(state, ContactFieldValidatorResetEventTypes.contactMeansName);

  factory ContactMeansFieldValidatorResetEvent.fromContactMeansValue(ContactMeansFormState state) =>
      ContactMeansFieldValidatorResetEvent(state, ContactFieldValidatorResetEventTypes.contactMeansValue);

  final ContactFieldValidatorResetEventTypes type;

  final ContactMeansFormState state;

  bool get isContactMeansNameField => type == ContactFieldValidatorResetEventTypes.contactMeansName;

  bool get isContactMeansValueField => type == ContactFieldValidatorResetEventTypes.contactMeansValue;

  @override
  List<Object> get props => [type, state];
}

class ContactMeansViewEvent extends ContactMeansEvent {

  const ContactMeansViewEvent(this.contactMeans);

  final ContactMeans contactMeans;

  @override
  List<Object> get props => [contactMeans];
}

class ContactMeansUpdateEvent extends ContactMeansEvent {

  const ContactMeansUpdateEvent(this.state);

  final ContactMeansFormState state;

  @override
  List<Object> get props => [state];
}
