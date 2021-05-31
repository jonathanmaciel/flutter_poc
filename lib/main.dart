import 'package:flutter/material.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:flutter_poc/main.config.dart';
import 'package:flutter_poc/presentations/contact_page.dart';
import 'package:flutter_poc/presentations/contacts_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<dynamic> configureInstanceLocatorEnvironment(SharedPreferences instance) async {
  await getIt.reset();
  final Preference preference = Preference(instance);
  getIt.registerSingleton(preference, instanceName: 'preference');
  $initGetIt(getIt, environment: preference.findEnvironmentNameById());
}

T instanceLocator<T extends Object>(String name) => getIt<T>(instanceName: name);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((instance) async {
    await configureInstanceLocatorEnvironment(instance);
    runApp(FlutterPoc());
  });
}

abstract class PresentationRouterPaths {
  static const CONTACT_LIST = '/';
  static const CONTACT_FORM = '/contact';
}

class FlutterPoc extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter POC #1: Contacts',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        PresentationRouterPaths.CONTACT_LIST: (_) => ContactHome(), 
        PresentationRouterPaths.CONTACT_FORM: (_) => ContactForm()
      }
    );
  }
}
