import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_admin/src/providers/user_provider.dart';
import 'package:reservo_admin/src/screens/master_screen.dart';

class PendingOrganizersScreen extends StatefulWidget {
  const PendingOrganizersScreen({super.key});

  @override
  State<PendingOrganizersScreen> createState() => _PendingOrganizersScreenState();
}

class _PendingOrganizersScreenState extends State<PendingOrganizersScreen> {
  bool showingActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<UserProvider>(context, listen: false).getPendingOrganizers();
    });
  }

  Future<void> _toggleUserStatus(BuildContext context, int id, bool isActive) async {
    final provider = Provider.of<UserProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm"),
        content: Text("Are you sure you want to ${isActive ? "Deactivate" : "Activate"} this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirm == true) {
      await provider.activateOrganizer(id);
    }
  }

  Widget _buildUserRow(BuildContext context, UserProvider provider, int index) {
    final user = provider.users[index];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade700,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${user.name} ${user.surname}", style: const TextStyle(fontSize: 16)),
              Text("Username: ${user.username}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text("Created at: ${user.dateCreated}", style: const TextStyle(fontSize: 14, color: Colors.grey))
            ],
          ),
          Row(
            children: [
              Text(user.active! ? "Active" : "Pending",
                  style: TextStyle(
                    color: user.active! ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _toggleUserStatus(context, user.id, user.active!),
                
                child: Text(user.active! ? "Deactivate" : "Activate"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade800,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pending Organizers",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                  
                      ...List.generate(provider.users.length,
                          (index) => _buildUserRow(context, provider, index)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
