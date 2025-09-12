import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/event_list_screen.dart';

class DraftEventsScreen extends StatefulWidget {
const DraftEventsScreen({super.key});

  @override
  State<DraftEventsScreen> createState() => _DraftEventsScreenState();
}

class _DraftEventsScreenState extends State<DraftEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ep = context.read<EventProvider>();
      ep.getEvents(state: "draft");
    });
}

  @override
    Widget build(BuildContext context) {
      return const EventListScreen(
        title: "Draft Events",
        state: "draft",
      );
    }
}