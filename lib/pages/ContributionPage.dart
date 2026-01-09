import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContributionPage extends StatefulWidget {
  const ContributionPage({super.key});

  @override
  State<ContributionPage> createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final totalAreaController = TextEditingController();
  final totalUnitsController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    totalAreaController.dispose();
    totalUnitsController.dispose();
    bedroomsController.dispose();
    bathroomsController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/properties'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': titleController.text,
          'location': locationController.text,
          'total_area': int.parse(totalAreaController.text),
          'total_units': int.parse(totalUnitsController.text),
          'bedrooms': int.parse(bedroomsController.text),
          'bathrooms': int.parse(bathroomsController.text),
          'price': int.parse(priceController.text),
          'description': descriptionController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showMessage('Property submitted successfully!');
        _clearForm();
      } else {
        _showMessage('Failed to submit property', isError: true);
      }
    } catch (e) {
      _showMessage('Error submitting property', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    titleController.clear();
    locationController.clear();
    totalAreaController.clear();
    totalUnitsController.clear();
    bedroomsController.clear();
    bathroomsController.clear();
    priceController.clear();
    descriptionController.clear();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF32CD32),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contribute Property',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Your Property',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: titleController,
                label: 'Property Title',
                hint: 'e.g., Luxury Villa in Banani',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Title is required';
                  return null;
                },
              ),
              _buildInputField(
                controller: locationController,
                label: 'Location',
                hint: 'e.g., Banani, Dhaka',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Location is required';
                  return null;
                },
              ),
              _buildInputField(
                controller: totalAreaController,
                label: 'Total Area (sq ft)',
                hint: 'e.g., 4500',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Area is required';
                  if (int.tryParse(value!) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              _buildInputField(
                controller: totalUnitsController,
                label: 'Total Units',
                hint: 'e.g., 1',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Units is required';
                  if (int.tryParse(value!) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              _buildInputField(
                controller: bedroomsController,
                label: 'Bedrooms per Unit',
                hint: 'e.g., 4',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Bedrooms is required';
                  if (int.tryParse(value!) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              _buildInputField(
                controller: bathroomsController,
                label: 'Bathrooms per Unit',
                hint: 'e.g., 3',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Bathrooms is required';
                  if (int.tryParse(value!) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              _buildInputField(
                controller: priceController,
                label: 'Price (৳)',
                hint: 'e.g., 4500000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Price is required';
                  if (int.tryParse(value!) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              _buildInputField(
                controller: descriptionController,
                label: 'Description',
                hint: 'Describe your property...',
                maxLines: 4,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Description is required';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32CD32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Property',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.black54),
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.home_work, color: Color(0xFF32CD32)),
          filled: true,
          fillColor: Colors.grey[100],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF32CD32), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}
