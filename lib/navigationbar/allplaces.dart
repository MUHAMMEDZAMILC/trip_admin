import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trip_admin/model/palcemodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trip_admin/navigationbar/addpage.dart';
import 'package:trip_admin/pages/place_details.dart';

class AllPlaces extends StatefulWidget {
  const AllPlaces({super.key});

  @override
  State<AllPlaces> createState() => _AllPlacesState();
}

class _AllPlacesState extends State<AllPlaces> {
  // Deletion logic
  void deletePlace(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Place"),
        content: const Text("Are you sure you want to delete this place?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('Places')
                  .doc(id)
                  .delete();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "All Places",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Places').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final placesDocs = snapshot.data!.docs;
            // Limit to 3 items for the home page list
            final limitedPlaces = placesDocs.take(3).toList();
            final placesModelList = limitedPlaces
                .map(
                  (doc) =>
                      PlaceModel.fromJson(doc.data() as Map<String, dynamic>),
                )
                .toList();
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: placesModelList.length,
              itemBuilder: (context, index) {
                final place = placesModelList[index];
                final docId = limitedPlaces[index].id;
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetails(placedtl: place),
                        ),
                      );
                    },
                    child: Container(
                      height: 250.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(22.r),
                              ),
                              child: Stack(
                                children: [
                                  Image.network(
                                    place.image ?? '',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(Icons.broken_image),
                                              ),
                                            ),
                                  ),
                                  Positioned(
                                    top: 12.h,
                                    right: 12.w,
                                    child: Row(
                                      children: [
                                        // Edit Button
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Addpage(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              size: 20.sp,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        // Delete Button
                                        GestureDetector(
                                          onTap: () {
                                            deletePlace(docId);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 20.sp,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Details Section
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          place.place ?? 'Unknown Place',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E1E2C),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 7.w,
                                            vertical: 1.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                color: Colors.amber[600],
                                                size: 16.sp,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                "4.8",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.sp,
                                                  color: Colors.amber[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    place.description ??
                                        "Discover the beauty of this amazing place.",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,

                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          "Explore",
                                          style: TextStyle(
                                            color: Colors.indigo[600],
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.indigo[600],
                                          size: 16.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addpage()),
          );
        },
        label: const Text("Add Place"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 111, 119, 168),
      ),
    );
  }
}
