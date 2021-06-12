import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';

abstract class ContactBook {

  Future<List<Contact>> list();

  Future<Contact> item(int? id);

  Future<Contact> add(Contact? contact);

  Future<bool> remove(Contact contact);

  Future<bool> removeContactMeans(ContactMeans? contactMeans);

  Future<ContactMeans> addContactMeans(ContactMeans? contactMeans);

  Future<bool> getInstructionFisrtContactAddStatus();

  Future<dynamic> setInstructionFisrtContactAddStatus(bool value);

  Future<bool> getInstructionFisrtContactMeansAddStatus();

  Future<dynamic> setInstructionFisrtContactMeansAddStatus(bool value);
}
