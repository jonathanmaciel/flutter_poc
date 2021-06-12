import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:injectable/injectable.dart';

@Named("settings") 
@Singleton(as: Settings)
@Environment('REMOTE_DIO')
class SettingsDio implements Settings {

  const SettingsDio(@Named('preference') this._preference);

  final Preference _preference;

  @override
  Future<Setting> item(int? id) async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.get('http://${_preference.httpHostURL}/contacts/book/settings/${id.toString()}');
      return Setting.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      throw Exception('ERROR: Contacts HTTP GET - ${e.response?.statusCode}');
    }
  }

  @override
  Future<Setting> put(Setting? settings) async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.put('http://${_preference.httpHostURL}/contacts/book/settings',
          data: jsonEncode(settings?.toJson()));
      return Setting.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      if (e.response != null) throw DomainException.fromJson(jsonDecode(e.response.toString()));
      throw Exception('ERROR: Contacts HTTP PUT - ${e.response?.statusCode}');
    }
  }
}
