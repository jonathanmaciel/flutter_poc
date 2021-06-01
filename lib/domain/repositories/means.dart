import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';

abstract class Means {

  Future<List<ContactMeans>> list(Contact? contact);

  Future<List<ContactMeans>> listNames(ContactMeans? contactMeans);

  Future<ContactMeans> post(ContactMeans? mean);

  Future<ContactMeans> put(ContactMeans? mean);

  Future<bool> remove(ContactMeans? mean);
}
