import 'package:flutter_poc/domain/exceptions/contact_means_main_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_name_equal_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_single_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_name_equal_exception.dart';

abstract class DomainException implements Exception {

  final int? status;
  
  final String? message;

  DomainException(this.status, this.message);

  factory DomainException.fromJson(Map<String, dynamic> json) {
    final int? status = json['status'] as int?;
    switch (status) {
      case ContactMeansMainRemovedException.STATUS: return ContactMeansMainRemovedException();
      case ContactMeansSingleRemovedException.STATUS: return ContactMeansSingleRemovedException();
      case ContactNameEqualException.STATUS: return ContactNameEqualException();
      case ContactMeansNameEqualException.STATUS: return ContactMeansNameEqualException();
      default: throw Exception('domain exception status not found');
    }
  }
}
