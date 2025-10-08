import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/event_list_screen.dart';


class EventStatsListScreen extends StatefulWidget {
const EventStatsListScreen({super.key});

  @override
  State<EventStatsListScreen> createState() => _EventStatsListScreenState();
}

class _EventStatsListScreenState extends State<EventStatsListScreen> {


@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ep = context.read<EventProvider>();
      ep.getEventsForStats();
    });
}

  @override
  Widget build(BuildContext context) {
    return const EventListScreen(
      title: "Orders for active and completed events",
      isStats: true, 
      state: 'stats',
    );
  }
}