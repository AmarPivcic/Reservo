// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketTypeInsert _$TicketTypeInsertFromJson(Map<String, dynamic> json) =>
    TicketTypeInsert(
      json['name'] as String,
      json['description'] as String?,
      (json['price'] as num).toDouble(),
      (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$TicketTypeInsertToJson(TicketTypeInsert instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'quantity': instance.quantity,
    };
