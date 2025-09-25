// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetails _$OrderDetailsFromJson(Map<String, dynamic> json) => OrderDetails(
      orderId: (json['orderId'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      state: json['state'] as String,
      eventId: (json['eventId'] as num).toInt(),
      eventName: json['eventName'] as String,
      eventImage: json['eventImage'] as String?,
      venue: json['venue'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      city: json['city'] as String,
      tickets: (json['tickets'] as List<dynamic>)
          .map((e) => OrderTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderDetailsToJson(OrderDetails instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'totalAmount': instance.totalAmount,
      'state': instance.state,
      'eventId': instance.eventId,
      'eventName': instance.eventName,
      'eventImage': instance.eventImage,
      'venue': instance.venue,
      'eventDate': instance.eventDate.toIso8601String(),
      'city': instance.city,
      'tickets': instance.tickets.map((e) => e.toJson()).toList(),
    };
