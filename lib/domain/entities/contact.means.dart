import 'package:flutter_poc/domain/entities/contact.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.means.g.dart';

@JsonSerializable()
class ContactMeans {

  ContactMeans(this.id, this.name, this.value, this.description, this.isMain);

  factory ContactMeans.fromJson(Map<String, dynamic> json) => _$ContactMeansFromJson(json);

  factory ContactMeans.newInstanceFromJson(Contact? contact) {
    final ContactMeans _instance = ContactMeans(0, '', '', '', false);
    _instance.contact = contact;
    return _instance;
  }

  factory ContactMeans.copy(ContactMeans? contactMeans) {
    final ContactMeans _instance = ContactMeans(contactMeans?.id, contactMeans?.name,
        contactMeans?.value, contactMeans?.description, contactMeans?.isMain);
    if (contactMeans?.contact != null) {
      _instance.contact = Contact(contactMeans?.contact?.id,
          contactMeans?.contact?.name, contactMeans?.contact?.description);
    }
    return _instance;
  }

  int? id;
  
  String? name;
  
  String? value;
  
  String? description;
  
  bool? isMain;
  
  Contact? contact;

  Map<String, dynamic> toJson() => _$ContactMeansToJson(this);
}
