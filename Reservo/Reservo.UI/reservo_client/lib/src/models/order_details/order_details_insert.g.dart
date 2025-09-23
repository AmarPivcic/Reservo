// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_details_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailsInsert _$OrderDetailsInsertFromJson(Map<String, dynamic> json) =>
    OrderDetailsInsert(
      ticketTypeId: (json['ticketTypeId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderDetailsInsertToJson(OrderDetailsInsert instance) =>
    <String, dynamic>{
      'ticketTypeId': instance.ticketTypeId,
      'quantity': instance.quantity,
    };
