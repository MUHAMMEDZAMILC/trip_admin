import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Addmeals extends StatefulWidget {
  const Addmeals({super.key});

  @override
  State<Addmeals> createState() => _AddmealsState();
}

class _AddmealsState extends State<Addmeals> {

  final _mealsFormkey = GlobalKey<FormState>();

  final TextEditingController titleCtrl =TextEditingController();
  final TextEditingController timeCtrl =TextEditingController();
  final TextEditingController priceCtrl =TextEditingController();
  final TextEditingController itemCtrl =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _mealsFormkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: [
          
               Text("Title ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               SizedBox(height: 5),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: "Enter Title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20,),
               Text(" Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               SizedBox(height: 5),
              TextField(
                controller: timeCtrl,
                decoration: InputDecoration(
                  hintText: " Enter  Time",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
                 SizedBox(height: 20,),
               Text(" Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               SizedBox(height: 5),
              TextField(
                controller: priceCtrl,
                decoration: InputDecoration(
                  hintText: " Enter  Price",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20,),
              const Text("Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: itemCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter Your items",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20,),
                SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
          
                    var uuid =Uuid();
          
              if (_mealsFormkey.currentState!.validate()) {
                

                   try {
                         await FirebaseFirestore.instance
                   .collection('Meals')
                   .doc(uuid.v4())
                   .set({
                    "id":uuid.v4(),
                    "title":titleCtrl.text,
                    "time":timeCtrl.text,
                    "price":priceCtrl.text,
                    "items":itemCtrl.text,
          
                   });
                     Navigator.pop(context);
                   
                 } catch (e) {
                   log(e.toString());
                 }
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
            ),
    );
  }
}