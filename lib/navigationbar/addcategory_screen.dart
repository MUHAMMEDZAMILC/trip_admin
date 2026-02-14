import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_admin/model/mainplacemodel.dart';
import 'package:trip_admin/pages/addactivities.dart';
import 'package:trip_admin/pages/addhotel.dart';
import 'package:trip_admin/pages/addmeals.dart';
import 'package:trip_admin/service/cloudinary_service.dart';
import 'package:uuid/uuid.dart';

class AddmainplaceScreen extends StatefulWidget {
  const AddmainplaceScreen({super.key});

  @override
  State<AddmainplaceScreen> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddmainplaceScreen> {
  final TextEditingController placeCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  XFile? image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = XFile(picked.path);
      });
    }
  }

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ---------- Place  ----------
            Text(
              "Place",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            TextField(
              controller: placeCtrl,
              decoration: InputDecoration(
                hintText: "Enter place ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              "Location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter Location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Add  Picture",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Row(children: [_imageBox()]),

            SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  var uuid = Uuid();
                  String? imageurl;

                  if (image != null) {
                    imageurl = await CloudneryUploader().uploadFile(image!);
                  }
                  try {
                                      await FirebaseFirestore.instance
                      .collection('MainPlace')
                      .doc(uuid.v4())
                      .set({
                        "id": uuid.v4(),
                        "place": placeCtrl.text,
                        "image": imageurl,
                        "description": descCtrl.text,
                      });

                      Navigator.pop(context);
                  } catch (e) {
                    log(e.toString());
                  }

                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 111, 119, 168),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Add", style: TextStyle(fontSize: 18)),
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
          height: 170,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade200,
          ),
          child: image == null
              ? Icon(Icons.add_a_photo, size: 40, color: Colors.black54)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(image!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}
