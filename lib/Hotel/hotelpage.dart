import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trip_admin/model/hotelmodel.dart';
import 'package:trip_admin/pages/addhotel.dart';

class Hotelpage extends StatefulWidget {
  const Hotelpage({super.key});

  @override
  State<Hotelpage> createState() => _HotelpageState();
}

class _HotelpageState extends State<Hotelpage> {
  // Store selected hotel IDs
  List<Hotelmodel> selectedHotels = [];
  List<String> selecthotelids =[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Hotels').snapshots(),
        builder: (context, snapshot) {
            if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
            }

            
            final hotelModels = snapshot.data!.docs
    .map((doc) => Hotelmodel.fromJson(doc.data() as Map<String, dynamic>))
    .toList();


            

            return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hotelModels.length,
            itemBuilder: (context, index) {
              final place = hotelModels[index];
              final hotelId = place.id;

             

              return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              child: Row(
                  children: [
                    // LEFT IMAGE
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(14),
                      ),
                      child: Image.network(
                        place.image1,
                        height: 95,
                        width: 110,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // CENTER TEXT
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.hotel,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "₹${place.pricePerday}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // RIGHT CHECKBOX
                    Checkbox(
                      value: selecthotelids.contains(place.id),
                      onChanged: (value) {
                        log(value.toString());
                       
                          if (value==true) {
                            selecthotelids.add(place.id);
                          } else {
                            selecthotelids.remove(place.id);
                          }

                          selectedHotels.clear();
                          for (var i = 0; i < hotelModels.length; i++) {
                            if (selecthotelids.contains(hotelModels[i].id)) {
                              selectedHotels.add(hotelModels[i]);
                            }
                          }
                         setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // SUBMIT BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            if (selectedHotels.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select at least one hotel")),
              );
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hotels Saved Successfully!")),
            );


            Navigator.pop(context,
              selectedHotels

            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Submit",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Addhotel()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
