import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_client/src/providers/category_provider.dart';
import 'package:reservo_client/src/screens/events_screen.dart';
import 'package:reservo_client/src/screens/master_screen.dart';

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
      final cp = context.read<CategoryProvider>();
      cp.getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return MasterScreen(
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(20),
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: categoryProvider.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...categoryProvider.categories.map((category) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: double.infinity,
                    child: Material(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventsScreen(categoryData: category),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: category.image != null &&
                                            category.image!.isNotEmpty
                                        ? Image.memory(
                                            base64Decode(category.image!),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'lib/src/assets/images/LogoLight.png',
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      )
    );
  }
}