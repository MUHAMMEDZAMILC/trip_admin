import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_admin/auth/auth.dart';

class VendorProfile extends StatelessWidget {
  const VendorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Profile"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('vendors').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final vendorData = snapshot.data?.data() as Map<String, dynamic>?;
          final name = vendorData?['name'] ?? 'Vendor';
          final email = vendorData?['email'] ?? user?.email ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _buildProfileItem(Icons.business, "Business Details", () {}),
                _buildProfileItem(Icons.history, "Transaction History", () {}),
                _buildProfileItem(Icons.settings, "Settings", () {}),
                const Divider(),
                _buildProfileItem(
                  Icons.logout,
                  "Logout",
                  () => Authservice().logout(context),
                  color: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.deepOrange),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
