import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/user/user.dart';
import 'package:reservo_organizer/src/models/user/user_update.dart';
import 'package:reservo_organizer/src/providers/auth_provider.dart';
import 'package:reservo_organizer/src/providers/city_provider.dart';
import 'package:reservo_organizer/src/providers/user_provider.dart';
import 'package:reservo_organizer/src/screens/login_screen.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {

  final _formKey = GlobalKey<FormState>();

  User? user;

  String? _username;
  String? _selectedGender;
  int? _cityId;
  File? _pickedImage;
  String? _userImage; 
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cp = context.read<CityProvider>();
      cp.getCities();

      final up = context.read<UserProvider>();
      up.getCurrentUser().then((value) {
        setState(() {
        user = value;
        _username = value.username;
        _nameController.text = value.name;
        _surnameController.text = value.surname;
        _emailController.text = value.email ?? '';
        _phoneController.text = value.phone ?? '';
        _addressController.text = value.address ?? '';
        _postalCodeController.text = value.postalCode ?? '';
        _selectedGender = value.gender;
        _cityId = value.cityId;
        _userImage = value.image;
        });
      });
    });
  }

@override
void dispose() {
  _nameController.dispose();
  _surnameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _addressController.dispose();
  _postalCodeController.dispose();
  super.dispose();
}

  Future<void> _pickImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      _pickedImage = file;
      _userImage = base64Image;
    });
  }
}

Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final dto = UserUpdate(
        username: _username,
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        address: _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        image: _userImage,
        cityId: _cityId,
      );

      try {
        final updated = await Provider.of<UserProvider>(context, listen: false).updateUser(dto);
        
        setState(() {
          user!.name = updated.name;
          user!.surname = updated.surname;
          user!.username = updated.username;
          user!.email = updated.email;
          user!.phone = updated.phone;
          user!.gender = updated.gender;
          user!.address = updated.address;
          user!.postalCode = updated.postalCode;
          user!.image = updated.image;
          user!.cityId = updated.cityId;
        });

        await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Saved"),
        content: const Text("User updated successfully."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))      
        ],
      )
    );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving changes: $e')),
        );
      }
    }
  }

  @override
    Widget build(BuildContext context) {
    final cityProvider = context.watch<CityProvider>();
    final authProvider = context.watch<AuthProvider>();

     return MasterScreen(
      showBackButton: false,
      showMyAccountButton: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center( // Center widget
          child: ConstrainedBox( // ConstrainedBox to limit width
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            height: 180,
                            width: 240,
                            fit: BoxFit.cover,
                          )
                        : (_userImage == null || _userImage!.isEmpty
                            ? Container(
                                height: 180,
                                width: 220,
                                color: Colors.grey[300],
                                child: const Icon(Icons.add_a_photo,
                                    size: 50, color: Colors.black54),
                              )
                            : Image.memory(
                                base64Decode(_userImage!),
                                height: 180,
                                width: 220,
                                fit: BoxFit.cover,
                              )),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(labelText: "Surname"),
                    validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!regex.hasMatch(v)) return "Invalid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      final regex = RegExp(r'^[0-9]+$');
                      if (!regex.hasMatch(v)) return "Numbers only";
                      if (v.length < 9) return "At least 9 digits";
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: "Address"),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(labelText: "Postal code"),
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final regex = RegExp(r'^[0-9]+$');
                        if (!regex.hasMatch(v)) return "Invalid postal code";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: ["Male", "Female", "Other"]
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                    decoration: const InputDecoration(labelText: "Gender"),
                    validator: (val) => val == null ? "Please select gender" : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: cityProvider.cities.any((c) => c.id == _cityId) ? _cityId : null,
                    items: cityProvider.cities
                        .map((c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _cityId = val),
                    decoration: const InputDecoration(labelText: "City"),
                    validator: (val) => val == null ? "Please select city" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
            ),
          ),
        ),
      ),
    );
    }
}