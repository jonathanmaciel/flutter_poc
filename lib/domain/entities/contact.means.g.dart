// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.means.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactMeans _$ContactMeansFromJson(Map<String, dynamic> json) {
  return ContactMeans(
    json['id'] as int?,
    json['name'] as String?,
    json['value'] as String?,
    json['description'] as String?,
    json['isMain'] as bool?,
  )..contact = json['contact'] == null
      ? null
      : Contact.fromJson(json['contact'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ContactMeansToJson(ContactMeans instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'description': instance.description,
      'isMain': instance.isMain,
      'contact': instance.contact,
    };
