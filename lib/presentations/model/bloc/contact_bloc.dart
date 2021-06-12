import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_main_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_single_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_name_equal_exception.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:flutter_poc/main.dart';
import 'package:flutter_poc/presentations/model/bloc/events/contact_events.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contact_model_states.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {

  ContactBloc(): super(ContactLoadingState(Contact.newInstanceWithOneContactMeans()));

  static const String instructionsFirstContactMeansText =
      '<b>Pronto!</b><br/><br/>Agora podemos adicionar meios para contato ao seu novo contato, '
      'basta acionar o botao na barra inferior do App e testar.<br/><br/> '
      'Mais uma coisa, ha uma opcao para determinar o contato principal que sera apresentado junto com as '
      'informacoes do seu contato na tela principal.';

  static const String instructionsFirstContactText = 
      'Por hora, priorizaremos os dados mais importantes para contactar alguem:<br/><br/> '
      'O <b><i>nome</i></b> que voce ira identificar o contato<br/><br/> '
      'Uma breve <b><i>descricao</i></b> que representa a sua relacao com o contato<br/><br/> '
      'e o <b><i>meio</i></b> para contacta-lo. <br/><br/>Apos isso te mostraremos mais opcoes. ';

  static const double heightSizeContactAdd = 260;

  static const double heightSizeContactUpdated = 220;

  String _title = 'Novo Contato';

  String get title => _title;

  String _subtitle = 'Aqui voce pode cadastrar um novo contato';

  String get subtitle => _subtitle;

  IconData _updateIcon = Icons.dashboard_customize;

  IconData get updateIcon => _updateIcon;

  ColorFilter get backgroundImageColorFilter => ColorFilter.mode(Colors.grey[300]?.withOpacity(0.5)??Colors.transparent, BlendMode.dstATop);

  bool isContactNameValid = true;

  bool isContactMeansNameValid = true;

  bool isContactMeansValueValid = true;

  TextEditingController contactNameTextController = TextEditingController();

  TextEditingController contactDescriptionTextController = TextEditingController();

  TextEditingController contactMeansNameTextController = TextEditingController();

  TextEditingController contactMeansValueTextController = TextEditingController();

  final GlobalKey<FormState> formId = GlobalKey<FormState>();

  ContactBook contactBook = instanceLocator<ContactBook>('contactBook');

  @override
  Stream<ContactState> mapEventToState(ContactEvent event) async* {
    if (event.runtimeType == ContactAddEvent) {
      yield* _mapContactAddEventToState(event as ContactAddEvent);
    } else if (event.runtimeType == ContactViewEvent) {
      yield* _mapContactViewEventToState(event as ContactViewEvent);
    } else if (event.runtimeType == ContactFieldValidatorErrorResetEvent) {
      yield* _mapContactFieldValidatorResetEventToState(event as ContactFieldValidatorErrorResetEvent);
    } else if (event.runtimeType == ContactUpdateEvent) {
      yield* _mapContactUpdateEventToState(event as ContactUpdateEvent);
    } else if (event.runtimeType == ContactMeansDialogEvent) {
      yield* _mapContactMeansDialogEventToState(event as ContactMeansDialogEvent);
    } else if (event.runtimeType == ContactMeansViewEvent) {
      yield* _mapContactMeansViewEventToState(event as ContactMeansViewEvent);
    } else if (event.runtimeType == ContactMeansRemoveEvent) {
      yield* _mapContactMeansRemoveEventToState(event as ContactMeansRemoveEvent);
    } else if (event.runtimeType == ContactRemoveEvent) {
      yield* _mapContactRemoveEventToState(event as ContactRemoveEvent);
    } else if (event.runtimeType == ContactMeansMainSelectEvent) {
      yield* _mapContactMeansMainSelectEventToState(event as ContactMeansMainSelectEvent);
    }
  }

  Stream<ContactState> _mapContactAddEventToState(ContactAddEvent event) async* {
    _title = 'Novo Contato';
    _subtitle = 'Aqui voce pode cadastrar um novo contato';
    _updateIcon = Icons.dashboard_customize;
    isContactNameValid = true;
    isContactMeansNameValid = true;
    isContactMeansValueValid = true;
    contactNameTextController.text = event.contact.name??'';
    contactDescriptionTextController.text = event.contact.description??'';
    contactMeansNameTextController.text = event.contact.means?.first.name??'';
    contactMeansValueTextController.text = event.contact.means?.first.value??'';
    final bool instructionFisrtContactAddStatus = await contactBook.getInstructionFisrtContactAddStatus();
    yield ContactAddedState(Contact.newInstanceWithOneContactMeans(), instructionFisrtContactAddStatus);
  }

  Stream<ContactState> _mapContactViewEventToState(ContactViewEvent event) async* {
    _title = 'Contato';
    _subtitle = 'Aqui voce pode visualizar/atualizar os dados do cantato';
    _updateIcon = Icons.edit_road;
    contactNameTextController.text = event.contact.name??'';
    contactDescriptionTextController.text = event.contact.description??'';
    yield ContactViewedState(event.contact);
  }
  
  Stream<ContactState> _mapContactFieldValidatorResetEventToState(ContactFieldValidatorErrorResetEvent event) async* {
    formId.currentState?.save();


    /* TODO rebuild */ bool status = false;
    if (state is ContactFormFormatErrorStateListener) {
      final ContactFormFormatErrorStateListener currentState = state as ContactFormFormatErrorStateListener;
      status = !currentState.status;
    }


    if (event.isContactNameField /*&& !isContactNameValid*/) {
      isContactNameValid = true;
      yield ContactFormFormatErrorStateListener.copy(ContactAddedState(event.state.contact, false), status);
    } else if (event.isContactMeansNameField /* && !isContactMeansNameValid*/) {
      isContactMeansNameValid = true;
      yield ContactFormFormatErrorStateListener.copy(ContactAddedState(event.state.contact, false), status);
    } else if (event.isContactMeansValueField /*&& !isContactMeansValueValid*/) {
      isContactMeansValueValid = true;
      yield ContactFormFormatErrorStateListener.copy(ContactAddedState(event.state.contact, false), status);
    }
  }

  Stream<ContactState> _mapContactMeansViewEventToState(ContactMeansViewEvent event) async* {
    yield ContactMeansViewedListener(event.state, state.contact, event.contactMeans);
  }

  Stream<ContactState> _mapContactMeansRemoveEventToState(ContactMeansRemoveEvent event) async* {
    try {
      await contactBook.removeContactMeans(event.contactMeans);
      final Contact contactUpdated = await contactBook.item(event.contactMeans.contact?.id);
      yield ContactMeansRemovedListener(event.state, contactUpdated, event.contactMeans);
    } on ContactMeansMainRemovedException catch (e) {
      yield ContactMeansMainRemoveExceptionListener(event.state, event.state.contact, event.contactMeans, e.message);
    } on ContactMeansSingleRemovedException catch (e) {
      yield ContactMeansSingleRemoveExceptionListener(event.state, event.state.contact, event.contactMeans, e.message);
    }
  }

  Stream<ContactState> _mapContactRemoveEventToState(ContactRemoveEvent event) async* {
    await contactBook.remove(Contact(event.state.contact.id, '', ''));
    yield ContactRemovedListener(event.state, state.contact, event.contactMeans);
  }

  Stream<ContactState> _mapContactMeansMainSelectEventToState(ContactMeansMainSelectEvent event) async* {
    final ContactMeans contactMeans = event.contactMeans;
    contactMeans.isMain = !(contactMeans.isMain ?? false);
    contactMeans.contact = event.state.contact;
    final ContactMeans contactMeansUpdated = await contactBook.addContactMeans(event.contactMeans);
    final Contact contact = await contactBook.item(state.contact.id);
    yield ContactMeansMainSelectedListener(ContactViewedState(contact), contact, contactMeansUpdated);
  }

  Stream<ContactState> _mapContactMeansDialogEventToState(ContactMeansDialogEvent event) async* {
    final bool isValid = formId.currentState?.validate() ?? false;
    if (isValid) {
      yield ContactMeansDialogListener(event.state, event.state.contact);
    } else {

      /* TODO rebuild */ bool status = false;
      if (state is ContactFormFormatErrorStateListener) {
        final ContactFormFormatErrorStateListener currentState = state as ContactFormFormatErrorStateListener;
        status = !currentState.status;
      }

      yield ContactFormFormatErrorStateListener.copy(event.state as ContactFormState, status);
    }
  }

  Stream<ContactState> _mapContactUpdateEventToState(ContactUpdateEvent event) async* {
    formId.currentState?.save();
    final bool isValid = formId.currentState?.validate() ?? false;
    if (isValid) {
      final bool isNewContact = event.state.contact.id == 0;
      Contact contactTest;
      try {
        contactTest = await contactBook.add(Contact.copy(event.state.contact));
      } on ContactNameEqualException catch (e) {
        yield ContactFormExceptionListener(event.state, event.state.contact, e.message);
        /* TODO */ return;
      } on Exception catch (e) {
        yield ContactFormExceptionListener(event.state, event.state.contact, e.toString());
        /* TODO */ return;
      }
      _title = 'Contato';
      _subtitle = 'Aqui voce pode visualizar/atualizar os dados do cantato';
      _updateIcon = Icons.edit_road;
      final bool instructionFisrtContactMeansAddStatus = await  contactBook.getInstructionFisrtContactMeansAddStatus();
      final bool isShowInstructionsDialog = isNewContact && instructionFisrtContactMeansAddStatus;
      yield ContactUpdatedListener(event.state, contactTest, isShowInstructionsDialog);
    } else {

      /* TODO rebuild */ bool status = false;
      if (state is ContactFormFormatErrorStateListener) {
        final ContactFormFormatErrorStateListener currentState = state as ContactFormFormatErrorStateListener;
        status = !currentState.status;
      }

      yield ContactFormFormatErrorStateListener.copy(event.state, status);
    }
  }
}
