import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';

abstract class ContactBook {

  Future<dynamic> list();

  List<Contact> get listed;

  int get count;

  bool get isEmpty;

  Contact elementAt(int i);

  Future<Contact> add(Contact? contact);

  Future<dynamic> remove(Contact contact);

  Future<bool?> removeContactMean(ContactMeans? contactMeans);

  Future<dynamic> addContactMean(ContactMeans? contactMeans);

  Future<bool> getInstructionFisrtContactAddStatus();

  Future<dynamic> setInstructionFisrtContactAddStatus(bool value);

  Future<bool> getInstructionFisrtContactMeansAddStatus();

  Future<dynamic> setInstructionFisrtContactMeansAddStatus(bool value);
}
