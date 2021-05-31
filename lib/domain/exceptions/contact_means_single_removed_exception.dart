
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactMeansSingleRemovedException extends DomainException {

  static const int STATUS = 507;

  ContactMeansSingleRemovedException() : super(STATUS, 'Voce esta tentando remover o ultimo meio ' + 
      'de contato para este contato, deseja excluir esse contato?');
}
