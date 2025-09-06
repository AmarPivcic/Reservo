import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event eventData;
  const EventDetailsScreen({super.key, required this.eventData});

  @override
  State<StatefulWidget> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventDetailsScreen> {

  Future<void> _activateEvent() async{
  final ep = context.read<EventProvider>();
  ep.activateEvent(widget.eventData.id);
}

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      showBackButton: true,
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
              onPressed: widget.eventData.state == "active" ? null : _activateEvent,
              child: const Text("Activate event"),
              ),
            ],
          )
        ],
      ),
    );
  }
}