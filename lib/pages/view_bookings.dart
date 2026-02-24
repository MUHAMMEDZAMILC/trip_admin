import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Bookingpage extends StatefulWidget {
  const Bookingpage({super.key});

  @override
  State<Bookingpage> createState() => _BookingpageState();
}

class _BookingpageState extends State<Bookingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          "Bookings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final id = snapshot.data!.docs[index].id;
              return BookingCard(data: data, docId: id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.r),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.airplane_ticket_outlined,
              size: 80.sp,
              color: Colors.indigo.withOpacity(0.3),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "No Tickets Yet",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "Your booked trips will appear here as travel tickets. Start exploring now!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          SizedBox(height: 16.h),
          const Text("Something went wrong. Please try again."),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const BookingCard({super.key, required this.data, required this.docId});

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        data['image'] ??
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e";
    String placeName = data['place'] ?? (data['description'] ?? "Amazing Trip");
    double totalPrice = (data['totalPrice'] is int)
        ? (data['totalPrice'] as int).toDouble()
        : (data['totalPrice'] as double? ?? 0.0);

    DateTime? bookedDate = (data['createdAt'] as Timestamp?)?.toDate();
    DateTime? travelDate = (data['travelDate'] as Timestamp?)?.toDate();

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section: Image & Status
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                child: Image.network(
                  imageUrl,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160.h,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Positioned(
              //   top: 12.h,
              //   left: 12.w,
              //   child: GestureDetector(
              //     onTap: () => _confirmDeletion(context),
              //     child: Container(
              //       padding: EdgeInsets.all(8.r),
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.9),
              //         shape: BoxShape.circle,
              //       ),
              //       child: Icon(
              //         Icons.delete_outline,
              //         color: Colors.red[400],
              //         size: 20.sp,
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[700],
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      const BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    "CONFIRMED",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 10.sp,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            placeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (bookedDate != null)
                            Text(
                              "Booked on ${bookedDate.day}/${bookedDate.month}/${bookedDate.year}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Price Paid",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${totalPrice.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.indigo[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                const DottedLine(dashColor: Colors.black12, dashGapLength: 6),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.indigo.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            travelDate != null
                                ? _getMonthName(travelDate.month)
                                : "DATE",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            travelDate != null ? "${travelDate.day}" : "--",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            travelDate != null ? "${travelDate.year}" : "N/A",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.indigo[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMiniInfo(
                            Icons.flight_takeoff_rounded,
                            "Travel Date",
                            travelDate != null
                                ? "Confirmed Attendance"
                                : "Date Not Set",
                          ),
                          SizedBox(height: 8.h),
                          _buildMiniInfo(
                            Icons.description_outlined,
                            "Reference",
                            "#${docId.substring(0, 8).toUpperCase()}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.h),

                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _buildIncludedChips(data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildIncludedChips(Map<String, dynamic> data) {
    List<Widget> chips = [];
    final summary = data['summary'] as List<dynamic>? ?? [];

    bool hasHotel = summary.any((s) => s.toString().contains('Hotel'));
    bool hasMeal = summary.any((s) => s.toString().contains('Meal'));
    bool hasActivity = summary.any((s) => s.toString().contains('Activity'));

    if (hasHotel) chips.add(_ticketChip(Icons.hotel, "Hotel"));
    if (hasMeal) chips.add(_ticketChip(Icons.restaurant, "Meals"));
    if (hasActivity) chips.add(_ticketChip(Icons.local_activity, "Activities"));

    return chips;
  }

  Widget _ticketChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.orange[800]),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    return months[month - 1];
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text("Cancel Ticket?"),
        content: const Text(
          "Are you sure you want to remove this booking from your travel list?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep"),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("bookings")
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              "Cancel Ticket",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
