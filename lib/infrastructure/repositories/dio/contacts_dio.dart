import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:flutter_poc/domain/exceptions/domain_exception.dart';
import 'package:flutter_poc/domain/repositories/contacts.dart';
import 'package:flutter_poc/infrastructure/preference.dart';
import 'package:injectable/injectable.dart';

@Named("contacts")
@Singleton(as: Contacts)
@Environment('REMOTE_DIO')
class ContactsDio implements Contacts {

  const ContactsDio(@Named('preference') this._preference);

  final Preference _preference;

  @override
  Future<List<Contact>> list() async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.get('http://${_preference.httpHostURL}/contacts/book');
      final List<dynamic> responseBody = jsonDecode(response.data);
      return responseBody.map((responseBodyItem) => Contact.fromJson(responseBodyItem)).toList();
    } on DioError catch(e) {
      throw Exception('ERROR: Contacts HTTP GET - ${e.response?.statusCode}');
    }
  }

  @override
  Future<Contact> item(int? id) async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final Response<String> response = await dio.get('http://${_preference.httpHostURL}/contacts/book/$id');
      return Contact.fromJson(jsonDecode(response.data??'{}'));
    } on DioError catch (e) {
      throw Exception('ERROR: Contacts HTTP GET - ${e.response?.statusCode}');
    }
  }

  @override
  Future<List<Contact>> listNames(String? name) => throw Exception('no http impl.');

  @override
  Future<Contact> post(Contact? contact) async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.post('http://${_preference.httpHostURL}/contacts/book',
          data: jsonEncode(contact?.toJson()));
      return Contact.fromJson(jsonDecode(response.data??'{}'));
    } on DioError catch (e) {
      if (e.response != null) throw DomainException.fromJson(jsonDecode(e.response.toString()));
      throw Exception('ERROR: Contacts HTTP POST - ${e.response?.statusCode}');
    }
  }

  @override
  Future<Contact> put(Contact? contact) async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      final response = await dio.put('http://${_preference.httpHostURL}/contacts/book',
          data: jsonEncode(contact?.toJson()));
      return Contact.fromJson(jsonDecode(response.data??'{}'));
    } on DioError catch (e) {
      if (e.response != null) throw DomainException.fromJson(jsonDecode(e.response.toString()));
      throw Exception('ERROR: Contacts HTTP PUT - ${e.response?.statusCode}');
    }
  }

  @override
  Future<bool> delete(Contact contact) async {
    final Dio dio = Dio();
    dio.options.headers['Content-type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    try {
      await dio.delete('http://${_preference.httpHostURL}/contacts/book',
          data: jsonEncode(contact.toJson()));
      return true;
    } on DioError catch (e) {
      if (e.response != null) throw DomainException.fromJson(jsonDecode(e.response.toString()));
      throw Exception('ERROR: Contacts HTTP DELETE - ${e.response?.statusCode}');
    }
  }
}
