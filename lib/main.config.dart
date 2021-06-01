// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'domain/repositories/contacts.dart' as _i5;
import 'domain/repositories/means.dart' as _i6;
import 'domain/repositories/settings.dart' as _i7;
import 'domain/services/contact_book.dart' as _i3;
import 'domain/services/contact_book_local.dart' as _i8;
import 'domain/services/contact_book_remote.dart' as _i4;
import 'infrastructure/preference.dart' as _i12;
import 'infrastructure/repositories/database/connection.dart' as _i9;
import 'infrastructure/repositories/database/sqlite/connection_sqlite.dart'
    as _i10;
import 'infrastructure/repositories/database/sqlite/contacts_sqlite.dart'
    as _i17;
import 'infrastructure/repositories/database/sqlite/means_sqlite.dart' as _i14;
import 'infrastructure/repositories/database/sqlite/settings_sqlite.dart'
    as _i16;
import 'infrastructure/repositories/http/contacts_http.dart' as _i11;
import 'infrastructure/repositories/http/means_http.dart' as _i13;
import 'infrastructure/repositories/http/settings_http.dart' as _i15;

const String _http = 'http';
const String _local = 'local';
// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.lazySingleton<_i3.ContactBook>(
      () => _i4.ContactBookRemote(
          get<_i5.Contacts>(instanceName: 'contacts'),
          get<_i6.Means>(instanceName: 'means'),
          get<_i7.Settings>(instanceName: 'settings')),
      instanceName: 'contactBook',
      registerFor: {_http});
  gh.lazySingleton<_i3.ContactBook>(
      () => _i8.ContactBookLocal(
          get<_i5.Contacts>(instanceName: 'contacts'),
          get<_i6.Means>(instanceName: 'means'),
          get<_i7.Settings>(instanceName: 'settings')),
      instanceName: 'contactBook',
      registerFor: {_local});
  gh.singleton<_i9.Connection>(_i10.ConnectionSQLite(),
      instanceName: 'connection');
  gh.singleton<_i5.Contacts>(
      _i11.ContactsHttp(get<_i12.Preference>(instanceName: 'preference')),
      instanceName: 'contacts',
      registerFor: {_http});
  gh.singleton<_i6.Means>(
      _i13.MeansHttp(get<_i12.Preference>(instanceName: 'preference')),
      instanceName: 'means',
      registerFor: {_http});
  gh.singleton<_i6.Means>(
      _i14.MeansSQLite(get<_i9.Connection>(instanceName: 'connection')),
      instanceName: 'means',
      registerFor: {_local});
  gh.singleton<_i7.Settings>(
      _i15.SettingsHttp(get<_i12.Preference>(instanceName: 'preference')),
      instanceName: 'settings',
      registerFor: {_http});
  gh.singleton<_i7.Settings>(
      _i16.SettingsSQLite(get<_i9.Connection>(instanceName: 'connection')),
      instanceName: 'settings',
      registerFor: {_local});
  gh.singleton<_i5.Contacts>(
      _i17.ContactSQLite(get<_i9.Connection>(instanceName: 'connection'),
          get<_i6.Means>(instanceName: 'means')),
      instanceName: 'contacts',
      registerFor: {_local});
  return get;
}
