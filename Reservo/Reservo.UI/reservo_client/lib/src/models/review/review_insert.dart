import 'package:json_annotation/json_annotation.dart';

part 'review_insert.g.dart';

@JsonSerializable()
class ReviewInsert{
  String? comment;
  int rating;
  int eventId;

  ReviewInsert({
    this.comment,
    required this.rating,
    required this.eventId
  });

  
  factory ReviewInsert.fromJson(Map<String, dynamic> json) => _$ReviewInsertFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewInsertToJson(this);
}