import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reservo_client/src/models/event/event.dart';
import 'package:reservo_client/src/models/ticket_type/ticket_type.dart';
import 'package:reservo_client/src/providers/event_provider.dart';
import 'package:reservo_client/src/providers/ticket_type_provider.dart';
import 'package:reservo_client/src/screens/buy_tickets_screen.dart';
import 'package:reservo_client/src/screens/master_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event eventData;
  const EventDetailsScreen({super.key, required this.eventData});

  @override
  State<StatefulWidget> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<TicketType> _ticketTypes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ep = context.read<EventProvider>();
      ep.updateProfile(widget.eventData.id);
    });
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final ticketTypeProvider = context.read<TicketTypeProvider>();
    final ticketTypes =
        await ticketTypeProvider.getTicketTypesForEvent(widget.eventData.id);

    setState(() {
      _ticketTypes = ticketTypes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.eventData;
    final dateFormatter = DateFormat('dd.MM.yyyy HH:mm');

    return MasterScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              event.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (event.image != null && event.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(event.image!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.white,
                ),
              ),

            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text("Venue: ${event.venueName ?? "N/A"}"),
                Text("City: ${event.cityName ?? "N/A"}"),
                Text("Start: ${dateFormatter.format(event.startDate)}"),
                Text("End: ${dateFormatter.format(event.endDate)}"),
              ],
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Available Tickets",
                style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            ..._ticketTypes.map((ticket) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (ticket.description != null &&
                              ticket.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              ticket.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ] else ... [
                            const SizedBox(height: 4),
                            const Text(
                              "No description",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text("Tickets left: ${ticket.quantity}"),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        "${ticket.price.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightGreenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            ElevatedButton
            (onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => BuyTicketsScreen(ticketTypes: _ticketTypes),
                ),
              );
            },
             child: Text("Buy tickets")
            )
          ],
        ),
      ),
    );
  }
}
