// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Venue _$VenueFromJson(Map<String, dynamic> json) => Venue(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['address'] as String,
      (json['capacity'] as num).toInt(),
      json['description'] as String?,
      json['cityName'] as String,
    );

Map<String, dynamic> _$VenueToJson(Venue instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'capacity': instance.capacity,
      'description': instance.description,
      'cityName': instance.cityName,
    };
