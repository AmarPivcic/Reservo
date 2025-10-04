import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_admin/src/providers/auth_provider.dart';
import 'package:reservo_admin/src/screens/cities_screen.dart';
import 'package:reservo_admin/src/screens/edit_account_screen.dart';
import 'package:reservo_admin/src/screens/home_screen.dart';
import 'package:reservo_admin/src/screens/pending_organizers_screen.dart';
import 'package:reservo_admin/src/screens/users_screen.dart';
import 'package:reservo_admin/src/screens/venue_requests_screen.dart';
import 'package:reservo_admin/src/screens/venues_screen.dart';


class MasterScreen extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final bool showMyAccountButton;
  final bool actions;

  MasterScreen({super.key, required this.child, this.showBackButton = false, this.showMyAccountButton = true, this.actions = true});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                'lib/src/assets/images/LogoLight.png',
                height: 45,
                fit: BoxFit.cover,
                ),
                SizedBox(width: 20),
                Text("Reservo", 
                style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            if(actions)
              Row(
                children:[
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  icon: const Icon(Icons.category, color: Colors.white),
                  label: const Text("Categories", style: TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CitiesScreen()),
                    );
                  },
                  icon: const Icon(Icons.location_city, color: Colors.white),
                  label: const Text("Cities", style: TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VenuesScreen()),
                    );
                  },
                  icon: const Icon(Icons.stadium, color: Colors.white),
                  label: const Text("Venues", style: TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VenueRequestsScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_location, color: Colors.white),
                  label: const Text("Venue Requests", style: TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UsersScreen()),
                    );
                  },
                  icon: const Icon(Icons.people, color: Colors.white),
                  label: const Text("Users", style: TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PendingOrganizersScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text("Pending organizers", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
              
            if (authProvider.isLoggedIn && showMyAccountButton)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditAccountScreen()),
                  );
                },
                icon: const Icon(Icons.account_circle, color: Colors.white),
                label: const Text("My account", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: child,
    );
  }
}