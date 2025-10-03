import 'package:json_annotation/json_annotation.dart';

part 'category_insert.g.dart';

@JsonSerializable()
class CategoryInsert {
  String name;
  String? image;


  CategoryInsert(
    this.name,
    this.image
  );

  factory CategoryInsert.fromJson(Map<String, dynamic> json) => _$CategoryInsertFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryInsertToJson(this);
}