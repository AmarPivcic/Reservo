import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';


class EventStatsScreen extends StatefulWidget {
  final int eventId;
  const EventStatsScreen({super.key, required this.eventId});

  @override
  State<EventStatsScreen> createState() => _EventStatsScreenState();
}

class _EventStatsScreenState extends State<EventStatsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      await Provider.of<EventProvider>(context, listen: false)
          .fetchOrdersForEvent(widget.eventId);
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<EventProvider>(context).orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Event Orders')),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : orders.isEmpty
        ? const Center(
            child: Text(
              'No orders for this event.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        : ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final stateColor =
                  order.state.toLowerCase() == 'active' ? Colors.green : Colors.red;
              final stateText =
                  '${order.state[0].toUpperCase()}${order.state.substring(1)}'; 

              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ordered by: ${order.orderedBy}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            stateText,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: stateColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...order.tickets.map((ticket) {
                        return Text(
                          '${ticket.quantity} x ${ticket.ticketTypeName} - ${ticket.quantity} x €${ticket.unitPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      Text(
                        'Total: €${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

    );

  }
}
