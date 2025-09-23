import 'dart:convert';

import 'package:reservo_client/src/models/order/order.dart';
import 'package:reservo_client/src/models/order/order_insert.dart';
import 'package:reservo_client/src/models/order/user_order.dart';
import 'package:reservo_client/src/models/order_details/order_details.dart';
import 'package:reservo_client/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class OrderProvider extends BaseProvider<Order, OrderInsert>
{
  OrderProvider() : super('Order');

  Future<Order> createOrder(OrderInsert orderData) async {
    return insertResponse<Order, OrderInsert>(
      orderData,
      toJson: (d) => d.toJson(),
      fromJson: (json) => Order.fromJson(json),
    );
  }

   Future<bool> confirmOrder(int orderId) async {
    final response = await http.post(
      Uri.parse('${BaseProvider.baseUrl}/Order/$orderId/Confirm'),
      headers: await createHeaders(),
    );

    return response.statusCode == 200;
  }

  Future<List<UserOrder>> getUserOrders() async {
   final response = await http.get(
      Uri.parse('${BaseProvider.baseUrl}/Order/UserOrders'),
      headers: await createHeaders(),
    );

    if(response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserOrder.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load orders");
    }

  }

  Future<List<UserOrder>> getUserPreviousOrders() async {
    final response = await http.get(
      Uri.parse('${BaseProvider.baseUrl}/Order/UserPreviousOrders'),
      headers: await createHeaders(),
    );

    if(response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserOrder.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load previous orders");
    }
  }

  Future<OrderDetails> getOrderDetail(int orderId) async{
    final response = await http.get(
      Uri.parse('${BaseProvider.baseUrl}/Order/UserOrders/$orderId'),
      headers: await createHeaders(),
    );
    print(response.body);
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return OrderDetails.fromJson(data);;
    } else {
      throw Exception("Failed to load order data");
    }
  }


}

