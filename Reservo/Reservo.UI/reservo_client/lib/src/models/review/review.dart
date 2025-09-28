import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  String? comment;
  int? id;

  @JsonKey(fromJson: _ratingFromJson)
  int? rating;

  @JsonKey(fromJson: _fromJsonDate, toJson: _toJsonDate)
  DateTime? createdAt;

  String? username;
  String? eventName;

  Review({
    this.comment,
    this.id,
    this.rating,
    this.createdAt,
    this.username,
    this.eventName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  // Safe DateTime parser
  static DateTime? _fromJsonDate(dynamic date) {
    if (date == null) return null;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  static String? _toJsonDate(DateTime? date) {
    return date?.toIso8601String();
  }

  // Safe rating parser
  static int? _ratingFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
