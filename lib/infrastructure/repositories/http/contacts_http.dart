import 'dart:async';
import 'dart:convert';

import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@Named("contacts")
@Singleton(as: Contacts)
@Environment('REMOTE_HTTP')
class ContactsHttp implements Contacts {

  const ContactsHttp(@Named('preference') this._preference);

  final Preference _preference;

  @override
  Future<List<Contact>> list() async {
    final response = await http.get(Uri.http(_preference.httpHostURL, '/contacts/book'));
    final bool isNotListed = response.statusCode != 200;
    if (isNotListed) throw Exception('ERROR: Contacts HTTP GET - ${response.statusCode}');
    final List<dynamic> responseBody = jsonDecode(response.body);
    return responseBody.map((dynamic responseBodyItem) => Contact.fromJson(responseBodyItem)).toList();
  }

  @override
  Future<Contact> item(int? id) async {
    final response = await http.get(Uri.http(_preference.httpHostURL, '/contacts/book/$id'));
    final bool isNotListed = response.statusCode != 200;
    if (isNotListed) throw Exception('ERROR: Contacts HTTP GET - ${response.statusCode}');
    return Contact.fromJson(jsonDecode(response.body));
  }

  @override
  Future<List<Contact>> listNames(String? name) => throw Exception('no http impl.');

  @override
  Future<Contact> post(Contact? contact) async {
    final response = await http.post(Uri.http(_preference.httpHostURL, '/contacts/book'),
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, 
        body: jsonEncode(contact?.toJson()));
    final bool isNotCreated = response.statusCode != 201;
    if (isNotCreated) {
      if (response.body.isNotEmpty) throw DomainException.fromJson(jsonDecode(response.body));
      throw Exception('ERROR: Contacts HTTP POST - ${response.statusCode}');
    }
    return Contact.fromJson(jsonDecode(response.body));
  }

  @override
  Future<Contact> put(Contact? contact) async {
    final response = await http.put(Uri.http(_preference.httpHostURL, '/contacts/book'),
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, 
        body: jsonEncode(contact?.toJson()));
    final bool isNotUpdated = response.statusCode != 200;
    if (isNotUpdated) {
      if (response.body.isNotEmpty) throw DomainException.fromJson(jsonDecode(response.body));
      throw Exception('ERROR: Contacts HTTP PUT - ${response.statusCode}');
    }
    return Contact.fromJson(jsonDecode(response.body));
  }

  @override
  Future<bool> delete(Contact contact) async {
    final response = await http.delete(Uri.http(_preference.httpHostURL, '/contacts/book'),
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, 
        body: jsonEncode(contact.toJson()));
    final bool isNotRemoved = response.statusCode != 200;
    if (isNotRemoved) {
      if (response.body.isNotEmpty) throw DomainException.fromJson(jsonDecode(response.body));
      throw Exception('ERROR: Contacts HTTP DELETE - ${response.statusCode}');
    }
    return true;
  }
}
