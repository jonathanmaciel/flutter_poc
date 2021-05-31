import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'dart:async';
import 'dart:convert';

@Named("means") 
@Singleton(as: Means)
@Environment('http')
class MeansHttp implements Means {

  final Preference _preference;

  MeansHttp(@Named('preference') this._preference);

  @override
  Future<List<ContactMeans>> list(Contact? contact) async {
    final response = await http.get(Uri.http(_preference.httpHostURL, '/contacts/book/mean/${contact?.id.toString()}'));
    final bool isNotListed = response.statusCode != 200;
    if (isNotListed) throw Exception('ERROR: Contact Means HTTP GET - ${response.statusCode}');
    List<dynamic> responseBody = jsonDecode(response.body);
    return responseBody.map((dynamic responseBodyItem) => ContactMeans.fromJson(responseBodyItem)).toList();
  }

  @override
  Future<ContactMeans> post(ContactMeans? contactMeans) async {
    final ContactMeans contactMeansCloned = ContactMeans.clone(contactMeans);
    contactMeansCloned.contact = Contact(contactMeans?.contact?.id, '', '');
    final response = await http.post(Uri.http(_preference.httpHostURL, '/contacts/book/mean'),
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, 
        body: jsonEncode(contactMeansCloned.toJson()));
    final bool isNotCreated = response.statusCode != 201;
    if (isNotCreated) {
      if (response.body.isNotEmpty) throw DomainException.fromJson(jsonDecode(response.body));
      throw throw Exception('ERROR: Contacts HTTP POST - ${response.statusCode}');
    }
    return ContactMeans.fromJson(jsonDecode(response.body));
  }

  @override
  Future<ContactMeans> put(ContactMeans? contactMeans) async {
    final ContactMeans contactMeansCloned = ContactMeans.clone(contactMeans);
    contactMeansCloned.contact = Contact(contactMeans?.contact?.id, '', '');
    final response = await http.put(Uri.http(_preference.httpHostURL, '/contacts/book/mean'),
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, 
        body: jsonEncode(contactMeansCloned.toJson()));
    final bool isNotUpdated = response.statusCode != 200;
    if (isNotUpdated) {
      if (response.body.isNotEmpty) throw DomainException.fromJson(jsonDecode(response.body));
      throw throw throw Exception('ERROR: Contacts HTTP PUT - ${response.statusCode}');
    }
    return ContactMeans.fromJson(jsonDecode(response.body));
  }

  @override
  Future<bool> remove(ContactMeans? contactMeans) async {
    final ContactMeans contactMeansCloned = ContactMeans.clone(contactMeans);
    contactMeansCloned.contact = Contact(contactMeans?.contact?.id, '', '');
    final response = await http.delete(Uri.http(_preference.httpHostURL, '/contacts/book/mean/'),
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, 
        body: jsonEncode(contactMeansCloned.toJson()));
    final bool isNotRemoved = response.statusCode != 200;
    if (isNotRemoved) {
      if (response.body.isNotEmpty) throw DomainException.fromJson(jsonDecode(response.body));
      throw Exception('ERROR: Contact Means HTTP DELETE - ${response.statusCode}');
    }
    return true;
  }
}
