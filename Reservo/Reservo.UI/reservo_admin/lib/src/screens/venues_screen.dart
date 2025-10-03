import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reservo_admin/src/models/venue/venue_insert_update.dart';
import 'package:reservo_admin/src/providers/city_provider.dart';
import 'package:reservo_admin/src/providers/category_provider.dart';
import 'package:reservo_admin/src/providers/venue_provider.dart';
import 'package:reservo_admin/src/screens/master_screen.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<VenueProvider>(context, listen: false).getVenues();
      await Provider.of<CityProvider>(context, listen: false).getCities();
      await Provider.of<CategoryProvider>(context, listen: false).getCategories();
    });
  }

  void _showVenueDialog({
    VenueInsertUpdate? initialData,
    int? venueId,
    required Future<void> Function(VenueInsertUpdate dto) onSubmit,
  }) {
    final venueProvider = Provider.of<VenueProvider>(context, listen: false);
    final cityProvider = Provider.of<CityProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    final _formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: initialData?.name ?? "");
    final addressController = TextEditingController(text: initialData?.address ?? "");
    final capacityController = TextEditingController(
        text: initialData?.capacity != null ? initialData!.capacity.toString() : "");
    final descriptionController = TextEditingController(text: initialData?.description ?? "");

    int? selectedCityId = initialData?.cityId ??
        (cityProvider.cities.isNotEmpty ? cityProvider.cities.first.id : null);

    List<int> selectedCategoryIds = List<int>.from(initialData?.categoryIds ?? []);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(venueId == null ? "Add Venue" : "Edit Venue"),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Name is required" : null,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Address"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Address is required" : null,
                      ),
                      TextFormField(
                        controller: capacityController,
                        decoration: const InputDecoration(labelText: "Capacity"),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Capacity is required";
                          if (int.tryParse(val) == null) return "Capacity must be a number";
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: "Description (optional)"),
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedCityId,
                        decoration: const InputDecoration(labelText: "City"),
                        items: cityProvider.cities
                            .map((city) => DropdownMenuItem(
                                  value: city.id,
                                  child: Text(city.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          selectedCityId = value!;
                        },
                        validator: (_) => selectedCityId == null ? "Please select a city" : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Categories", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Column(
                        children: categoryProvider.categories.map((cat) {
                          final isSelected = selectedCategoryIds.contains(cat.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(cat.name),
                            activeColor: Colors.green.shade600,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedCategoryIds.add(cat.id);
                                } else {
                                  selectedCategoryIds.remove(cat.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (selectedCategoryIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select at least one category")),
                        );
                        return;
                      }

                      final dto = VenueInsertUpdate(
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        capacity: int.parse(capacityController.text.trim()),
                        description: descriptionController.text.trim(),
                        cityId: selectedCityId!,
                        categoryIds: selectedCategoryIds,
                      );

                      await onSubmit(dto);
                      if (context.mounted) Navigator.pop(context);
                      venueProvider.getVenues();
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(int venueId, String venueName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$venueName'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<VenueProvider>(context, listen: false);
              final result = await provider.deleteVenue(venueId);
              if (result == "OK") {
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

  Widget _buildVenueRow(VenueProvider provider, int index) {
    final venue = provider.venues[index];
    final city = Provider.of<CityProvider>(context, listen: false)
    .cities
    .firstWhere(
      (c) => c.name.trim().toLowerCase() == (venue.cityName ?? "").trim().toLowerCase(),
      orElse: () => Provider.of<CityProvider>(context, listen: false).cities.first,
    );
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: const TextStyle(fontSize: 18, color: Colors.white)),
                Text(venue.address,
                    style: const TextStyle(fontSize: 14, color: Colors.white70)),
                Text("Capacity: ${venue.capacity}",
                    style: const TextStyle(fontSize: 14, color: Colors.white70)),
                if (venue.cityName != null)
                  Text("City: ${venue.cityName}",
                      style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  final initial = VenueInsertUpdate(
                    name: venue.name,
                    address: venue.address,
                    capacity: venue.capacity,
                    description: venue.description,
                    cityId: city.id,
                    categoryIds: venue.categories.map((c) => c.id).toList(),
                  );

                  _showVenueDialog(
                    initialData: initial,
                    venueId: venue.id,
                    onSubmit: (dto) => Provider.of<VenueProvider>(context, listen: false)
                        .updateVenue(venue.id, dto),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(venue.id, venue.name),
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
      child: Consumer<VenueProvider>(
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
                      const Text(
                        "Venues",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(provider.venues.length,
                          (index) => _buildVenueRow(provider, index)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showVenueDialog(
                          onSubmit: (dto) => Provider.of<VenueProvider>(context, listen: false)
                              .insertVenue(dto),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text("Add New Venue"),
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
