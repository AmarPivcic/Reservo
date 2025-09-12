import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/event_list_screen.dart';


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
    return const EventListScreen(
      title: "Active Events",
      state: "active",
    );
  }
}