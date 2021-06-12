import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:flutter_poc/main.config.dart';
import 'package:flutter_poc/presentations/contact_page.dart';
import 'package:flutter_poc/presentations/contacts_page.dart';
import 'package:flutter_poc/presentations/model/bloc/contact_bloc.dart';
import 'package:flutter_poc/presentations/model/bloc/contacts_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<dynamic> configureInstanceLocatorEnvironment(SharedPreferences instance) async {
  await getIt.reset();
  final Preference preference = Preference(instance);
  getIt.registerSingleton(preference, instanceName: 'preference');
  $initGetIt(getIt, environment: preference.currentEnvironment);
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
  static const String contactsScreen = '/';
  static const String contactScreen = '/contact';
}

class FlutterPoc extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter POC #1: Contacts',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        PresentationRouterPaths.contactsScreen: (_) {
          return BlocProvider<ContactsBloc>(
            create: (context) => ContactsBloc(),
            child: ContactPage(),
          );
        },
        PresentationRouterPaths.contactScreen: (_) {
          return BlocProvider<ContactBloc>(
            create: (context) => ContactBloc(),
            child: ContactForm(Contact(0, '', '')),
          );
        },
      }
    );
  }
}
