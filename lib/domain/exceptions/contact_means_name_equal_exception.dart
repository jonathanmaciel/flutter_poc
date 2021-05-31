
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactMeansNameEqualException extends DomainException {

  static const int STATUS = 509;
  
  ContactMeansNameEqualException() : super(509, 'O nome esta vinculado a outro meio de contato.');
}
