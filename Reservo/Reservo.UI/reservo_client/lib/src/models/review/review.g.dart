// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      comment: json['comment'] as String?,
      id: (json['id'] as num?)?.toInt(),
      rating: Review._ratingFromJson(json['rating']),
      createdAt: Review._fromJsonDate(json['createdAt']),
      username: json['username'] as String?,
      eventName: json['eventName'] as String?,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'comment': instance.comment,
      'id': instance.id,
      'rating': instance.rating,
      'createdAt': Review._toJsonDate(instance.createdAt),
      'username': instance.username,
      'eventName': instance.eventName,
    };
