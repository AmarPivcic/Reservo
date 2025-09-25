import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reservo_client/src/models/order_details/order_details.dart';
import 'package:reservo_client/src/screens/home_screen.dart';
import 'package:reservo_client/src/screens/master_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/order_provider.dart';
import 'package:provider/provider.dart';


class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<OrderDetails> _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailFuture =
        Provider.of<OrderProvider>(context, listen: false).getOrderDetail(widget.orderId);
  }

  Future<void> _showCancelDialog() async {
    final orderProvider = context.read<OrderProvider>();
    showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Cancel order"),
        content: const Text("Are you sure you want to cancel this order? You will be refunded shortly after."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () async {
              try {
                final confirmed = await orderProvider.cancelOrder(widget.orderId);

                if (confirmed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Order cancelled successfully."))
                  );
                } 

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Order cancellation failed: $e"))
                );
              }
            },
            child: const Text("Cancel order"),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: FutureBuilder<OrderDetails>(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Order not found"));
          }

          final order = snapshot.data!;
          final isActive = order.state.toLowerCase() == "active";
          final showTickets = isActive;
          final state = order.state.toLowerCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: order.eventImage != null && order.eventImage!.isNotEmpty
                            ? Image.memory(
                                base64Decode(order.eventImage!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[700],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.eventName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text("Venue: ${order.venue}"),
                            Text("City: ${order.city}"),
                            Text(
                                "Date: ${order.eventDate.toLocal().toString().split(' ')[0]}"),
                            const SizedBox(height: 4),
                            if (!isActive)
                              Text(
                                order.state.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: order.state == "cancelled"
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (showTickets)
                  ...order.tickets.map(
                    (ticketType) => Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticketType.ticketTypeName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                "Quantity: ${ticketType.quantity} x ${ticketType.unitPrice.toStringAsFixed(2)} €"),
                            Text(
                                "Total: ${ticketType.totalPrice.toStringAsFixed(2)} €"),
                            const SizedBox(height: 8),
                            Column(
                              children: ticketType.tickets.map((t) {
                                return Align(
                                  alignment: Alignment.center, 
                                  child: SizedBox(
                                    width: double.infinity, 
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            QrImageView(
                                              data: t.qrCode,
                                              version: QrVersions.auto,
                                              size: MediaQuery.of(context).size.width * 0.65,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              ticketType.ticketTypeName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              t.state.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: t.state == "active" ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                if(state == "active")
                  Center(
                  child: ElevatedButton(
                    child: const Text("Cancel order"),
                    onPressed: () {
                      _showCancelDialog();
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

