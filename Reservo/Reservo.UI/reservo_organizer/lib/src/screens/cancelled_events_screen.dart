import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/event_list_screen.dart';

class CancelledEventsScreen extends StatefulWidget {
const CancelledEventsScreen({super.key});

  @override
  State<CancelledEventsScreen> createState() => _CancelledEventsScreenState();
}

class _CancelledEventsScreenState extends State<CancelledEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ep = context.read<EventProvider>();
      ep.getEvents(state: "cancelled");
    });
}

  @override
    Widget build(BuildContext context) {
      return const EventListScreen(
        title: "Cancelled Events",
        state: "cancelled",
      );
    }
}