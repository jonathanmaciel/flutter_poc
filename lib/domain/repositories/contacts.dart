import 'package:flutter_poc/domain/entities/contact.dart';

abstract class Contacts {
  
  Future<List<Contact>> list();
  
  Future<Contact> post(Contact? contact);
  
  Future<Contact> put(Contact? contact);
  
  Future<bool> delete(Contact contact);
}
