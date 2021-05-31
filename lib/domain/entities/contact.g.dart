// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) {
  return Contact(
    json['id'] as int?,
    json['name'] as String?,
    json['description'] as String?,
  )
    ..label = json['label'] as String?
    ..means = (json['means'] as List<dynamic>?)
        ?.map((e) => ContactMeans.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'label': instance.label,
      'means': instance.means,
    };
