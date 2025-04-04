import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inspetto/screens/login_selection_screen.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //logout
  Future<void> logout(BuildContext context) async {
    await auth.signOut();

    // Delay ensures Firebase session clears before navigating
    await Future.delayed(const Duration(milliseconds: 300));

    if (!context.mounted) return; // Ensure context is still valid

    // Close dialog if it's open
    Navigator.of(context, rootNavigator: true).pop();

    // Ensure navigation starts fresh with no previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginSelectionScreen()),
      (route) => false, // Clears navigation history correctly
    );

    notifyListeners(); // Ensures UI updates accordingly
  }

//get login status
  Future<List<String>> getLoginStatus() async {
    await Future.delayed(Duration(seconds: 1)); // Stability delay
    List<String> data = [];
    User? user = auth.currentUser;

    if (user == null) {
      print("User is not logged in.");
      return ['No data found'];
    }

    // Remove '+91' from Firebase Auth phone number for matching
    String phoneNumber = user.phoneNumber!.startsWith('+91')
        ? user.phoneNumber!.substring(3)
        : user.phoneNumber!;

    print("Matching Phone Number: $phoneNumber");

    // Query with the corrected phone number
    QuerySnapshot snapshot = await firestore
        .collection('employees')
        .where('phone', isEqualTo: phoneNumber)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var userData = snapshot.docs.first.data() as Map<String, dynamic>;

      data = [
        userData['role'] ?? '',
        userData['name'] ?? '',
        userData['district'] ?? '',
      ];

      print(
          "Role: ${userData['role']}, Name: ${userData['name']}, District: ${userData['district']}");
      return data;
    }

    print("No data found in Firestore.");
    return ['No data found'];
  }

  Future<void> debugFirestoreData() async {
    QuerySnapshot snapshot = await firestore.collection('employees').get();

    for (var doc in snapshot.docs) {
      print("Document ID: ${doc.id}");
      print("Data: ${doc.data()}");
    }
  }

//get phone number to send OTP
  Future<String?> getPhoneNumber(String employeeId) async {
    try {
      // Query Firestore to find the document where employee_id matches
      QuerySnapshot query = await firestore
          .collection("employees")
          .where("employee_id", isEqualTo: employeeId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Extract phone number from the first matching document
        String phoneNumber = query.docs.first["phone"];
        print("Phone Number Found: $phoneNumber");
        return phoneNumber;
      } else {
        print("No data found for Employee ID: $employeeId");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  //get name
  Future<String?> getName(String employeeId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot query = await firestore
          .collection('employees')
          .where('employee_id', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        String name = query.docs.first['name'];
        print('Name found: $name');
        return name;
      } else {
        print("No name found");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  //get district
  Future<String?> getDistrict(String empoyeeId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot query = await firestore
          .collection('employees')
          .where('employee_id', isEqualTo: empoyeeId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        String district = query.docs.first['district'];
        print('distict found $district');
        return district;
      } else {
        print("No data found");
        return null;
      }
    } catch (e) {
      print("No district found");
      return null;
    }
  }

  bool _isOtpSent = false;
  bool _isVerifying = false;

  bool get isOtpSent => _isOtpSent;
  bool get isVerifying => _isVerifying;

  String _verificationId = ""; // Private variable

  String get verificationId => _verificationId; // Add this getter

//Send OTP
  void sendOTP(String phoneNumber) async {
    _isOtpSent = true;
    notifyListeners();

    await auth.verifyPhoneNumber(
      phoneNumber: "+91$phoneNumber",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        _isOtpSent = false;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        print("OTP Sending Failed: ${e.message}");
        _isOtpSent = false;
        notifyListeners();
      },
      codeSent: (String verId, int? resendToken) {
        _verificationId = verId;
        _isOtpSent = false;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verId) {
        _verificationId = verId;
      },
    );
  }

//verify OTP
  Future<bool> verifyOTP(String otp, BuildContext context,) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, // Use stored verification ID
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      // await changeLogginStatus(empid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified Successfully!")),
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Try again!")),
      );
      return false;
    }
  }

  Future changeLogginStatus(String empID) async {
    await firestore
        .collection('employees')
        .doc(empID)
        .update({"isloggedin": "true"});
  }
}
