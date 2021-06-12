import 'dart:async';

import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/infrastructure/repositories/database/connection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

@Named("contacts")
@Singleton(as: Contacts)
@Environment('LOCAL')
class ContactSQLite implements Contacts {

  const ContactSQLite(@Named('connection') this._connection, @Named('means') this._means);

  final Connection _connection;

  final Means _means;

  @override
  Future<List<Contact>> list() async {    
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> contactsMapped = await database.rawQuery(_ContactsSqliteSQL.select);
    final List<Contact> contactsListed = [];
    for (final Map<String, dynamic> item in contactsMapped) {
      final Contact contact = Contact(item['contacts_id'] as int?, item['contacts_name'] as String?, 
          item['contacts_description'] as String?);
      contact.means = await _means.list(contact);
      try {
        final ContactMeans? contactMeansMain = contact.means?.firstWhere((item) => item.isMain == true);
        contact.label = contactMeansMain?.value;
      } catch (e) {
        contact.label = '-';
      }
      contactsListed.add(contact);
    }
    return contactsListed;
  }

  @override
  Future<Contact> item(int? id) async {
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> itemMapped = await database.rawQuery(_ContactsSqliteSQL.selectItem, [id]);
    final Contact contact = Contact(itemMapped.first['contacts_id'] as int?, itemMapped.first['contacts_name'] as String?,
        itemMapped.first['contacts_description'] as String?);
    contact.means = await _means.list(contact);
    return contact;
  }

  @override
  Future<Contact> post(Contact? contact) async {
    final Database database = await _connection.connect;
    final Contact contactInserted = Contact(0, contact?.name, contact?.description);
    contactInserted.id = await database.rawInsert(_ContactsSqliteSQL.insert, [contact?.name, contact?.description]);
    final ContactMeans contactMeans = ContactMeans(0, contact?.means?.first.name, contact?.means?.first.value, '',true);
    contactMeans.contact = contactInserted;
    contactInserted.means = [await _means.post(contactMeans)];
    return contactInserted;
  }

  @override
  Future<List<Contact>> listNames(String? name) async {
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> contactsMapped = await database.rawQuery(_ContactsSqliteSQL.selectName, [name]);
    final List<Contact> contactsListed = [];
    for (final Map<String, dynamic> item in contactsMapped) {
      final Contact contact = Contact(item['contacts_id'] as int?, item['contacts_name'] as String?, 
          item['contacts_description'] as String?);
      contactsListed.add(contact);
    }
    return contactsListed;
  }

  @override
  Future<Contact> put(Contact? contact) async {
    final Database database = await _connection.connect;
    final Contact contactUpdated = Contact(contact?.id, contact?.name, contact?.description);
    contactUpdated.means = contact?.means;
    final int rowsAffected = await database.rawUpdate(_ContactsSqliteSQL.update, [contact?.name, 
        contact?.description, contact?.id]);
    if (rowsAffected == 0) throw Exception('ERROR: Contacts SQL UPDATE');
    return contactUpdated;
  }

  @override
  Future<bool> delete(Contact contact) async {
    final Database database = await _connection.connect;
    await database.rawDelete(_ContactsSqliteSQL.deleteMean, [contact.id]);
    final int rowsAffected = await database.rawDelete(_ContactsSqliteSQL.delete, [contact.id]);
    return rowsAffected == 0;
  }
}

abstract class _ContactsSqliteSQL {

  static const String select = 
      'SELECT contacts_id, contacts_name, contacts_description ' 
      'FROM tb_contacts ORDER BY contacts_id';

  static const String selectItem = 
      'SELECT contacts_id, contacts_name, contacts_description ' 
      'FROM tb_contacts ' 
      'WHERE contacts_id = ? ';

  static const String selectName = 
      'SELECT contacts_id, contacts_name, contacts_description ' 
      'FROM tb_contacts WHERE contacts_name = ? ';

  static const String insert = 
      'insert into tb_contacts(contacts_name, contacts_description) ' 
      'values(?, ?)';

  static const String update = 
      'update tb_contacts set contacts_name=?, contacts_description=? ' 
      'where contacts_id=?';

  static const String delete = 'DELETE FROM tb_contacts WHERE contacts_id = ?';

  static const String deleteMean = 'DELETE FROM tb_contact_means WHERE contacts_id = ?';
}
