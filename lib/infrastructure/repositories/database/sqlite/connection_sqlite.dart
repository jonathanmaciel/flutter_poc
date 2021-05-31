import 'package:flutter_poc/infrastructure/repositories/database/connection.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


@Named("connection") 
@Singleton(as: Connection)
class ConnectionSQLite implements Connection {

  static const int DATABASE_VERSION = 1;

  Database? _database;

  Future<Database?> get connect async {
    if (_database == null) {
      final String databasesPath = join(await getDatabasesPath(), 'flutter_poc.db');
      _database = await openDatabase(databasesPath, onCreate: (db, version) async {
          await db.execute(_SqliteSQL.CREATE_CONTACTS);
          await db.execute(_SqliteSQL.CREATE_CONTACT_MEANS);
          await db.execute(_SqliteSQL.CREATE_SETTINGS);
          await db.execute(_SqliteSQL.INSERT_DEFAULT_SETTINGS_1);
          await db.execute(_SqliteSQL.INSERT_DEFAULT_SETTINGS_2);
        },
        version: DATABASE_VERSION,
      );
    }
    return _database;
  }
}

abstract class _SqliteSQL {

  static const String CREATE_CONTACTS = """
    CREATE TABLE tb_contacts (
      contacts_id INTEGER PRIMARY KEY AUTOINCREMENT,
      contacts_name VARCHAR(250),
      contacts_description VARCHAR(250)
    );
  """;

  static const String CREATE_CONTACT_MEANS = """
    CREATE TABLE tb_contact_means(
      contacts_id INTEGER,
      contact_means_id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_means_name VARCHAR(250),
      contact_means_value VARCHAR(250),
      contact_means_description VARCHAR(250),
      contact_means_is_main NUMBER,
      FOREIGN KEY(contacts_id) REFERENCES TB_CONTACT(CONTACTS_ID)
    );
  """;

  static const String CREATE_SETTINGS = """
    CREATE TABLE TB_SETTINGS(
      settings_id integer PRIMARY KEY AUTOINCREMENT,
      settings_value VARCHAR(100)
    );
  """;

  static const String INSERT_DEFAULT_SETTINGS_1 = """
    INSERT INTO tb_settings (settings_value) VALUES (1);
  """;

  static const String INSERT_DEFAULT_SETTINGS_2 = """
    INSERT INTO tb_settings (settings_value) VALUES (1);
  """;
}
