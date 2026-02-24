import 'dart:io';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_admin/service/cloudinary_service.dart';
import 'package:uuid/uuid.dart';

class Addhotel extends StatefulWidget {
  const Addhotel({super.key});

  @override
  State<Addhotel> createState() => _AddhotelState();
}

class _AddhotelState extends State<Addhotel> {
  final TextEditingController hotelCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController latitudeCtrl = TextEditingController();
  final TextEditingController longitudeCtrl = TextEditingController();

  List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  Future<void> _pickImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        selectedImages.addAll(pickedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Add New Hotel",
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
                _buildSectionHeader("Hotel Details"),
                const SizedBox(height: 12),
                _buildCardWrapper([
                  _buildCustomTextField(
                    controller: hotelCtrl,
                    label: "Hotel Name",
                    hint: "Enter hotel name",
                    icon: Icons.hotel_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildCustomTextField(
                    controller: priceCtrl,
                    label: "Price Per Day",
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
                const SizedBox(height: 24),
                _buildSectionHeader("Location"),
                const SizedBox(height: 12),
                _buildCardWrapper([
                  Row(
                    children: [
                      Expanded(
                        child: _buildCustomTextField(
                          controller: latitudeCtrl,
                          label: "Latitude",
                          hint: "Latitude",
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCustomTextField(
                          controller: longitudeCtrl,
                          label: "Longitude",
                          hint: "Longitude",
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionHeader("Media"),
                const SizedBox(height: 12),
                _buildImageSection(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (isUploading)
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

  Widget _buildImageSection() {
    return _buildCardWrapper([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Hotel Images",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          TextButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: const Text("Add More"),
            style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (selectedImages.isEmpty)
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  "Add Hotel Photos",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        )
      else
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(selectedImages[index].path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 17,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    ]);
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
        onPressed: _submitHotel,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "SUBMIT HOTEL",
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

  Future<void> _submitHotel() async {
    if (hotelCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the required fields")),
      );
      return;
    }

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one image")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final List<String> imageUrls = [];
      for (var image in selectedImages) {
        final url = await CloudneryUploader().uploadFile(image);
        if (url != null) imageUrls.add(url);
      }

      var uuid = const Uuid();
      String hotelId = uuid.v4();

      await FirebaseFirestore.instance.collection('Hotels').doc(hotelId).set({
        "id": hotelId,
        "hotel": hotelCtrl.text,
        "price perday": priceCtrl.text,
        "description": descCtrl.text,
        "latitude": latitudeCtrl.text,
        "longitude": longitudeCtrl.text,
        "images": imageUrls,
        "created_at": Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hotel Added Successfully!")),
        );
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding hotel: $e")));
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }
}
