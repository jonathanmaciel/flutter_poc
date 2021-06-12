
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactMeansNameEqualException extends DomainException {

  const ContactMeansNameEqualException() : super('O nome esta vinculado a outro meio de contato.');

  static const int code = 509;
}
