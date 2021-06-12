import 'package:shared_preferences/shared_preferences.dart';

class Preference {

  const Preference(this.sharedPreferences);

  static const String remoteHttpUrlKey = 'Infrastructure.Preference.REMOTE_HTTP_URL';
  
  static const String remoteHttpUrlLocalhost = '';
  
  static const String environmentKey = 'Infrastructure.Preference.ENVIRONMENT';
  
  static const int environmentLocalId = 1;
  
  static const int environmentRemoteHttpId = 2;

  static const int environmentRemoteDioId = 3;

  final SharedPreferences sharedPreferences;

  String get httpHostURL => sharedPreferences.getString(remoteHttpUrlKey) ?? remoteHttpUrlLocalhost;

  set httpHostURL(String value) => sharedPreferences.setString(remoteHttpUrlKey, value);

  int get environment => sharedPreferences.getInt(environmentKey) ?? environmentLocalId;

  set environment(int value) => sharedPreferences.setInt(environmentKey, value);

  bool get isEnvironmentLocal => environment == environmentLocalId;

  bool get isEnvironmentHttpApi => environment == environmentRemoteHttpId;

  bool get isEnvironmentRemoteDioApi => environment == environmentRemoteDioId;

  String get currentEnvironment {
    switch (environment) {
      case Preference.environmentRemoteHttpId : return 'REMOTE_HTTP';
      case Preference.environmentRemoteDioId : return 'REMOTE_DIO';
      default: return 'LOCAL';
    }
  }
}
