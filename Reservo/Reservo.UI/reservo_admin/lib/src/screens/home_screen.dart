import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reservo_admin/src/models/category/category_insert.dart';
import 'package:reservo_admin/src/providers/category_provider.dart';
import 'package:reservo_admin/src/screens/master_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).getCategories();
    });
  }

  void _showCategoryDialog({
    String? initialName,
    String? initialImage,
    int? categoryId,
    required Future<String> Function(String name, String? image) onSubmit,
  }) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController =
        TextEditingController(text: initialName ?? '');
    _base64Image = initialImage;
    _selectedImage = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(categoryId != null ? "Edit Category" : "Add New Category"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Category Name"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required field" : null,
                  ),
                  const SizedBox(height: 12),
                  _base64Image != null
                      ? Image.memory(
                          base64Decode(_base64Image!),
                          height: 100,
                        )
                      : const SizedBox(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        _selectedImage = File(pickedFile.path);
                        final bytes = await _selectedImage!.readAsBytes();
                        _base64Image = base64Encode(bytes);
                        setStateDialog(() {});
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Pick Image"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Close"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final result =
                        await onSubmit(_nameController.text, _base64Image);
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
          );
        });
      },
    );
  }

  void _showDeleteDialog(int categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$categoryName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<CategoryProvider>(context, listen: false);
              final result = await provider.deleteCategory(categoryId);
              if (result == "OK") {
                await provider.getCategories();
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

  Widget _buildCategoryRow(CategoryProvider provider, int index) {
    final cat = provider.categories[index];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cat.image != null && cat.image!.isNotEmpty
                ? Image.memory(
                    base64Decode(cat.image!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[400],
                    child: const Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cat.name,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () {
              _showCategoryDialog(
                initialName: cat.name,
                initialImage: cat.image,
                categoryId: cat.id,
                onSubmit: (name, image) async {
                  final provider =
                      Provider.of<CategoryProvider>(context, listen: false);
                  return await provider.updateCategory(cat.id, CategoryInsert(name, image));
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(cat.id, cat.name),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade800,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        "Categories",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(provider.categories.length, (index) {
                        return _buildCategoryRow(provider, index);
                      }),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showCategoryDialog(onSubmit: (name, image) async {
                            final provider =
                                Provider.of<CategoryProvider>(context, listen: false);
                            return await provider.insertCategory(CategoryInsert(name, image));
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add New Category"),
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
