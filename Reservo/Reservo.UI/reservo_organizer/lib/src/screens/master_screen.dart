import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/providers/auth_provider.dart';
import 'package:reservo_organizer/src/screens/home_screen.dart';
import 'package:reservo_organizer/src/screens/login_screen.dart';
import 'package:reservo_organizer/src/screens/previous_events_screen.dart';

class MasterScreen extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  MasterScreen({super.key, required this.child, required this.showBackButton});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Reservo", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            if(authProvider.isLoggedIn)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
                ]
              ),
            if (authProvider.isLoggedIn)
              TextButton.icon(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: child,
    );
  }
}