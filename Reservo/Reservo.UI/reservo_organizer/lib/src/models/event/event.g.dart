// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      state: json['state'] as String,
      categoryName: json['categoryName'] as String?,
      venueName: json['venueName'] as String?,
      cityName: json['cityName'] as String?,
      image: json['image'] as String?, 
      categoryId: (json['categoryId'] as num).toInt(),
      venueId: (json['venueId'] as num).toInt(),
      cityId: (json['cityId'] as num).toInt(),
       ticketTypes: (json['ticketTypes'] as List<dynamic>)
          .map((e) => TicketType.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'image': instance.image,
      'venueId': instance.venueId,
      'categoryId': instance.categoryId,
      'cityId': instance.cityId,
      'ticketTypes': instance.ticketTypes
    };
