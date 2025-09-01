import 'package:flutter/material.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';

class PreviousEventsScreen extends StatefulWidget {
const PreviousEventsScreen({super.key});

  @override
  State<PreviousEventsScreen> createState() => _PreviousEventsScreenState();
}

class _PreviousEventsScreenState extends State<PreviousEventsScreen> {
  @override
  Widget build(BuildContext context) {
     return MasterScreen(
      showBackButton: false,
      child: Center(
        child: Text(
          "Previous Events",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}