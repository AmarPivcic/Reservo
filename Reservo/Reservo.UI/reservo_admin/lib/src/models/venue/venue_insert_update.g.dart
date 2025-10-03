// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_insert_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueInsertUpdate _$VenueInsertUpdateFromJson(Map<String, dynamic> json) =>
    VenueInsertUpdate(
      name: json['name'] as String,
      address: json['address'] as String,
      capacity: (json['capacity'] as num).toInt(),
      description: json['description'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
      categoryIds: (json['categoryIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$VenueInsertUpdateToJson(VenueInsertUpdate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'capacity': instance.capacity,
      'description': instance.description,
      'cityId': instance.cityId,
      'categoryIds': instance.categoryIds,
    };
