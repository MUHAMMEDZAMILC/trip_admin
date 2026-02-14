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

final TextEditingController hotelCtrl =TextEditingController();
final TextEditingController priceCtrl =TextEditingController();
final TextEditingController descCtrl =TextEditingController();
final TextEditingController latitudeCtrl =TextEditingController();
final TextEditingController longitudeCtrl =TextEditingController();

 List<String> imageList = [];


  XFile? selimage;
  XFile? selimage2;
  final ImagePicker _picker =ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Hotel"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place Name
            const Text("Hotel Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
               controller: hotelCtrl,
              decoration: InputDecoration(
                hintText: "Enter Hotel name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            // Price
            const Text("Price Per Day",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
              controller: priceCtrl,
              decoration: InputDecoration(
                hintText: "Enter price",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            const Text("Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
              controller: descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter description",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            // Location
            const Text("Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Latitude",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: latitudeCtrl,
                        decoration: InputDecoration(
                          hintText: "Latitude",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Longitude",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: longitudeCtrl,
                        decoration: InputDecoration(
                          hintText: "Longitude",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Images
         const Text("Hotel Images (2)",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),

Row(
              children: [
                _imageBox(()async{
                   final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked !=null){
      setState(() {
        selimage = XFile(picked.path);
      });
    } 
                }, selimage),
                _imageBox(()async{
                   final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked !=null){
      setState(() {
        selimage2 = XFile(picked.path);
      });
    } 
                },selimage2),
              ],
            ),

            const SizedBox(height: 29),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{

                  var uuid = Uuid();
                  String? imageurl;
                  String?imageUrl2;

                  if( selimage!= null && selimage2!=null){
                    imageurl = await CloudneryUploader().uploadFile(selimage!);
                    imageUrl2 = await CloudneryUploader().uploadFile(selimage2!);
                  }

                  try {
                         await FirebaseFirestore.instance
                   .collection('Hotels')
                   .doc(uuid.v4())
                   .set({
                    "id":uuid.v4(),
                    "hotel":hotelCtrl.text,
                    "price perday":priceCtrl.text,
                    "description":descCtrl.text,
                    "latitude":latitudeCtrl.text,
                    "longitude":longitudeCtrl.text,
                    "image1":imageurl,
                    "image2":imageUrl2,

                   });
                      Navigator.pop(context);

                  }catch(e) {
                    log(e.toString());
                  }

                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 67, 77, 143),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 18,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- IMAGE BOX WIDGET -------------------
 Widget _imageBox(Function()? onTap,XFile? file) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade200,
          ),
          child: file ==null    
          ? Icon(Icons.add_a_photo, size: 40, color: Colors.black54)
          :ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(file.path),
              fit:BoxFit.cover,
              width:double.infinity,
              height: double.infinity
            ),
          )
        
        ),
      ),
    );
  }

  }

