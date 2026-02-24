import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trip_admin/model/palcemodel.dart';

class PlaceDetails extends StatelessWidget {
  final PlaceModel placedtl;

  const PlaceDetails({super.key, required this.placedtl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                placedtl.place ?? "Place Details",
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Image.network(
                (placedtl.images != null && placedtl.images!.isNotEmpty)
                    ? placedtl.images![0]
                    : (placedtl.image ?? ""),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (placedtl.images != null &&
                      placedtl.images!.length > 1) ...[
                    Text(
                      "Gallery",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 100.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: placedtl.images!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                placedtl.images![index],
                                width: 150.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (placedtl.description != null) ...[
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      placedtl.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (placedtl.basePackagePrice != null) ...[
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.green),
                        SizedBox(width: 10.w),
                        Text(
                          "Base Price: ${placedtl.basePackagePrice}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (placedtl.hotels != null &&
                      placedtl.hotels!.isNotEmpty) ...[
                    Text(
                      "Hotels",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...placedtl.hotels!.map(
                      (hotel) => Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: ListTile(
                          leading: hotel.image1 != null
                              ? Image.network(
                                  hotel.image1!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.hotel),
                                )
                              : Icon(Icons.hotel),
                          title: Text(hotel.hotel ?? "Unknown Hotel"),
                          subtitle: Text(hotel.description ?? ""),
                          trailing: Text("\$${hotel.pricePerday ?? ''}"),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (placedtl.activity != null &&
                      placedtl.activity!.isNotEmpty) ...[
                    Text(
                      "Activities",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...placedtl.activity!.map(
                      (act) => Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: ListTile(
                          leading: Icon(
                            Icons.local_activity,
                            color: Colors.blue,
                          ),
                          title: Text(act.title ?? "Activity"),
                          subtitle: Text(act.description ?? ""),
                          trailing: Text(act.price ?? ''),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (placedtl.meals != null && placedtl.meals!.isNotEmpty) ...[
                    Text(
                      "Meals",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...placedtl.meals!.map(
                      (meal) => Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: ListTile(
                          leading: Icon(Icons.restaurant, color: Colors.orange),
                          title: Text(meal.title ?? "Meal"),
                          subtitle: Text(meal.items ?? ""),
                          trailing: Text(meal.price ?? ''),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  if (placedtl.nearby != null &&
                      placedtl.nearby!.isNotEmpty) ...[
                    Text(
                      "Nearby Places",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...placedtl.nearby!.map(
                      (near) => Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.indigo,
                          ),
                          title: Text(near.title ?? "Nearby Location"),
                          subtitle: Text("Lat: ${near.lat}, Log: ${near.log}"),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
