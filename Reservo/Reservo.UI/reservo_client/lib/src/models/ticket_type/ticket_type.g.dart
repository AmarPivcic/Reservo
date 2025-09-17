// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketType _$TicketTypeFromJson(Map<String, dynamic> json) => TicketType(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['description'] as String?,
      (json['price'] as num).toDouble(),
      (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$TicketTypeToJson(TicketType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'quantity': instance.quantity,
    };
