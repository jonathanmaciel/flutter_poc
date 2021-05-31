import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:flutter_poc/infrastructure/repositories/database/connection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

@Named("settings") 
@Singleton(as: Settings)
@Environment('local')
class SettingsSQLite implements Settings {

  final Connection _connection;

  SettingsSQLite(@Named('connection') this._connection);

  @override
  Future<Setting> item(int? id) async {
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> settingsMapped = await database.rawQuery(_SettingsSqliteSQL.SELECT, [id]);
    return Setting(settingsMapped.first['settings_id'] as int?, settingsMapped.first['settings_value'] as String?);
  }

  @override
  Future<Setting> put(Setting? setting) async {
    final Database database = await _connection.connect;
    final int rowsEffected = await database.rawUpdate(_SettingsSqliteSQL.UPDATE, [setting?.value, setting?.id]);
    if (rowsEffected == 0) throw Exception('ERROR: Settings SQL UPDATE');
    return Setting(setting?.id, setting?.value);
  }
}

abstract class _SettingsSqliteSQL {

  static const String SELECT = """
      SELECT settings_id, settings_value
      FROM tb_settings 
      WHERE settings_id = ?
      ORDER BY settings_id 
  """;

  static const String UPDATE = """
      UPDATE tb_settings SET settings_value=?
      WHERE settings_id=?
  """;
}
