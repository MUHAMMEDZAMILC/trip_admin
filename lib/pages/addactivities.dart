import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Addactivities extends StatefulWidget {
  const Addactivities({super.key});

  @override
  State<Addactivities> createState() => _AddactivitiesState();
}

class _AddactivitiesState extends State<Addactivities> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Add New Activity",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Activity Details"),
                const SizedBox(height: 12),
                _buildCardWrapper([
                  _buildCustomTextField(
                    controller: titleCtrl,
                    label: "Activity Title",
                    hint: "Enter title",
                    icon: Icons.local_activity_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildCustomTextField(
                    controller: priceCtrl,
                    label: "Price",
                    hint: "Enter price",
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildCustomTextField(
                    controller: descCtrl,
                    label: "Description",
                    hint: "Enter description",
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                ]),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
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
        onPressed: _submitActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "SUBMIT ACTIVITY",
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

  Future<void> _submitActivity() async {
    if (titleCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the required fields")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      var uuid = const Uuid();
      String activityId = uuid.v4();

      await FirebaseFirestore.instance
          .collection('Activities')
          .doc(activityId)
          .set({
            "id": activityId,
            "title": titleCtrl.text,
            "price": priceCtrl.text,
            "description": descCtrl.text,
            "created_at": Timestamp.now(),
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Activity Added Successfully!")),
        );
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding activity: $e")));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }
}
