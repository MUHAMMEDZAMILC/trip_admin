import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trip_admin/navigationbar/addcategory_screen.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  // Deletion Logic
  void _deleteCategory(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this category? This action cannot be undone.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('MainPlace')
                    .doc(id)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Category deleted successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error deleting category: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light greyish background
      appBar: AppBar(
        title: const Text(
          "Manage Categories",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddmainplaceScreen()),
          );
        },
        label: const Text("Add Category"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 111, 119, 168),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('MainPlace').snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6F77A8)),
            );
          }

          if (!asyncSnapshot.hasData || asyncSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No categories found",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: asyncSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = asyncSnapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              String id = doc.id;
              String place = (data['place'] as String?) ?? 'Unknown';
              String description = (data['description'] as String?) ?? '';
              String imageUrl = (data['image'] as String?) ?? '';

              if (imageUrl.isEmpty || imageUrl == 'N/A') {
                imageUrl = "https://via.placeholder.com/150";
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            // Action Buttons Overlay
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Column(
                                children: [
                                  _actionButton(
                                    icon: Icons.edit_rounded,
                                    color: Colors.blueAccent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddmainplaceScreen(
                                                isEdit: true,
                                                documentId: id,
                                                existingPlace: place,
                                                existingDesc: description,
                                                existingImage: imageUrl,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 6),
                                  _actionButton(
                                    icon: Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    onTap: () => _deleteCategory(context, id),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content Section
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E2C),
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}
