import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_admin/model/package_model.dart';

class BookedPackage {
  final String id;
  final String vendorId;
  final String userId;
  final String userEmail;
  final String packageId;
  final String status;
  final double price;
  final String duration;
  final DateTime bookedAt;
  final TourPackage packageDetails;

  BookedPackage({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.userEmail,
    required this.packageId,
    required this.status,
    required this.price,
    required this.duration,
    required this.bookedAt,
    required this.packageDetails,
  });

  factory BookedPackage.fromMap(Map<String, dynamic> map, String docId) {
    return BookedPackage(
      id: docId,
      vendorId: map['vendorId'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      packageId: map['packageId'] ?? '',
      status: map['status'] ?? 'Pending',
      price: (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? '',
      bookedAt: (map['bookedAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      packageDetails: TourPackage.fromMap(
        Map<String, dynamic>.from(map['packageDetails'] ?? {}),
        map['packageId'] ?? '',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'userId': userId,
      'userEmail': userEmail,
      'packageId': packageId,
      'status': status,
      'price': price,
      'duration': duration,
      'bookedAt': bookedAt,
      'packageDetails': packageDetails.toMap(),
    };
  }
}
