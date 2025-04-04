import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class VisitProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  late String place;
//upload image to storage
  Future<String?> uploadImage(File imageFile, String district, place) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('$district/$place/visit_photo_${DateTime.now().day}.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Image Upload Error: $e");
      return null;
    }
  }

  Future<String?> uploadSignature(
      Uint8List signatureBytes, String district, String place) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('$district/$place/signature_${DateTime.now().day}.png');

      await ref.putData(
          signatureBytes, SettableMetadata(contentType: 'image/png'));

      return await ref.getDownloadURL();
    } catch (e) {
      print("Signature Upload Error: $e");
      return null;
    }
  }

  //add visit data to firebase
  Future<void> addVisitData(
      {required String title,
      required String district,
      required String place,
      required String remarks,
      required File imageFile,
      required Uint8List signatureBytes,
      required String uploadedBy}) async {
    try {
      // Get Geo-location
      Location locationService = Location();
      LocationData currentLocation = await locationService.getLocation();

      // Upload Photo and Signature
      String? photoUrl = await uploadImage(imageFile, district, place);
      String? signatureUrl =
          await uploadSignature(signatureBytes, district, place);

      // Store Data in Firestore
      await firestore.collection(district).add({
        'title': title,
        'place': place,
        'latitude': currentLocation.latitude.toString(),
        'longitude': currentLocation.longitude.toString(),
        'remarks': remarks,
        'photoUrl': photoUrl ?? '',
        'signature': signatureUrl ?? '',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'uploadedBy': uploadedBy
      });

      print("Visit data added successfully.");
    } catch (e) {
      print("Error adding visit data: $e");
    }
  }

  //get list of images
  Future<List<Map<String, dynamic>>> fetchData(String placeName) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot snapshot = await firestore.collection(placeName).get();
      return snapshot.docs.map(
        (e) {
          var data = e.data() as Map<String, dynamic>;
          data['docId'] = e.id;
          return data;
        },
      ).toList();
    } catch (e) {
      print("error fetching data $e");
      return [];
    }
  }
}
