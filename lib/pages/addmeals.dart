import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Addmeals extends StatefulWidget {
  const Addmeals({super.key});

  @override
  State<Addmeals> createState() => _AddmealsState();
}

class _AddmealsState extends State<Addmeals> {
  final _mealsFormkey = GlobalKey<FormState>();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController itemCtrl = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Add New Meal",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _mealsFormkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Meal Details"),
                  const SizedBox(height: 12),
                  _buildCardWrapper([
                    _buildCustomTextField(
                      controller: titleCtrl,
                      label: "Meal Title",
                      hint: "e.g. Breakfast, Dinner",
                      icon: Icons.restaurant_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildCustomTextField(
                      controller: timeCtrl,
                      label: "Serving Time",
                      hint: "e.g. 8:00 AM - 10:00 AM",
                      icon: Icons.access_time,
                    ),
                    const SizedBox(height: 20),
                    _buildCustomTextField(
                      controller: priceCtrl,
                      label: "Price",
                      hint: "Enter price",
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildCustomTextField(
                      controller: itemCtrl,
                      label: "Included Items",
                      hint: "list items included in this meal",
                      icon: Icons.list_alt_outlined,
                      maxLines: 4,
                    ),
                  ]),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCardWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.deepOrange, size: 20),
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepOrange),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.deepOrange, Colors.orangeAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitMeal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "SUBMIT MEAL",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Future<void> _submitMeal() async {
    if (_mealsFormkey.currentState!.validate()) {
      setState(() => isSaving = true);

      try {
        var uuid = const Uuid();
        String mealId = uuid.v4();

        await FirebaseFirestore.instance.collection('Meals').doc(mealId).set({
          "id": mealId,
          "title": titleCtrl.text,
          "time": timeCtrl.text,
          "price": priceCtrl.text,
          "items": itemCtrl.text,
          "created_at": Timestamp.now(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Meal Added Successfully!")),
          );
        }
      } catch (e) {
        log(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error adding meal: $e")));
        }
      } finally {
        if (mounted) setState(() => isSaving = false);
      }
    }
  }
}
