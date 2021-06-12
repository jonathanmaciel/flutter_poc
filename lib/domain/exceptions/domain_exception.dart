import 'package:flutter_poc/domain/exceptions/contact_means_main_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_name_equal_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_means_single_removed_exception.dart';
import 'package:flutter_poc/domain/exceptions/contact_name_equal_exception.dart';

abstract class DomainException implements Exception {

  const DomainException(this.message);

  factory DomainException.fromJson(Map<String, dynamic> json) {
    final int? status = json['status'] as int?;
    switch (status) {
      case ContactMeansMainRemovedException.code: return const ContactMeansMainRemovedException();
      case ContactMeansSingleRemovedException.code: return const ContactMeansSingleRemovedException();
      case ContactNameEqualException.code: return const ContactNameEqualException();
      case ContactMeansNameEqualException.code: return const ContactMeansNameEqualException();
      default: throw Exception(json['message']);
    }
  }

  final String message;
}
