import 'package:flutter/material.dart';
import 'package:reservo_client/src/models/ticket_type/ticket_type.dart';
import 'package:reservo_client/src/screens/confirm_payment_screen.dart';
import 'package:reservo_client/src/screens/master_screen.dart';

class BuyTicketsScreen extends StatefulWidget {
  final List<TicketType> ticketTypes;
  const BuyTicketsScreen({super.key, required this.ticketTypes});

  @override
  State<BuyTicketsScreen> createState() => _BuyTicketsScreenState();
}

class _BuyTicketsScreenState extends State<BuyTicketsScreen> {
  late Map<int, int> selectedQuantities;

  @override
  void initState() {
    super.initState();
    selectedQuantities = {
      for (var t in widget.ticketTypes) t.id: 0,
    };
  }

  void _incrementQuantity(TicketType ticketType) {
    setState(() {
      int current = selectedQuantities[ticketType.id] ?? 0;
      int maxAllowed = ticketType.quantity > 10 ? 10 : ticketType.quantity;
      if (current < maxAllowed) {
        selectedQuantities[ticketType.id] = current + 1;
      }
    });
  }

  void _decrementQuantity(TicketType ticketType) {
    setState(() {
      int current = selectedQuantities[ticketType.id] ?? 0;
      if (current > 0) {
        selectedQuantities[ticketType.id] = current - 1;
      }
    });
  }  
  
@override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "Select Tickets",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.ticketTypes.length,
              itemBuilder: (context, index) {
                final ticketType = widget.ticketTypes[index];
                final selected = selectedQuantities[ticketType.id] ?? 0;
                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticketType.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (ticketType.description != null)
                              Text(
                                ticketType.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              "€${ticketType.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ticketType.quantity == 0
                                ? const Text(
                                    "Sold out",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                _decrementQuantity(ticketType),
                                            icon: const Icon(Icons.remove),
                                          ),
                                          Text(
                                            "$selected",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _incrementQuantity(ticketType),
                                            icon: const Icon(Icons.add),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Available: ${ticketType.quantity}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
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
                onPressed: () {
                  final selectedTickets = widget.ticketTypes
                      .where((t) => (selectedQuantities[t.id] ?? 0) > 0)
                      .map((t) => {
                            "ticketTypeId": t.id,
                            "quantity": selectedQuantities[t.id],
                          })
                      .toList();
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                    builder: (_) => ConfirmPaymentScreen(selectedTickets: selectedTickets),
                    ),
                  );
                },
                child: const Text("Continue to Payment"),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}