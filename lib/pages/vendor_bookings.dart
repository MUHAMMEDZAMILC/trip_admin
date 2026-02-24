import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_admin/model/booking_model.dart';

class VendorBookings extends StatefulWidget {
  const VendorBookings({super.key});

  @override
  State<VendorBookings> createState() => _VendorBookingsState();
}

class _VendorBookingsState extends State<VendorBookings> {
  String? vendorUid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getVendorUid();
  }

  Future<void> _getVendorUid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorUid = prefs.getString("uid");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        ),
      );
    }

    if (vendorUid == null) {
      return const Scaffold(body: Center(child: Text("Vendor not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Bookings"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: vendorUid == null
          ? const Center(child: Text("Error: Vendor UID missing"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookedpackage')
                  .where('vendorId', isEqualTo: vendorUid)
                  // .orderBy('bookedAt', descending: true) // Temporarily commented out to avoid index requirement
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint("Firestore Error: ${snapshot.error}");
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Error fetching bookings: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildNoBookingsView(vendorUid);
                }

                final bookings = snapshot.data!.docs
                    .map(
                      (doc) => BookedPackage.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildBookingCard(booking);
                  },
                );
              },
            ),
    );
  }

  Widget _buildBookingCard(BookedPackage booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.deepOrange.withAlpha(26)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.packageDetails.destinations.isNotEmpty
                        ? booking.packageDetails.destinations.first.placeName
                        : "Unknown Destination",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person_outline, "Customer", booking.userEmail),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              "Booked On",
              DateFormat('dd MMM yyyy, hh:mm a').format(booking.bookedAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.timer_outlined, "Duration", booking.duration),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "₹${booking.packageDetails.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepOrange),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildNoBookingsView(String? vendorUid) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              "No Bookings Found",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "No bookings found for vendor ID: $vendorUid",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              "Please check if this ID matches the 'vendorId' field in your 'bookedpackage' collection in Firestore.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
