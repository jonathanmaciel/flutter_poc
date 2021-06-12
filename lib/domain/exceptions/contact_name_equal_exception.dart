
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactNameEqualException extends DomainException {

  const ContactNameEqualException() : super('O nome esta vinculado a outro contato.');

  static const int code = 508;
}
