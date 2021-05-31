import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.means.g.dart';

@JsonSerializable()
class ContactMeans {

  int? id;
  
  String? name;
  
  String? value;
  
  String? description;
  
  bool? isMain;
  
  Contact? contact;

  ContactMeans(this.id, this.name, this.value, this.description, this.isMain);

  factory ContactMeans.fromJson(Map<String, dynamic> json) => _$ContactMeansFromJson(json);

  factory ContactMeans.newInstance(Contact? contact) {
    final ContactMeans _instance = ContactMeans(0, '', '', '', false);
    _instance.contact = contact;
    return _instance;
  }

  factory ContactMeans.clone(ContactMeans? contactMeans) {
    return ContactMeans(contactMeans?.id, contactMeans?.name, contactMeans?.value, 
        contactMeans?.description, contactMeans?.isMain);
  }

  Map<String, dynamic> toJson() => _$ContactMeansToJson(this);
}
