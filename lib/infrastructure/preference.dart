import 'package:shared_preferences/shared_preferences.dart';

class Preference {

  static const String REMOTE_HTTP_URL = 'Infrastructure.Preference.REMOTE_HTTP_URL';
  
  static const String REMOTE_HTTP_URL_LOCALHOST = '';
  
  static const String ENVIRONMENT = 'Infrastructure.Preference.ENVIRONMENT';
  
  static const int ENVIRONMENT_LOCAL = 1;
  
  static const int ENVIRONMENT_REMOTE = 2;

  final SharedPreferences sharedPreferences;

  Preference(this.sharedPreferences);

  String get httpHostURL => sharedPreferences.getString(REMOTE_HTTP_URL) ?? REMOTE_HTTP_URL_LOCALHOST;

  set httpHostURL(String value) => sharedPreferences.setString(REMOTE_HTTP_URL, value);

  int get environment => sharedPreferences.getInt(ENVIRONMENT) ?? ENVIRONMENT_LOCAL;

  set environment(int value) => sharedPreferences.setInt(ENVIRONMENT, value);

  get isEnvironmentLocal => environment == ENVIRONMENT_LOCAL;

  get isEnvironmentHttp => environment == ENVIRONMENT_REMOTE;

  String findEnvironmentNameById() => environment == Preference.ENVIRONMENT_REMOTE ? 'http' : 'local';
}
