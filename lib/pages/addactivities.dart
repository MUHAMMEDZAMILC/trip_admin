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

  final TextEditingController titleCtrl =TextEditingController();
  final TextEditingController priceCtrl =TextEditingController();
  final TextEditingController descCtrl =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

             Text("Title ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             SizedBox(height: 5),
            TextFormField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: "Enter Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20,),
             Text(" Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             SizedBox(height: 5),
            TextFormField(
              controller: priceCtrl,
              decoration: InputDecoration(
                hintText: " Enter  Price",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20,),
            const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
            controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter description",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 25,),
              SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  var uuid =Uuid();

                  try {
                         await FirebaseFirestore.instance
                  .collection('Activities')
                  .doc(uuid.v4())
                  .set({
                    "id":uuid.v4(),
                    "title":titleCtrl.text,
                    "price":priceCtrl.text,
                    "description":descCtrl.text,

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
                child: const Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),
            ]
            ),
            ),
    );
  }
}