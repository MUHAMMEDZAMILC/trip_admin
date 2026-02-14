import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_admin/service/cloudinary_service.dart';
import 'package:uuid/uuid.dart';

class AddmainplaceScreen extends StatefulWidget {
  final bool isEdit;
  final String? documentId;
  final String? existingPlace;
  final String? existingDesc;
  final String? existingImage;

  const AddmainplaceScreen({
    super.key,
    this.isEdit = false,
    this.documentId,
    this.existingPlace,
    this.existingDesc,
    this.existingImage,
  });

  @override
  State<AddmainplaceScreen> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddmainplaceScreen> {
  late TextEditingController placeCtrl;
  late TextEditingController descCtrl;

  XFile? image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    placeCtrl = TextEditingController(
      text: widget.isEdit ? widget.existingPlace : "",
    );
    descCtrl = TextEditingController(
      text: widget.isEdit ? widget.existingDesc : "",
    );
  }

  @override
  void dispose() {
    placeCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = XFile(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (placeCtrl.text.isEmpty || descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (!widget.isEdit && image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = widget.existingImage;

      if (image != null) {
        imageUrl = await CloudneryUploader().uploadFile(image!);
      }

      final collection = FirebaseFirestore.instance.collection('MainPlace');

      if (widget.isEdit && widget.documentId != null) {
        // Update existing
        await collection.doc(widget.documentId).update({
          "place": placeCtrl.text,
          "description": descCtrl.text,
          if (imageUrl != null) "image": imageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category updated successfully")),
        );
      } else {
        // Add new
        var uuid = const Uuid();
        String newId = uuid.v4();
        await collection.doc(newId).set({
          "id": newId,
          "place": placeCtrl.text,
          "image": imageUrl,
          "description": descCtrl.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category added successfully")),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Category" : "Add Category"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Place Name ----------
            const Text(
              "Place Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: placeCtrl,
              decoration: InputDecoration(
                hintText: "Enter place name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------- Description ----------
            const Text(
              "Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter description",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------- Image Picker ----------
            const Text(
              "Category Image",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(children: [_imageBox()]),

            const SizedBox(height: 30),

            // ---------- Submit Button ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 111, 119, 168),
                  disabledBackgroundColor: const Color.fromARGB(
                    255,
                    111,
                    119,
                    168,
                  ).withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
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
                    : Text(
                        widget.isEdit ? "Update Category" : "Add Category",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------- Image Box Widget ----------------------------
  Widget _imageBox() {
    return Expanded(
      child: GestureDetector(
        onTap: () => pickImage(ImageSource.gallery),
        child: Container(
          height: 180,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image != null
                ? Image.file(
                    File(image!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : (widget.isEdit &&
                      widget.existingImage != null &&
                      widget.existingImage!.isNotEmpty)
                ? Image.network(
                    widget.existingImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap to upload image",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
