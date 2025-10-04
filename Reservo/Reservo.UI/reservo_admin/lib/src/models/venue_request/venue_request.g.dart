// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueRequest _$VenueRequestFromJson(Map<String, dynamic> json) => VenueRequest(
      id: (json['id'] as num).toInt(),
      organizerName: json['organizerName'] as String?,
      venueName: json['venueName'] as String,
      cityName: json['cityName'] as String,
      address: json['address'] as String,
      capacity: (json['capacity'] as num).toInt(),
      description: json['description'] as String?,
      suggestedCategories: json['suggestedCategories'] as String?,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      allowedCategoryIds: (json['allowedCategoryIds'] as List<dynamic>).map((e) => e as int).toList(),

    );

Map<String, dynamic> _$VenueRequestToJson(VenueRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizerName': instance.organizerName,
      'venueName': instance.venueName,
      'cityName': instance.cityName,
      'address': instance.address,
      'capacity': instance.capacity,
      'description': instance.description,
      'suggestedCategories': instance.suggestedCategories,
      'allowedCategoryIds': instance.allowedCategoryIds,
      'state': instance.state,
      'createdAt': instance.createdAt.toIso8601String(),
    };
