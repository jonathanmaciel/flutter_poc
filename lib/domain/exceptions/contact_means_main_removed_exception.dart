
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactMeansMainRemovedException extends DomainException {
  
  static const int STATUS = 506;
  
  ContactMeansMainRemovedException() : super(STATUS, 'Voce esta tentando remover o meio de ' + 
      'contato principal para este contato, selecione outro e tente novamente.');
}
