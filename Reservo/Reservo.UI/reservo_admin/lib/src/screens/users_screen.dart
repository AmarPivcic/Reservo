import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_admin/src/providers/user_provider.dart';
import 'package:reservo_admin/src/screens/master_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool showingActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<UserProvider>(context, listen: false).getActiveUsers();
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
      await provider.changeActiveStatus(id, showActive: showingActive);
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
          // Left side
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${user.name} ${user.surname}", style: const TextStyle(fontSize: 16)),
              Text("Username: ${user.username}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text("Role: ${user.role ?? 'N/A'}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),

          // Right side
          Row(
            children: [
              Text(user.active! ? "Active" : "Inactive",
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
                        "Users",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              setState(() => showingActive = true);
                              await provider.getActiveUsers();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showingActive ? Colors.blue : Colors.grey,
                            ),
                            child: const Text("Active Users", style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() => showingActive = false);
                              await provider.getInactiveUsers();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !showingActive ? Colors.blue : Colors.grey,
                            ),
                            child: const Text("Inactive Users", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // List of users
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
