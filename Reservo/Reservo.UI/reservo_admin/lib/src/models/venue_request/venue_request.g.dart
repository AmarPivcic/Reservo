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
      allowedCategories: json['allowedCategories'] as String,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      'allowedCategories': instance.allowedCategories,
      'state': instance.state,
      'createdAt': instance.createdAt.toIso8601String(),
    };
