
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';

class ContactMeansMainRemovedException extends DomainException {

  const ContactMeansMainRemovedException() : super('Voce esta tentando remover o meio de '
      'contato principal para este contato, selecione outro e tente novamente.');

  static const int code = 506;
}
