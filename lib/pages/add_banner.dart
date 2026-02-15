import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_admin/service/cloudinary_service.dart';
import 'package:trip_admin/model/mainplacemodel.dart';

class AddBanner extends StatefulWidget {
  final bool isEdit;
  final String? bannerId;
  final String? title;
  final String? place;
  final String? description;
  final String? existingImageUrl;

  const AddBanner({
    super.key,
    this.isEdit = false,
    this.bannerId,
    this.title,
    this.place,
    this.description,
    this.existingImageUrl,
  });

  @override
  State<AddBanner> createState() => _AddBannerState();
}

class _AddBannerState extends State<AddBanner> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  XFile? selectedImage;
  bool isUploading = false;
  MainPlace? selectedPlace;
  Map<String, dynamic>? selectedPlaceFullData;

  final CloudneryUploader uploader = CloudneryUploader();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      titleController.text = widget.title!;
      descController.text = widget.description!;
      _loadPlaceDetails();
    }
  }

  Future<void> _loadPlaceDetails() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Places')
          .where('place', isEqualTo: widget.place)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        setState(() {
          selectedPlace = MainPlace.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          selectedPlaceFullData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error loading place details: $e');
    }
  }

  Future<void> _fetchCompletePlace(String placeId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Places')
          .doc(placeId)
          .get();

      if (doc.exists) {
        setState(() {
          selectedPlaceFullData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error fetching complete place: $e');
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> uploadBanner() async {
    if (selectedImage == null && !widget.isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (titleController.text.isEmpty ||
        selectedPlace == null ||
        descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a place"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    String? imageUrl;
    if (selectedImage != null) {
      imageUrl = await uploader.uploadFile(selectedImage!);
    } else if (widget.isEdit) {
      imageUrl = widget.existingImageUrl;
    }

    if (imageUrl != null) {
      try {
        if (widget.isEdit) {
          Map<String, dynamic> updateData = {
            "bannername": titleController.text,
            "image": imageUrl,
            "place": selectedPlaceFullData,
            "description": descController.text,
          };
          await FirebaseFirestore.instance
              .collection("bannerslide")
              .doc(widget.bannerId)
              .update(updateData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Banner updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          Map<String, dynamic> addData = {
            "bannername": titleController.text,
            "image": imageUrl,
            "place": selectedPlaceFullData,
            "description": descController.text,
          };
          await FirebaseFirestore.instance
              .collection("bannerslide")
              .add(addData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Banner added successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error ${widget.isEdit ? 'updating' : 'adding'} banner: $e",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image upload failed"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? "Edit Banner" : "Add Banner",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: selectedImage == null
                    ? widget.isEdit
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                widget.existingImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Tap to add banner image",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Title Field
            const Text(
              "Title",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter banner title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Place Selection Dropdown
            const Text(
              "Place",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Places')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No places available");
                }

                var places = snapshot.data!.docs
                    .map(
                      (doc) => MainPlace.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                String? initialValue;
                if (selectedPlace != null) {
                  initialValue = selectedPlace!.id;
                }

                return DropdownButtonFormField<String>(
                  value: initialValue,
                  items: places
                      .map(
                        (place) => DropdownMenuItem(
                          value: place.id,
                          child: Text(place.place),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selected = places.firstWhere((p) => p.id == value);
                      setState(() {
                        selectedPlace = selected;
                        _fetchCompletePlace(value);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a place';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Select place",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Description Field
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter banner description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUploading ? null : uploadBanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.isEdit ? "Update Banner" : "Add Banner",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}
