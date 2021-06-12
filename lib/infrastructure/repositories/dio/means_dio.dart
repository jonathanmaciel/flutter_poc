import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';
import 'package:flutter_poc/domain/repositories/means.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:injectable/injectable.dart';

@Named("means") 
@Singleton(as: Means)
@Environment('REMOTE_DIO')
class MeansDio implements Means {

  const MeansDio(@Named('preference') this._preference);

  final Preference _preference;

  @override
  Future<List<ContactMeans>> list(Contact? contact) async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.get('http://${_preference.httpHostURL}/contacts/book/means/');
      final List<dynamic> responseBody = jsonDecode(response.data);
      return responseBody.map((dynamic responseBodyItem) => ContactMeans.fromJson(responseBodyItem)).toList();
    } on DioError catch(e) {
      throw Exception('ERROR: Contacts HTTP GET - ${e.response?.statusCode}');
    }
  }

  @override
  Future<List<ContactMeans>> listNames(ContactMeans? contactMeans) async => throw Exception('no http impl.');

  @override
  Future<ContactMeans> post(ContactMeans? contactMeans) async {
    final ContactMeans contactMeansCloned = ContactMeans.copy(contactMeans);
    contactMeansCloned.contact = Contact(contactMeans?.contact?.id, '', '');
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.post('http://${_preference.httpHostURL}/contacts/book/means',
          data: jsonEncode(contactMeansCloned.toJson()));
      return ContactMeans.fromJson(jsonDecode(response.data));
    } on DioError catch(e) {
      if (e.response != null) throw DomainException.fromJson(jsonDecode(e.response.toString()));
      throw Exception('ERROR: Contacts HTTP POST - ${e.response?.statusCode}');
    }
  }

  @override
  Future<ContactMeans> put(ContactMeans? contactMeans) async {
    final ContactMeans contactMeansCloned = ContactMeans.copy(contactMeans);
    contactMeansCloned.contact = Contact(contactMeans?.contact?.id, '', '');
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.put('http://${_preference.httpHostURL}/contacts/book/means',
          data: jsonEncode(contactMeansCloned.toJson()));
      return ContactMeans.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      if (e.response != null) throw DomainException.fromJson(jsonDecode(e.response.toString()));
      throw Exception('ERROR: Contacts HTTP PUT - ${e.response?.statusCode}');
    }
  }

  @override
  Future<bool> remove(ContactMeans? contactMeans) async {
    final ContactMeans contactMeansCloned = ContactMeans.copy(contactMeans);
    contactMeansCloned.contact = Contact(contactMeans?.contact?.id, '', '');
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      await dio.delete('http://${_preference.httpHostURL}/contacts/book/means',
          data: jsonEncode(contactMeansCloned.toJson()));
      return true;
    } on DioError catch (e) {
      if (e.response != null) throw DomainException.fromJson(jsonDecode(e.response.toString()));
      throw Exception('ERROR: Contacts HTTP DELETE - ${e.response?.statusCode}');
    }
  }
}
