import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_admin/Activities/activitiespage.dart';
import 'package:trip_admin/Hotel/hotelpage.dart';
import 'package:trip_admin/Meals/meals.dart';
import 'package:trip_admin/model/nearvymodel.dart';
import 'package:trip_admin/pages/addnearby.dart';
import 'package:trip_admin/service/cloudinary_service.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_admin/model/hotelmodel.dart';
import 'package:trip_admin/model/mainplacemodel.dart';

class Addpage extends StatefulWidget {
  final Map<String, dynamic>? placeData;
  final String? docId;

  const Addpage({super.key, this.placeData, this.docId});

  @override
  State<Addpage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<Addpage> {
  final TextEditingController placeCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  List<Hotelmodel> selectedHotels = [];
  List<Map<String, dynamic>> selectedActivities = [];
  List<Map<String, dynamic>> selectedMeals = [];
  List<Nearbymodel> selectedNearby = [];
  MainPlace? selectedValue;
  List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  Stream<List<MainPlace>> getMainPlaces() {
    return FirebaseFirestore.instance.collection('MainPlace').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return MainPlace.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

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
          "Add New Place",
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
                _buildSectionHeader("Basic Details"),
                const SizedBox(height: 12),
                _buildCardWrapper([
                  _buildCustomTextField(
                    controller: placeCtrl,
                    label: "Place Name",
                    hint: "Enter place name",
                    icon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildMainPlaceDropdown(),
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
                _buildSectionHeader("Media"),
                const SizedBox(height: 12),
                _buildImageSection(),
                const SizedBox(height: 24),
                _buildSectionHeader("Associated Services"),
                const SizedBox(height: 12),
                _buildServiceButtons(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 40),
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
      ),
    );
  }

  Widget _buildCardWrapper(List<Widget> children) {
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.deepOrange, size: 20),
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

  Widget _buildMainPlaceDropdown() {
    return StreamBuilder<List<MainPlace>>(
      stream: getMainPlaces(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        }

        final places = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Main Place",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.map_outlined,
                  color: Colors.deepOrange,
                  size: 20,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              value: selectedValue?.id,
              items: places.map((place) {
                return DropdownMenuItem(
                  value: place.id,
                  child: Text(place.title),
                );
              }).toList(),
              onChanged: (value) {
                final place = places.firstWhere((p) => p.id == value);
                setState(() {
                  selectedValue = place;
                });
              },
              hint: const Text("Select main category"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageSection() {
    return _buildCardWrapper([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Place Images",
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
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1.5,
                style: BorderStyle.none,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 40,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Select Multiple Images",
                  style: TextStyle(color: Colors.grey),
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

  Widget _buildSelectedItemsList(List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 35,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                items[index],
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceButtons() {
    return Column(
      children: [
        _serviceRowButton(
          "Manage Hotels",
          Icons.hotel_outlined,
          Colors.blue[50]!,
          Colors.blue,
          () async {
            final List<Hotelmodel>? result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Hotelpage()),
            );
            if (result != null) setState(() => selectedHotels = result);
          },
          trailingText: selectedHotels.isNotEmpty
              ? "${selectedHotels.length} selected"
              : null,
          child: _buildSelectedItemsList(
            selectedHotels.map((h) => h.hotel).toList(),
            Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        _serviceRowButton(
          "Manage Activities",
          Icons.sports_soccer_outlined,
          Colors.green[50]!,
          Colors.green,
          () async {
            final List<Map<String, dynamic>>? result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Activitiespage()),
            );
            if (result != null) setState(() => selectedActivities = result);
          },
          trailingText: selectedActivities.isNotEmpty
              ? "${selectedActivities.length} selected"
              : null,
          child: _buildSelectedItemsList(
            selectedActivities.map((a) => a['title'] as String).toList(),
            Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        _serviceRowButton(
          "Manage Meals",
          Icons.restaurant_menu_outlined,
          Colors.orange[50]!,
          Colors.orange,
          () async {
            final List<Map<String, dynamic>>? result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Meals()),
            );
            if (result != null) setState(() => selectedMeals = result);
          },
          trailingText: selectedMeals.isNotEmpty
              ? "${selectedMeals.length} selected"
              : null,
          child: _buildSelectedItemsList(
            selectedMeals.map((m) => m['title'] as String).toList(),
            Colors.orange,
          ),
        ),
        const SizedBox(height: 16),
        _serviceRowButton(
          "Manage Nearby Places",
          Icons.location_on_outlined,
          Colors.purple[50]!,
          Colors.purple,
          () async {
            final List<Nearbymodel>? result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNearby()),
            );
            if (result != null) setState(() => selectedNearby = result);
          },
          trailingText: selectedNearby.isNotEmpty
              ? "${selectedNearby.length} selected"
              : null,
          child: _buildSelectedItemsList(
            selectedNearby.map((n) => n.title ?? "").toList(),
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _serviceRowButton(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap, {
    String? trailingText,
    Widget? child,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (trailingText != null)
                          Text(
                            trailingText,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (child != null) child,
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
        onPressed: _submitPlace,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "SUBMIT PLACE",
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

  Future<void> _submitPlace() async {
    if (placeCtrl.text.isEmpty || selectedValue == null) {
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
      String placeId = uuid.v4();

      await FirebaseFirestore.instance.collection('Placess').doc(placeId).set({
        "id": placeId,
        "place": placeCtrl.text,
        "description": descCtrl.text,
        "mainplace": {
          "id": selectedValue!.id,
          "place": selectedValue!.title,
          "imageUrl": selectedValue!.imageUrl,
          "description": selectedValue!.description,
        },
        "images": imageUrls,
        "hotels": selectedHotels.map((h) => h.toMap()).toList(),
        "activities": selectedActivities,
        "meals": selectedMeals,
        "nearby": selectedNearby.map((n) => n.toMap()).toList(),
        "created_at": Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Place Added Successfully!")),
        );
      }
    } catch (e) {
      log("Error adding place: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding place: $e")));
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }
}
