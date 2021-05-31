import 'package:flutter_poc/domain/entities/setting.dart';
import 'package:flutter_poc/domain/repositories/settings.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'dart:async';
import 'dart:convert';

@Named("settings") 
@Singleton(as: Settings)
@Environment('http')
class SettingsHttp implements Settings {

  final Preference _preference;

  SettingsHttp(@Named('preference') this._preference);

  @override
  Future<Setting> item(int? id) async {
    final response = await http.get(Uri.http(_preference.httpHostURL, '/contacts/book/settings/${id.toString()}'));
    final bool isNotListed = response.statusCode != 200;
    if (isNotListed) throw Exception('ERROR: Settings HTTP GET - ${response.statusCode}');
    return Setting.fromJson(jsonDecode(response.body));
  }

  @override
  Future<Setting> put(Setting? settings) async {
    final response = await http.put(Uri.http(_preference.httpHostURL, '/contacts/book/settings'), 
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, 
        body: jsonEncode(settings?.toJson()));
    final bool isNotUpdated = response.statusCode != 200;
    if (isNotUpdated) throw Exception('ERROR: Settings HTTP PUT - ${response.statusCode}');
    return Setting.fromJson(jsonDecode(response.body));
  }
}
