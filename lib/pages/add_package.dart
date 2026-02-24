import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_admin/model/package_model.dart';
import 'package:trip_admin/service/cloudinary_service.dart';
import 'package:uuid/uuid.dart';

class AddPackagePage extends StatefulWidget {
  const AddPackagePage({super.key});

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<PackageDestination> _destinations = [];
  List<List<XFile>> _selectedImagesPerDestination = [];

  void _addDestination() {
    setState(() {
      _destinations.add(PackageDestination(
        placeName: '',
        resortName: '',
        resortImages: [],
        meals: {'morning': '', 'noon': '', 'dinner': ''},
      ));
      _selectedImagesPerDestination.add([]);
    });
  }

  void _removeDestination(int index) {
    setState(() {
      _destinations.removeAt(index);
      _selectedImagesPerDestination.removeAt(index);
    });
  }

  Future<void> _pickImages(int index) async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImagesPerDestination[index].addAll(pickedFiles);
      });
    }
  }

  void _removeSelectedImage(int destinationIndex, int imageIndex) {
    setState(() {
      _selectedImagesPerDestination[destinationIndex].removeAt(imageIndex);
    });
  }

  Future<void> _savePackage() async {
    if (_durationCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and add at least one destination"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedImagesPerDestination.any((list) => list.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one image for each resort"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.deepOrange),
      ),
    );

    final String vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String packageId = const Uuid().v4();
    final uploader = CloudneryUploader();

    List<PackageDestination> uploadedDestinations = [];

    try {
      for (int i = 0; i < _destinations.length; i++) {
        List<String> imageUrls = [];
        for (var imageFile in _selectedImagesPerDestination[i]) {
          String? imageUrl = await uploader.uploadFile(imageFile);
          if (imageUrl == null) {
            throw Exception("Failed to upload image for ${_destinations[i].placeName}");
          }
          imageUrls.add(imageUrl);
        }

        uploadedDestinations.add(PackageDestination(
          placeName: _destinations[i].placeName,
          resortName: _destinations[i].resortName,
          resortImages: imageUrls,
          meals: _destinations[i].meals,
        ));
      }

      final newPackage = TourPackage(
        id: packageId,
        vendorId: vendorId,
        duration: _durationCtrl.text,
        destinations: uploadedDestinations,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('packages')
          .doc(packageId)
          .set(newPackage.toMap());

      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Package Added Successfully! 🚀"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _durationCtrl.clear();
          _priceCtrl.clear();
          _destinations = [];
          _selectedImagesPerDestination = [];
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Create Tour Package",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("General Information"),
            const SizedBox(height: 12),
            _buildInfoCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader("Destinations Plan"),
                TextButton.icon(
                  onPressed: _addDestination,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text("Add New"),
                  style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_destinations.isEmpty)
              _buildEmptyState()
            else
              _buildDestinationList(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
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
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCustomTextField(
            controller: _durationCtrl,
            label: "Duration",
            hint: "e.g. 10 Days / 9 Nights",
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _priceCtrl,
            label: "Starting Price",
            hint: "e.g. 25000",
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.deepOrange, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.location_on_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            "No destinations added yet",
            style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _destinations.length,
      itemBuilder: (context, index) {
        return _buildDestinationCard(index);
      },
    );
  }

  Widget _buildDestinationCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DESTINATION #${index + 1}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => _removeDestination(index),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompactField(
                  label: "Where to?",
                  hint: "e.g. Munnar, Kerala",
                  onChanged: (val) {
                    _destinations[index] = PackageDestination(
                      placeName: val,
                      resortName: _destinations[index].resortName,
                      resortImages: _destinations[index].resortImages,
                      meals: _destinations[index].meals,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildCompactField(
                  label: "Resort Name",
                  hint: "e.g. Spice Tree Resort",
                  onChanged: (val) {
                    _destinations[index] = PackageDestination(
                      placeName: _destinations[index].placeName,
                      resortName: val,
                      resortImages: _destinations[index].resortImages,
                      meals: _destinations[index].meals,
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildImageSection(index),
                const SizedBox(height: 20),
                const Text(
                  "Inclusions (Meals)",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54),
                ),
                const SizedBox(height: 12),
                _buildMealInputs(index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactField({
    required String label,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            isDense: true,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Resort Photos",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            ),
            GestureDetector(
              onTap: () => _pickImages(index),
              child: const Text(
                "+ Add Photos",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedImagesPerDestination[index].isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImagesPerDestination[index].length,
              itemBuilder: (context, imgIndex) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 90,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_selectedImagesPerDestination[index][imgIndex].path),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(index, imgIndex),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: () => _pickImages(index),
            child: Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text("Upload Images",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMealInputs(int index) {
    return Row(
      children: [
        Expanded(
            child: _buildMealColumn(index, "morning", Icons.wb_twilight)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildMealColumn(index, "noon", Icons.wb_sunny_outlined)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildMealColumn(index, "dinner", Icons.nightlight_round_outlined)),
      ],
    );
  }

  Widget _buildMealColumn(int index, String mealType, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.orange[300]),
        const SizedBox(height: 4),
        TextField(
          onChanged: (val) => _destinations[index].meals[mealType] = val,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: mealType.toUpperCase(),
            hintStyle: const TextStyle(fontSize: 10),
            isDense: true,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
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
          colors: [Colors.deepOrange, Colors.orange],
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
        onPressed: _savePackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "PUBLISH PACKAGE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
