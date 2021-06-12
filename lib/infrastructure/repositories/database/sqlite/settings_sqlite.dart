import 'dart:async';

import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:flutter_poc/infrastructure/repositories/database/connection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

@Named("settings") 
@Singleton(as: Settings)
@Environment('LOCAL')
class SettingsSQLite implements Settings {

  const SettingsSQLite(@Named('connection') this._connection);

  final Connection _connection;

  @override
  Future<Setting> item(int? id) async {
    final Database database = await _connection.connect;
    final List<Map<String, dynamic>> settingsMapped = await database.rawQuery(_SettingsSqliteSQL.select, [id]);
    return Setting(settingsMapped.first['settings_id'] as int?, settingsMapped.first['settings_value'] as String?);
  }

  @override
  Future<Setting> put(Setting? setting) async {
    final Database database = await _connection.connect;
    final int rowsEffected = await database.rawUpdate(_SettingsSqliteSQL.update, [setting?.value, setting?.id]);
    if (rowsEffected == 0) throw Exception('ERROR: Settings SQL UPDATE');
    return Setting(setting?.id, setting?.value);
  }
}

abstract class _SettingsSqliteSQL {

  static const String select =
      'SELECT settings_id, settings_value '
      'FROM tb_settings '
      'WHERE settings_id = ? '
      'ORDER BY settings_id ';

  static const String update =
      'UPDATE tb_settings SET settings_value=? '
      'WHERE settings_id=? ';
}
