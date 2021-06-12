import 'package:equatable/equatable.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contacts_states.dart';

abstract class ContactsEvent extends Equatable {

  const ContactsEvent();
}

class ContactListViewEvent extends ContactsEvent {

  const ContactListViewEvent();

  @override
  List<Object> get props => [];
}

class ContactListItemRemoveEvent extends ContactsEvent {

  const ContactListItemRemoveEvent(this.state, this.contact);

  final ContactsState state;

  final Contact contact;

  @override
  List<Object> get props => [];
}
