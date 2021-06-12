import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/presentations/model/bloc/states/states.dart';

abstract class ContactsState extends State {

  const ContactsState();

  @override
  List<Object> get props => [];
}

abstract class ContactsStateListener extends ContactsState implements /* TODO */ StateListener<ContactsState> {

  const ContactsStateListener(this._state);

  final ContactsState _state;

  @override
  bool isEmited(Type type) => state.runtimeType == type;

  @override
  ContactsState get state => _state;

  @override
  List<Object> get props => [_state];
}

class ContactsLoadingState extends ContactsState {

  const ContactsLoadingState() : super();
}

class ContactsEmptyListViewedState extends ContactsState {

  const ContactsEmptyListViewedState();
}

class ContactListViewedState extends ContactsState {

  const ContactListViewedState(this.listed);

  final List<Contact> listed;

  @override
  List<Object> get props => [listed];
}

class ContactListItemViewListener extends ContactsStateListener {

  const ContactListItemViewListener(ContactsState state, this.contact): super(state);

  final Contact contact;

  @override
  List<Object> get props => [state, contact];
}

class ContactPreferencesViewListener extends ContactsStateListener {

  const ContactPreferencesViewListener(ContactsState state): super(state);
}

class ContactListItemRemoveConfirmListener extends ContactsStateListener {

  const ContactListItemRemoveConfirmListener(ContactsState state, this.contact): super(state);

  final Contact contact;

  @override
  List<Object> get props => [state, contact];
}

class ContactListItemRemovedListener extends ContactsStateListener {

  const ContactListItemRemovedListener(ContactsState state, this.contact): super(state);

  final Contact contact;

  @override
  List<Object> get props => [state, contact];
}
