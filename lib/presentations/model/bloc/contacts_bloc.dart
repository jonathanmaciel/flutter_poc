import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:flutter_poc/main.dart';
import 'package:flutter_poc/presentations/model/bloc/events/contacts_events.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contacts_states.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {

  ContactsBloc(): super(const ContactsLoadingState());

  static const String instructionsFirstContactText =
      'Bem vindo!</br></br> '
      'Esse aplicativo tem o objetivo de organizar todos os seus contatos.</br></br> '
      'Para isso, o primeiro passo e <u>cadastrar o seu primeiro contato</u>, <b>e muito facil!</b></br></br> '
      'Clique aqui e vamos la!';

  ContactBook get contactBook => instanceLocator<ContactBook>('contactBook');

  @override
  Stream<ContactsState> mapEventToState(ContactsEvent event) async* {
    if (event.runtimeType == ContactListViewEvent) {
      yield* _mapContactListViewToState(event as ContactListViewEvent);
    } else if (event.runtimeType == ContactListItemRemoveEvent) {
      yield* _mapContactListItemRemoveEventToState(event as ContactListItemRemoveEvent);
    }
  }

  Stream<ContactsState> _mapContactListViewToState(ContactListViewEvent event) async* {
    final List<Contact> contactListed = await contactBook.list();
    if (contactListed.isNotEmpty) {
      yield ContactListViewedState(contactListed);
    } else {
      yield const ContactsEmptyListViewedState();
    }
  }

  Stream<ContactsState> _mapContactListItemRemoveEventToState(ContactListItemRemoveEvent event) async* {
    await contactBook.remove(Contact(event.contact.id, '', ''));
    yield ContactListItemRemovedListener(event.state, event.contact);
  }
}
