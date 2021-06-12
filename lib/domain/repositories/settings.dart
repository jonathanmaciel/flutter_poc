import 'package:flutter_poc/domain/entities/setting.dart';

abstract class Settings {

  static const int instructionsFirstContactAddStatus = 1;

  static const int instructionsFirstContactMeansAddStatus = 2;

  Future<Setting> item(int? id);

  Future<Setting> put(Setting? settings);
}
