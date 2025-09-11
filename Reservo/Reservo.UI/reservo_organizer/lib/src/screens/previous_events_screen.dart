import 'package:flutter/material.dart';
import 'package:reservo_organizer/src/screens/home_screen.dart';
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
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.event, color: Colors.white),
          label: const Text("Events", style: TextStyle(color: Colors.white)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const PreviousEventsScreen()),
            );
          },
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text("Previous Events", style: TextStyle(color: Colors.white)),
        ),
      ],
      child: Center(
        child: Text(
          "Previous Events",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}