import 'package:json_annotation/json_annotation.dart';

part 'city_insert.g.dart';

@JsonSerializable()
class CityInsert{
  String name;

  CityInsert(
    this.name
  );

  factory CityInsert.fromJson(Map<String, dynamic> json) => _$CityInsertFromJson(json);

  Map<String, dynamic> toJson() => _$CityInsertToJson(this);
}