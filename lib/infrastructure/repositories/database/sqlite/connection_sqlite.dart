import 'package:flutter_poc/infrastructure/repositories/database/connection.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@Named("connection") 
@Singleton(as: Connection)
class ConnectionSQLite implements Connection {

  static const int databaseVersion = 1;

  Database? _database;

  @override
  Future<Database?> get connect async {
    if (_database == null) {
      final String databasesPath = join(await getDatabasesPath(), 'flutter_poc.db');
      _database = await openDatabase(databasesPath, onCreate: (db, version) async {
          await db.execute(_SqliteSQL.createContacts);
          await db.execute(_SqliteSQL.createContactMeans);
          await db.execute(_SqliteSQL.createSettings);
          await db.execute(_SqliteSQL.insertDefaultSettings1);
          await db.execute(_SqliteSQL.insertDefaultSettings2);
        },
        version: databaseVersion,
      );
    }
    return _database;
  }
}

abstract class _SqliteSQL {

  static const String createContacts =
    'CREATE TABLE tb_contacts ( '
    '  contacts_id INTEGER PRIMARY KEY AUTOINCREMENT, '
    '  contacts_name VARCHAR(250), '
    '  contacts_description VARCHAR(250) '
    '); ';

  static const String createContactMeans =
    'CREATE TABLE tb_contact_means( '
    '  contacts_id INTEGER, '
    '  contact_means_id INTEGER PRIMARY KEY AUTOINCREMENT, '
    '  contact_means_name VARCHAR(250), '
    '  contact_means_value VARCHAR(250), '
    '  contact_means_description VARCHAR(250), '
    '  contact_means_is_main NUMBER, '
    '  FOREIGN KEY(contacts_id) REFERENCES TB_CONTACT(CONTACTS_ID) '
    ');';

  static const String createSettings =
    'CREATE TABLE TB_SETTINGS( '
    '  settings_id integer PRIMARY KEY AUTOINCREMENT, '
    '  settings_value VARCHAR(100) '
    ');'
  ;

  static const String insertDefaultSettings1 = 'INSERT INTO tb_settings (settings_value) VALUES (1);';

  static const String insertDefaultSettings2 = 'INSERT INTO tb_settings (settings_value) VALUES (1);';
}
