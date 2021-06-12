import 'package:equatable/equatable.dart';
import 'package:flutter_poc/domain/entities/contact.means.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact extends Equatable {

  Contact(this.id, this.name, this.description);

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  factory Contact.newInstanceWithOneContactMeans() {
    final Contact _contactWithOneContactMeans = Contact(0, '', '');
    _contactWithOneContactMeans.means = [ContactMeans(0, '', '', '', true)];
    return _contactWithOneContactMeans;
  }

  factory Contact.copy(Contact? c) {
    final Contact contact = Contact(c?.id, c?.name, c?.description);
    if (c?.means != null) {
      contact.means = [];
      for (int i = 0;  i < (c?.means?.length??0); i++) {
        final ContactMeans? item = c?.means?.elementAt(i);
        contact.means?.add(ContactMeans.copy(item));
      }
    }
    return contact;
  }

  factory Contact.copyWithoutContactMeans(Contact? c) => Contact(c?.id, c?.name, c?.description);

  int? id;
  
  String? name;
  
  String? description;
  
  String? label;

  List<ContactMeans>? means = [];

  bool isSingleContactMeans() => means?.length == 1;

  bool get isSingleContactMeansAndNew => isSingleContactMeans() && id == 0;

  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  List<Object?> get props => [id, name];
}
