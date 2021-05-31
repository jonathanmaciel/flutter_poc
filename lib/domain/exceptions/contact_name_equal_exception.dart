
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactNameEqualException extends DomainException {

  static const int STATUS = 508;
  
  ContactNameEqualException() : super(STATUS, 'O nome esta vinculado a outro contato.');
}
