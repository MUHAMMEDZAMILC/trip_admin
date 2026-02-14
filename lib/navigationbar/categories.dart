import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trip_admin/navigationbar/addcategory_screen.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddmainplaceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('MainPlace').snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
             return ListView.builder(
              itemCount: asyncSnapshot.data?.docs.length,
            itemBuilder: (context, index) {
              return   Padding(
                padding: const EdgeInsets.only(bottom:  8.0),
                child: _categoryCard(
                  imageUrl: asyncSnapshot.data?.docs[index]['image']??'N/A' '"https://www.bharatbooking.com/admin/webroot/img/uploads/holiday-package/1692431062_85552-thj.jpg"',
                  title: asyncSnapshot.data?.docs[index]['place'],
                ),
              );
            },
            padding: const EdgeInsets.all(16),
          
          );
        } 
        return CircularProgressIndicator();
          }
         
      ),
    );
  }

  // ------------------------ Card UI -------------------------
  Widget _categoryCard({required String imageUrl, required String title}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // ---------- Image ----------
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          // ---------- Title ----------
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
