import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reservo_client/src/models/category/category.dart';
import 'package:reservo_client/src/providers/event_provider.dart';
import 'package:reservo_client/src/screens/master_screen.dart';

class EventsScreen extends StatefulWidget {

  final Category categoryData;

  const EventsScreen({super.key, required this.categoryData});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ep = context.read<EventProvider>();
      ep.getEvents(
        categoryId: widget.categoryData.id
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    return MasterScreen(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(widget.categoryData.name, style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),),
            const SizedBox(height: 16),
            ...eventProvider.events.map((event) {
              final date = DateFormat('dd.MM.yyyy').format(event.startDate);
              final time = DateFormat('HH:mm').format(event.startDate);

              final remainingTickets = event.ticketTypes.fold<int>(
                0,  
                (sum, t) => sum + t.quantity,
              );

              double startingPrice = 0;
              if (event.ticketTypes.isNotEmpty) {
                startingPrice = event.ticketTypes
                    .map((t) => t.price)
                    .reduce((a, b) => a < b ? a : b);
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: event.image != null && event.image!.isNotEmpty
                          ? Image.memory(
                              base64Decode(event.image!),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                          : Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[700],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Venue: ${event.venueName ?? 'N/A'}"),
                          Text("City: ${event.cityName ?? 'N/A'}"),
                          Text("Date: $date"),
                          Text("Time: $time"),
                          Text("Remaining tickets: $remainingTickets"),
                          Text("Starting price: ${startingPrice.toStringAsFixed(2)} €"),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}