// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:inspetto/screens/district_official/district_official_main_screen.dart';

// Future<String?> getPhoneNumber(String employeeId) async {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   try {
//     // Query Firestore to find the document where employee_id matches
//     QuerySnapshot query = await firestore
//         .collection("employees")
//         .where("employee_id", isEqualTo: employeeId)
//         .limit(1)
//         .get();

//     if (query.docs.isNotEmpty) {
//       // Extract phone number from the first matching document
//       String phoneNumber = query.docs.first["phone"];
//       print("Phone Number Found: $phoneNumber");
//       return phoneNumber;
//     } else {
//       print("No data found for Employee ID: $employeeId");
//       return null;
//     }
//   } catch (e) {
//     print("Error fetching data: $e");
//     return null;
//   }
// }

// //sent OTP
// FirebaseAuth auth = FirebaseAuth.instance;
// String verificationId = "";

// Future<void> sendOTP(String phoneNumber) async {
//   await auth.verifyPhoneNumber(
//     phoneNumber: "+91$phoneNumber", // Add country code if missing
//     timeout: const Duration(seconds: 60),
//     verificationCompleted: (PhoneAuthCredential credential) async {
//       // Auto verification for some devices
//       await auth.signInWithCredential(credential);
//       print("Auto Verification Success!");
//     },
//     verificationFailed: (FirebaseAuthException e) {
//       print("OTP Sending Failed: ${e.message}");
//     },
//     codeSent: (String verId, int? resendToken) {
//       verificationId = verId; // Store verification ID for later use
//       print("OTP Sent to $phoneNumber");
//     },
//     codeAutoRetrievalTimeout: (String verId) {
//       verificationId = verId;
//     },
//   );
// }

// //verify OTP

// void verifyOTP(String verificationId, String otp, BuildContext context) async {
//   try {
//     // Create a credential using verification ID and the OTP entered
//     PhoneAuthCredential credential = PhoneAuthprovider.credential(
//       verificationId: verificationId,
//       smsCode: otp,
//     );

//     // Sign in with the credential
//     await FirebaseAuth.instance.signInWithCredential(credential);

//     // Navigate to the next screen on successful verification
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("OTP Verified Successfully!")),
//     );

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DistrictOfficialMainScreen(),
//       ),
//     ); // Change to your screen
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Invalid OTP. Try again!")),
//     );
//   }
// }
