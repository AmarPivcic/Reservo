// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['description'] as String,
      DateTime.parse(json['startDate'] as String),
      DateTime.parse(json['endDate'] as String),
      json['state'] as String,
      json['categoryName'] ?? '' as String,
      json['venueName'] as String,
      json['cityName'] as String,
      json['image'] ?? '' as String
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'state': instance.state,
      'categoryName': instance.categoryName,
      'venueName': instance.venueName,
      'cityName': instance.cityName,
      'image' : instance.image
    };
