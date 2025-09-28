// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewInsert _$ReviewInsertFromJson(Map<String, dynamic> json) => ReviewInsert(
      comment: json['comment'] as String?,
      rating: (json['rating'] as num).toInt(),
      eventId: (json['eventId'] as num).toInt(),
    );

Map<String, dynamic> _$ReviewInsertToJson(ReviewInsert instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'rating': instance.rating,
      'eventId': instance.eventId,
    };
