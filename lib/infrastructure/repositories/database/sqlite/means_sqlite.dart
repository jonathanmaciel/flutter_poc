import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_main_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_name_equal_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_single_removed_exception.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/infrastructure/repositories/database/connection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

@Named("means")
@Singleton(as: Means)
@Environment('local')
class MeansSQLite implements Means {
  final Connection _connection;

  MeansSQLite(@Named('connection') this._connection);

  @override
  Future<List<ContactMeans>> list(Contact? contact) async {
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> meansMapped = await database.rawQuery(_MeansSqliteSQL.SELECT, [contact?.id]);
    final List<ContactMeans> meansList = [];
    for (final Map<String, dynamic> item in meansMapped) {
      final ContactMeans contactMeans = ContactMeans(item['contact_means_id'] as int, 
          item['contact_means_name'] as String, item['contact_means_value'] as String, '', 
          item['contact_means_is_main'] as int == 1);
      meansList.add(contactMeans);
    }
    return meansList;
  }

  @override
  Future<ContactMeans> post(ContactMeans? contactMeans) async {
    final Database database = await _connection.connect;
    final List<ContactMeans> meansListed = await _listNames(contactMeans);
    if (meansListed.isNotEmpty) throw ContactMeansNameEqualException();
    if (contactMeans?.isMain??false) {
      await database.rawUpdate(_MeansSqliteSQL.UPDATE_MAIN_CONTACT, [false, contactMeans?.contact?.id]);
    }
    contactMeans?.id = await database.rawInsert(_MeansSqliteSQL.INSERT, [contactMeans.contact?.id, 
        contactMeans.name, contactMeans.value, contactMeans.isMain]);
    return ContactMeans(contactMeans?.id, contactMeans?.name, contactMeans?.value, '', contactMeans?.isMain);
  }

  Future<List<ContactMeans>> _listNames(ContactMeans? contactMeans) async {
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> meansMapped = await database.rawQuery(_MeansSqliteSQL.SELECT_NAME, 
        [contactMeans?.contact?.id, contactMeans?.name, contactMeans?.value]);
    final List<ContactMeans> meansListed = [];
    for (final Map<String, dynamic> item in meansMapped) {
      final ContactMeans _contactMeans = ContactMeans(item['contact_means_id'] as int?, 
          item['contact_means_name'] as String?, item['contact_means_value'] as String?, '', 
          item['contact_means_is_main'] as int == 1);
      meansListed.add(_contactMeans);
    }
    return meansListed;
  }

  @override
  Future<ContactMeans> put(ContactMeans? contactMeans) async {
    final Database database = await _connection.connect;
    final List<ContactMeans> meansListed = await _listNames(contactMeans);
    if (meansListed.isNotEmpty && meansListed.first.id != contactMeans?.id) throw ContactMeansNameEqualException();
    if (contactMeans?.isMain??false) {
      await database.rawUpdate(_MeansSqliteSQL.UPDATE_MAIN_CONTACT, [false, contactMeans?.contact?.id]);
    }
    final int rowsEffected = await database.rawUpdate(_MeansSqliteSQL.UPDATE, [contactMeans?.name, 
        contactMeans?.value, (contactMeans?.isMain ?? false) ? 1 : 0, contactMeans?.id]);
    if (rowsEffected == 0) throw Exception('ERROR: Contacts SQL UPDATE');
    return ContactMeans(contactMeans?.id, contactMeans?.name, contactMeans?.value, '', contactMeans?.isMain);
  }

  @override
  Future<bool> remove(ContactMeans? contactMeans) async {
    bool isMeansMoreThanOne = (contactMeans?.contact?.means?.length ?? 0) > 1;
    if (isMeansMoreThanOne && (contactMeans?.isMain??false)) throw ContactMeansMainRemovedException();
    if (contactMeans?.contact?.isSingleContactMeans()??false) throw ContactMeansSingleRemovedException();
    final Database database = await _connection.connect;
    final int rowsEffected = await database.rawDelete(_MeansSqliteSQL.DELETE, [contactMeans?.id]);
    return rowsEffected > 0;
  }
}

abstract class _MeansSqliteSQL {

  static const String SELECT = """
      select contact_means_id, contact_means_name, contact_means_value, 
          contact_means_is_main
      from tb_contact_means
      where contacts_id = ?
      order by contact_means_id
  """;

  static const String SELECT_NAME = """
      select contact_means_id, contact_means_name, contact_means_value, 
          contact_means_is_main
      from tb_contact_means
      where contacts_id = ? AND contact_means_name = ? AND contact_means_value =?
  """;

  static const String INSERT = """
      insert into tb_contact_means(contacts_id, contact_means_name, 
          contact_means_value, 
      contact_means_is_main) values(?, ?, ?, ?)
  """;

  static const String UPDATE = """
      update tb_contact_means set contact_means_name=?, contact_means_value=?, 
          contact_means_is_main=?
      where contact_means_id=?
  """;

  static const String UPDATE_MAIN_CONTACT = """
      update tb_contact_means set contact_means_is_main=?
      where contacts_id=?
  """;

  static const String DELETE = """
      delete from tb_contact_means
      where contact_means_id=?
  """;
}
