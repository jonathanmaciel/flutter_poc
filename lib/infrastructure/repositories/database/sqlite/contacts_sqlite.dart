import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/infrastructure/repositories/database/connection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

@Named("contacts")
@Singleton(as: Contacts)
@Environment('local')
class ContactSQLite implements Contacts {

  final Connection _connection;

  final Means _means;

  ContactSQLite(@Named('connection') this._connection, @Named('means') this._means);

  @override
  Future<List<Contact>> list() async {    
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> contactsMapped = await database.rawQuery(_ContactsSqliteSQL.SELECT);
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
  Future<Contact> post(Contact? contact) async {
    final Database database = await _connection.connect;
    final Contact contactInserted = Contact(0, contact?.name, contact?.description);
    contactInserted.id = await database.rawInsert(_ContactsSqliteSQL.INSERT, [contact?.name, contact?.description]);
    final ContactMeans contactMeans = ContactMeans(0, contact?.means?.first.name, contact?.means?.first.value, '',true);
    contactMeans.contact = contactInserted;
    contactInserted.means = [await this._means.post(contactMeans)];
    return contactInserted;
  }

  @override
  Future<List<Contact>> listNames(String? name) async {
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> contactsMapped = await database.rawQuery(_ContactsSqliteSQL.SELECT_NAME, [name]);
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
    final int rowsAffected = await database.rawUpdate(_ContactsSqliteSQL.UPDATE, [contact?.name, 
        contact?.description, contact?.id]);
    if (rowsAffected == 0) throw Exception('ERROR: Contacts SQL UPDATE');
    return contactUpdated;
  }

  @override
  Future<bool> delete(Contact contact) async {
    final Database database = await _connection.connect;
    /* TODO cascade? */ await database.rawDelete(_ContactsSqliteSQL.DELETE_MEAN, [contact.id]);
    final int rowsAffected = await database.rawDelete(_ContactsSqliteSQL.DELETE, [contact.id]);
    return rowsAffected == 0;
  }
}

abstract class _ContactsSqliteSQL {

  static const String SELECT = """
      SELECT contacts_id, contacts_name, contacts_description 
      FROM tb_contacts ORDER BY contacts_id 
  """;

  static const String SELECT_NAME = """
      SELECT contacts_id, contacts_name, contacts_description 
      FROM tb_contacts WHERE contacts_name = ? 
  """;

  static const String INSERT = """
      insert into tb_contacts(contacts_name, contacts_description) 
      values(?, ?)
  """;

  static const String UPDATE = """
      update tb_contacts set contacts_name=?, contacts_description=? 
      where contacts_id=?
  """;

  static const String DELETE = """
      DELETE FROM tb_contacts WHERE contacts_id = ?
  """;

  static const String DELETE_MEAN = """
      DELETE FROM tb_contact_means WHERE contacts_id = ?
  """;
}
