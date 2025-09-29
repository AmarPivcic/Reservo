// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_request_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueRequestInsert _$VenueRequestInsertFromJson(Map<String, dynamic> json) =>
    VenueRequestInsert(
      venueName: json['venueName'] as String,
      cityName: json['cityName'] as String,
      address: json['address'] as String,
      capacity: (json['capacity'] as num).toInt(),
      description: json['description'] as String?,
      allowedCategories: json['allowedCategories'] as String,
    );

Map<String, dynamic> _$VenueRequestInsertToJson(VenueRequestInsert instance) =>
    <String, dynamic>{
      'venueName': instance.venueName,
      'cityName': instance.cityName,
      'address': instance.address,
      'capacity': instance.capacity,
      'description': instance.description,
      'allowedCategories': instance.allowedCategories,
    };
