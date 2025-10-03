import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer_scanner/src/screens/master_screen.dart';
import 'package:reservo_organizer_scanner/src/screens/scan_screen.dart';

import '../providers/event_provider.dart';


class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ep = context.read<EventProvider>();
      ep.getEvents();
    });
  }

@override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();

    return MasterScreen(
      child: eventProvider.isLoading
        ? const Center(child: CircularProgressIndicator()) 
        : eventProvider.countOfEvents == 0 
        ? const Center(child: Text("No active events.", style: TextStyle(color: Colors.white24)))  
        : Column(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Active events",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                                builder: (_) => ScanScreen(eventId: event.id),
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
