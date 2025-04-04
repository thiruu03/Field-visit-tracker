import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if fingerprint authentication is available
  Future<String> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate ? "It can authenticate" : "It wont";
  }

  // Authenticate User
  Future<bool> authenticateUser() async {
    try {
      final bool authenticate = await auth.authenticate(
        localizedReason: 'Authenticate to proceed',
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticate;
    } catch (e) {
      print("Authentication Error: $e");
      return false;
    }
  }

  // Generate a fingerprint hash
  String generateFingerprintHash(String fingerprintData) {
    var bytes = utf8.encode(fingerprintData);
    return sha256.convert(bytes).toString();
  }

  // Save fingerprint hash to Firestore
  Future<void> saveFingerprint() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is logged in.");
      return;
    }

    // Authenticate user first
    bool authenticated = await authenticateUser();
    if (!authenticated) {
      print("Fingerprint authentication failed.");
      return;
    }

    // Generate unique fingerprint hash (based on user ID for now)
    String fingerprintHash = generateFingerprintHash(user.uid);

    try {
      await FirebaseFirestore.instance
          .collection("employees")
          .doc(user.uid)
          .set(
              {
            "fingerprint": fingerprintHash,
          },
              SetOptions(
                  merge: true)); // 🔥 Use merge: true to avoid overwriting data

      print("✅ Fingerprint saved successfully: $fingerprintHash");
    } catch (e) {
      print("❌ Error saving fingerprint: $e");
    }
  }

  // Verify fingerprint before approving/rejecting
  Future<bool> verifyFingerprint() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return false;

    bool authenticated = await authenticateUser();
    if (!authenticated) return false;

    DocumentSnapshot doc =
        await _firestore.collection("employees").doc(user.uid).get();

    if (!doc.exists || !doc.data().toString().contains("fingerprint")) {
      print("Fingerprint not found.");
      return false;
    }

    String savedFingerprint = doc["fingerprint"];
    String enteredFingerprintHash = generateFingerprintHash(user.uid);

    return savedFingerprint == enteredFingerprintHash;
  }

  Future<bool> checkFingerprint() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return false;

    DocumentSnapshot doc =
        await _firestore.collection("employees").doc(user.uid).get();

    if (doc.exists &&
        (doc.data() as Map<String, dynamic>).containsKey("fingerprint")) {
      print("Fingerprint already registered.");
      return true; // ✅ Return true if fingerprint exists
    }

    print("Fingerprint not found, prompting for registration...");
    return false; // ✅ Return false if fingerprint needs to be saved
  }
}
