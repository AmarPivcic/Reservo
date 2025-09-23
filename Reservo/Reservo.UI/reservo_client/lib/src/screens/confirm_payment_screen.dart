import 'package:flutter/material.dart';
import 'package:reservo_client/src/models/order/order_insert.dart';
import 'package:reservo_client/src/models/order_details/order_details_insert.dart';
import 'package:reservo_client/src/providers/order_provider.dart';
import 'package:reservo_client/src/providers/ticket_type_provider.dart';
import 'package:reservo_client/src/screens/home_screen.dart';
import 'package:reservo_client/src/screens/master_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

class ConfirmPaymentScreen extends StatefulWidget {
  final List<Map<String, int?>> selectedTickets;
  const ConfirmPaymentScreen({super.key, required this.selectedTickets});

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  final OrderProvider _orderProvider = OrderProvider();
  final TicketTypeProvider _ticketProvider = TicketTypeProvider();

  List<Map<String, dynamic>> ticketSummaries = [];
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
  }

  Future<void> _loadTicketDetails() async {
    double sum = 0;
    List<Map<String, dynamic>> summaries = [];

    for (var t in widget.selectedTickets) {
      final ticketType =
          await _ticketProvider.getTicketTypeById(t["ticketTypeId"]!);
      if (ticketType != null) {
        int qty = t["quantity"]!;
        double subtotal = ticketType.price * qty;
        sum += subtotal;

        summaries.add({
          "id": ticketType.id,
          "name": ticketType.name,
          "quantity": qty,
          "unitPrice": ticketType.price,
          "subtotal": subtotal,
        });
      }
    }

    setState(() {
      ticketSummaries = summaries;
      totalPrice = sum;
    });
  }

  Future<void> _startPayment() async {
    final orderInsert = OrderInsert(
      orderDetails: widget.selectedTickets
          .map((t) => OrderDetailsInsert(
                ticketTypeId: t["ticketTypeId"]!,
                quantity: t["quantity"]!,
              ))
          .toList(),
    );

    final order = await _orderProvider.createOrder(orderInsert);
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create order")),
      );
      return;
    }

    try {
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: order.stripeClientSecret,
          merchantDisplayName: "Reservo",
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();

      final confirmed = await _orderProvider.confirmOrder(order.id);
        if (confirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment successful! Order confirmed.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(
              "Payment succeeded, but confirming order failed.")),
          );
        }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          const Text(
            "Confirm Payment",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ticketSummaries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: ticketSummaries.length,
                    itemBuilder: (context, index) {
                      final t = ticketSummaries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text("${t["name"]} x${t["quantity"]}"),
                          subtitle: Text(
                              "€${t["unitPrice"].toStringAsFixed(2)} each"),
                          trailing: Text(
                            "€${t["subtotal"].toStringAsFixed(2)}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total: €${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _startPayment,
                      child: const Text("Pay"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}