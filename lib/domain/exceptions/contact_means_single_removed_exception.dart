
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactMeansSingleRemovedException extends DomainException {

  const ContactMeansSingleRemovedException() : super('Voce esta tentando remover o ultimo meio '
      'de contato para este contato, deseja excluir esse contato?');

  static const int code = 507;
}
