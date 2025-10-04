import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_admin/src/models/venue_request/venue_request.dart';
import 'package:reservo_admin/src/models/venue_request/venue_request_insert.dart';
import 'package:reservo_admin/src/providers/category_provider.dart';
import 'package:reservo_admin/src/providers/venue_request_provider.dart';
import 'package:reservo_admin/src/screens/master_screen.dart';

class VenueRequestsScreen extends StatefulWidget {
  const VenueRequestsScreen({super.key});

  @override
  State<VenueRequestsScreen> createState() => _VenueRequestsScreenState();
}

class _VenueRequestsScreenState extends State<VenueRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<CategoryProvider>(context, listen: false).getCategories();
      await Provider.of<VenueRequestProvider>(context, listen: false).getVenueRequests();
    });
  }

  Future<void> _showRequestPopup(VenueRequest request) async {
    final _formKey = GlobalKey<FormState>();
    final cp = Provider.of<CategoryProvider>(context, listen: false);

    final venueNameController = TextEditingController(text: request.venueName);
    final cityNameController = TextEditingController(text: request.cityName);
    final addressController = TextEditingController(text: request.address);
    final capacityController = TextEditingController(text: request.capacity.toString());
    final descriptionController = TextEditingController(text: request.description ?? "");

    List<int> selectedCategoryIds = List<int>.from(request.allowedCategoryIds);

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Review Venue Request"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Organizer: ${request.organizerName ?? "-"}"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: venueNameController,
                          decoration: const InputDecoration(labelText: "Venue Name"),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        TextFormField(
                          controller: cityNameController,
                          decoration: const InputDecoration(labelText: "City Name"),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(labelText: "Address"),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        TextFormField(
                          controller: capacityController,
                          decoration: const InputDecoration(labelText: "Capacity"),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            final val = int.tryParse(v);
                            if (val == null || val <= 0) return "Must be > 0";
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: "Description (optional)"),
                        ),
                        const SizedBox(height: 8),
                        Text("Suggested Categories: ${request.suggestedCategories ?? "-"}"),
                        const SizedBox(height: 8),
                        const Text("Allowed Categories:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Column(
                          children: cp.categories.map((c) {
                            final isSelected = selectedCategoryIds.contains(c.id);
                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(c.name),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedCategoryIds.add(c.id);
                                  } else {
                                    selectedCategoryIds.remove(c.id);
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
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close")),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final updateDto = VenueRequestInsert(
                      venueName: venueNameController.text.trim(),
                      cityName: cityNameController.text.trim(),
                      address: addressController.text.trim(),
                      capacity: int.parse(capacityController.text.trim()),
                      state: "Rejected",
                      allowedCategoryIds: selectedCategoryIds,
                      suggestedCategories: request.suggestedCategories,
                    );

                    try {
                      await Provider.of<VenueRequestProvider>(context, listen: false)
                          .updateVenue(request.id, updateDto);
                      if (context.mounted) Navigator.of(ctx).pop();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Reject"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final updateDto = VenueRequestInsert(
                      venueName: venueNameController.text.trim(),
                      cityName: cityNameController.text.trim(),
                      address: addressController.text.trim(),
                      capacity: int.parse(capacityController.text.trim()),
                      state: "Accepted",
                      allowedCategoryIds: selectedCategoryIds,
                      suggestedCategories: request.suggestedCategories,
                    );

                    try {
                      await Provider.of<VenueRequestProvider>(context, listen: false)
                          .updateVenue(request.id, updateDto);
                      if (context.mounted) Navigator.of(ctx).pop();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Accept"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRequestRow(VenueRequest request) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showRequestPopup(request),
        child: Container(
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
                    Text("${request.venueName} - ${request.organizerName ?? "-"}",
                        style: const TextStyle(fontSize: 16, color: Colors.white)),
                    Text("Capacity: ${request.capacity}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("City: ${request.cityName ?? "-"}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Text(request.state, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Consumer<VenueRequestProvider>(
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
                        "Venue Requests",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (provider.venueRequests.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text("No venue requests"),
                        ),
                      ...provider.venueRequests
                          .map((req) => _buildRequestRow(req))
                          .toList(),
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
