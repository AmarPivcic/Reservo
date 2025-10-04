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
      suggestedCategories: json['suggestedCategories'] as String?,
      allowedCategoryIds: (json['allowedCategoryIds'] as List<dynamic>).map((e) => e as int).toList(),

    );

Map<String, dynamic> _$VenueRequestInsertToJson(VenueRequestInsert instance) =>
    <String, dynamic>{
      'venueName': instance.venueName,
      'cityName': instance.cityName,
      'address': instance.address,
      'capacity': instance.capacity,
      'description': instance.description,
      'suggestedCategories': instance.suggestedCategories,
      'allowedCategoryIds': instance.allowedCategoryIds,
    };
