import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:reservo_client/src/models/order_details/order_details.dart';
import 'package:reservo_client/src/models/review/review.dart';
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
  Review? _orderReview;
  bool _isSubmittingReview = false;
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orderDetailFuture =
        Provider.of<OrderProvider>(context, listen: false).getOrderDetail(widget.orderId);
    _loadReview();
  }

  Future<void> _loadReview() async {
  final review = await context.read<OrderProvider>().getReviewForOrder(widget.orderId);
    if (review != null && review.rating != null) {
      setState(() {
        _orderReview = review;
        _selectedRating = review.rating!;
        _commentController.text = review.comment ?? "";
      });
    }
}

  Future<void> _submitReview(OrderDetails order) async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating"))
      );
      return;
    }

    setState(() => _isSubmittingReview = true);

    try {
      final review = await context.read<OrderProvider>().createReview(
        widget.orderId,
        order.eventId,
        _selectedRating,
        _commentController.text,
      );
      setState(() {
        _orderReview = review;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review: $e"))
      );
    } finally {
      setState(() => _isSubmittingReview = false);
    }
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

  Widget _buildReviewSection(OrderDetails order) {
    // if (order.state.toLowerCase() != "completed") {
    //   return const SizedBox.shrink();
    // }

  if (_orderReview != null && _orderReview!.rating != null) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        margin: const EdgeInsets.only(top: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RatingBarIndicator(
                rating: _orderReview!.rating!.toDouble(),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 30.0,
              ),
              const SizedBox(height: 8),
              if (_orderReview!.comment != null && _orderReview!.comment!.isNotEmpty)
                Text(
                  _orderReview!.comment!,
                  style: const TextStyle(fontSize: 16),
                )
              else
                const Text(
                  "No comment provided",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 3,
    margin: const EdgeInsets.only(top: 16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Leave a Review",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RatingBar.builder(
            initialRating: _selectedRating.toDouble(),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _selectedRating = rating.toInt();
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: "Comment (optional)",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmittingReview
                  ? null
                  : () => _submitReview(order),
              child: _isSubmittingReview
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Review"),
            ),
          ),
        ],
      ),
    ),
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
                  ),
                _buildReviewSection(order),
              ],
            ),
          );
        },
      ),
    );
  }
}

