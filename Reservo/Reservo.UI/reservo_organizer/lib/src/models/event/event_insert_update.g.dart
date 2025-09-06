// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_insert_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventInsertUpdate _$EventInsertUpdateFromJson(Map<String, dynamic> json) =>
    EventInsertUpdate(
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      categoryId: (json['categoryId'] as num).toInt(),
      venueId: (json['venueId'] as num).toInt(),
      image: json['image'] as String?,
      ticketTypes: (json['ticketTypes'] as List<dynamic>)
          .map((e) => TicketTypeInsert.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventInsertUpdateToJson(EventInsertUpdate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'categoryId': instance.categoryId,
      'venueId': instance.venueId,
      'image': instance.image,
      'ticketTypes': instance.ticketTypes,
    };
