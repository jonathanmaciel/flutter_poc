import 'package:flutter_poc/domain/entities/setting.dart';

abstract class Settings {

  static const int INSTRUCTION_FISRT_CONTACT_ADD_STATUS = 1;

  static const int INSTRUCTION_FISRT_CONTACT_MEANS_ADD_STATUS = 2;

  Future<Setting> item(int? id);

  Future<Setting> put(Setting? settings);
}
