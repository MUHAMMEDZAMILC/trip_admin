import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_admin/login.dart';
import 'package:trip_admin/navigationbar/bottomnav.dart';
import 'package:trip_admin/navigationbar/vendor_bottomnav.dart';

class Authservice {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<String> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Store as vendor
        await _firestore.collection("vendors").doc(credential.user!.uid).set({
          'name': username,
          'email': email,
          'uid': credential.user!.uid,
          'role': 'vendor',
        });
        res = "success";
      } else {
        res = "please fill all the field";
      }
    } catch (err) {
      debugPrint("Signup error: $err");
      return err.toString();
    }
    return res;
  }

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Check for hardcoded Admin
      if (email == "admin@gmail.com" && password == "admin123") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("role", "admin");
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
            (route) => false,
          );
        }
        return;
      }

      // 2. Regular Firebase Auth Login
      UserCredential value = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = value.user!.uid;
      
      // Check if user exists in vendors collection
      DocumentSnapshot vendorDoc = await _firestore.collection("vendors").doc(uid).get();
      
      if (vendorDoc.exists) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("uid", uid);
        await prefs.setString("role", "vendor");
        
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const VendorBottomNavBar()),
            (route) => false,
          );
        }
      } else {
        // Not an admin or vendor
        await _auth.signOut();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unauthorized access")),
          );
        }
      }
    } catch (e) {
      debugPrint("Login error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all (role, uid, etc)
    await _auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }
}
