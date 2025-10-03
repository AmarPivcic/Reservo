import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_admin/src/providers/city_provider.dart';
import 'package:reservo_admin/src/models/city/city_insert.dart';
import 'package:reservo_admin/src/screens/master_screen.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CityProvider>(context, listen: false).getCities();
    });
  }

  void _showCityDialog({
    String? initialName,
    required Future<String> Function(String name) onSubmit,
  }) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _controller =
        TextEditingController(text: initialName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(initialName != null ? "Edit City" : "Add New City"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            decoration: const InputDecoration(labelText: "City Name"),
            validator: (value) =>
                value == null || value.isEmpty ? "Required field" : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final result = await onSubmit(_controller.text);
                if (result == "OK") {
                  if (context.mounted) Navigator.of(ctx).pop();
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int cityId, String cityName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$cityName'?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<CityProvider>(context, listen: false);
              final result = await provider.deleteCity(cityId);

              if (result == "OK") {
                await provider.getCities();
                if (context.mounted) Navigator.of(ctx).pop();
              } else {
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildCityRow(CityProvider provider, int index) {
    final city = provider.cities[index];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(city.name, style: const TextStyle(fontSize: 18, color: Colors.white)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => _showCityDialog(
                  initialName: city.name,
                  onSubmit: (newName) async {
                    final provider =
                        Provider.of<CityProvider>(context, listen: false);
                    return await provider.editCity(city.id, CityInsert(newName));
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(city.id, city.name),
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
      child: Consumer<CityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

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
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        "Cities",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(provider.cities.length,
                          (index) => _buildCityRow(provider, index)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showCityDialog(
                          onSubmit: (name) async {
                            final provider =
                                Provider.of<CityProvider>(context, listen: false);
                            return await provider.insertCity(CityInsert(name));
                          },
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text("Add New City"),
                      ),
                      const SizedBox(height: 16),
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
