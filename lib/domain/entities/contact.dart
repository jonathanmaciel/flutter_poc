import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {

  int? id;
  
  String? name;
  
  String? description;
  
  String? label;

  List<ContactMeans>? means = [];

  Contact(this.id, this.name, this.description);

  bool isSingleContactMeans() => means?.length == 1;

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  factory Contact.newInstanceWithOneContactMeans() {
    Contact _contactWithOneContactMeans = Contact(0, '', '');
    _contactWithOneContactMeans.means = [ContactMeans(0, '', '', '', true)];
    return _contactWithOneContactMeans;
  }

  Map<String, dynamic> toJson() => _$ContactToJson(this);
}
