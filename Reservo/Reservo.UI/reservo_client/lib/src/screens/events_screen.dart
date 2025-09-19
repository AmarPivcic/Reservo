import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reservo_client/src/models/category/category.dart';
import 'package:reservo_client/src/providers/event_provider.dart';
import 'package:reservo_client/src/screens/event_details_screen.dart';
import 'package:reservo_client/src/screens/master_screen.dart';

class EventsScreen extends StatefulWidget {
  final Category categoryData;

  const EventsScreen({super.key, required this.categoryData});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ep = context.read<EventProvider>();
      ep.getEvents(categoryId: widget.categoryData.id);
    });
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Event name"),
                      ),
                      TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: "City"),
                      ),
                      TextField(
                        controller: _venueController,
                        decoration: const InputDecoration(labelText: "Venue"),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? "No date selected"
                                  : "Date: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}",
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setModalState(() => _selectedDate = picked);
                              }
                            },
                            child: const Text("Pick date"),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final ep = context.read<EventProvider>();
                          ep.getEvents(
                            categoryId: widget.categoryData.id,
                            nameFilter: _nameController.text,
                            cityFilter: _cityController.text,
                            venueFilter: _venueController.text,
                            date: _selectedDate,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Apply"),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          _nameController.clear();
                          _cityController.clear();
                          _venueController.clear();
                          setModalState(() => _selectedDate = null);

                          final ep = context.read<EventProvider>();
                          ep.getEvents(categoryId: widget.categoryData.id);

                          Navigator.pop(context);
                        },
                        child: const Text("Clear filters"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();

    return MasterScreen(
      child: eventProvider.isLoading
        ? const Center(child: CircularProgressIndicator()) 
        : eventProvider.countOfEvents == 0 
        ? const Center(child: Text("No events in this category.", style: TextStyle(color: Colors.white24)))  
        : Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.categoryData.name,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _openFilters(context),
                  icon: const Icon(Icons.filter_list, size: 28),
                ),
              ],
            )
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                      child: Material(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (_) => EventDetailsScreen(eventData: event),
                              ),
                            );
                          },
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
                                        child: const Icon(Icons.image_not_supported,
                                            size: 50, color: Colors.white),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.name,
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
