import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_admin/auth/auth.dart';
import 'package:trip_admin/model/package_model.dart';
import 'package:trip_admin/pages/package_detail.dart';

class VendorHome extends StatelessWidget {
  const VendorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Packages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Authservice().logout(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('packages')
            .where('vendorId', isEqualTo: currentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No packages added yet."));
          }

          final packages = snapshot.data!.docs.map((doc) {
            return TourPackage.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              final String? previewImage = package.destinations.isNotEmpty && package.destinations[0].resortImages.isNotEmpty
                  ? package.destinations[0].resortImages[0]
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: previewImage != null && previewImage.isNotEmpty
                        ? Image.network(
                            previewImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 60),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                  title: Text(
                    "${package.duration} Trip",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${package.destinations.length} destinations\nStarting from: ${package.destinations.isNotEmpty ? package.destinations[0].placeName : 'N/A'}",
                  ),
                  trailing: Text(
                    "₹${package.price}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageDetailPage(package: package),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
