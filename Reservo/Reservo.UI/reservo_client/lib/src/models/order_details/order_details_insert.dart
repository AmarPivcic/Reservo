import 'package:json_annotation/json_annotation.dart';

part 'order_details_insert.g.dart';

@JsonSerializable()
class OrderDetailsInsert{
  int ticketTypeId;
  int quantity;

  OrderDetailsInsert({
    required this.ticketTypeId,
    required this.quantity,
  });

  factory OrderDetailsInsert.fromJson(Map<String, dynamic> json) => _$OrderDetailsInsertFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsInsertToJson(this);
}