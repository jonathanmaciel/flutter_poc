import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@JsonSerializable()
class Setting {

  Setting(this.id, this.value);

  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);

  int? id;

  String? value;

  Map<String, dynamic> toJson() => _$SettingToJson(this);
}
