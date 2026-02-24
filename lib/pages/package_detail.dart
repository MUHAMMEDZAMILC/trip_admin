import 'package:flutter/material.dart';
import 'package:trip_admin/model/package_model.dart';

class PackageDetailPage extends StatelessWidget {
  final TourPackage package;

  const PackageDetailPage({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${package.duration} Trip Detail"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepOrange.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price: ₹${package.price}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Duration: ${package.duration}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Added on: ${package.createdAt.day}/${package.createdAt.month}/${package.createdAt.year}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Destinations",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: package.destinations.length,
              itemBuilder: (context, index) {
                final dest = package.destinations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Place: ${dest.placeName}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Resort: ${dest.resortName}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Images Carousel
                      if (dest.resortImages.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: dest.resortImages.length,
                            itemBuilder: (context, imgIndex) {
                              return Container(
                                margin: const EdgeInsets.only(right: 12, bottom: 12),
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(dest.resortImages[imgIndex]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const Divider(),

                      // Meals
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Included Meals:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildMealRow(Icons.wb_sunny_outlined, "Morning", dest.meals['morning'] ?? 'N/A'),
                            _buildMealRow(Icons.wb_sunny, "Noon", dest.meals['noon'] ?? 'N/A'),
                            _buildMealRow(Icons.nights_stay_outlined, "Dinner", dest.meals['dinner'] ?? 'N/A'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMealRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
