import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_name_equal_exception.dart';
import 'package:flutter_poc/domain/services/contact_book.dart';
import 'package:flutter_poc/main.dart';
import 'package:flutter_poc/presentations/model/bloc/events/contact_means_events.dart';
import 'package:flutter_poc/presentations/model/bloc/states/contact_means_states.dart';

class ContactMeansBloc extends Bloc<ContactMeansEvent, ContactMeansState> {

  ContactMeansBloc(): super(ContactMeansLoadingState(ContactMeans(0, '', '', '', false)));

  bool isNameInvalid = false;

  bool isValueInvalid = false;

  bool exception = false;

  String exceptionMessage = '';

  final GlobalKey<FormState> formId = GlobalKey<FormState>();

  @override
  Stream<ContactMeansState> mapEventToState(ContactMeansEvent event) async* {
    if (event.runtimeType == ContactMeansFieldValidatorResetEvent) {
      yield* _mapContactMeansFieldValidatorResetEventToState(event as ContactMeansFieldValidatorResetEvent);
    } else if (event.runtimeType == ContactMeansUpdateEvent) {
      yield* _mapContactMeansUpdateEventToState(event as ContactMeansUpdateEvent);
    }
  }

  Stream<ContactMeansState> _mapContactMeansFieldValidatorResetEventToState(ContactMeansFieldValidatorResetEvent event) async* {
    formId.currentState?.save();
    if (exceptionMessage.isNotEmpty) exceptionMessage = '';
    if (event.isContactMeansNameField && !isNameInvalid) {
      isNameInvalid = true;
      yield ContactMeansFormFormatErrorListener.copy(event.state);
    } else if (event.isContactMeansValueField && !isValueInvalid) {
      isValueInvalid = true;
      yield ContactMeansFormFormatErrorListener.copy(event.state);
    } else {
      yield ContactMeansFormState(event.state.contactMeans, event.state.contact);
    }
  }

  Stream<ContactMeansState> _mapContactMeansUpdateEventToState(ContactMeansUpdateEvent event) async* {
    formId.currentState?.save();
    final bool isValid = formId.currentState?.validate() ?? false;
    if (isValid) {
      formId.currentState?.save();
      final ContactBook contactBook = instanceLocator<ContactBook>('contactBook');
      try {
        final bool isNew = event.state.contactMeans.id == 0;
        final ContactMeans contactMeansUpdated = await contactBook.addContactMeans(event.state.contactMeans);
        if (!isNew) for (int i = 0; i < (event.state.contact.means?.length??0); i++) {
          if (event.state.contact.means?[i].id == contactMeansUpdated.id) {
            event.state.contact.means?[i] = contactMeansUpdated;
            break;
          }
        }
        else event.state.contact.means?.add(contactMeansUpdated);
        yield ContactMeansUpdatedListener(event.state.contactMeans, event.state.contact);
      } on ContactMeansNameEqualException catch (e) {
        exception = true;
        exceptionMessage = e.message;
        yield ContactMeansFormExceptionListener(event.state, event.state.contactMeans, e.message);
        return;
      }
    } else {
      yield ContactMeansFormFormatErrorListener.copy(event.state);
    }
  }
}

