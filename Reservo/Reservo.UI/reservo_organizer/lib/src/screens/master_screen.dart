import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/providers/auth_provider.dart';
import 'package:reservo_organizer/src/screens/login_screen.dart';

class MasterScreen extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final List<Widget>? actions;

  MasterScreen({super.key, required this.child, this.showBackButton = false, this.actions});

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
            if(actions != null)
              Row(children: actions!),
              
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