import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatusProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  cureentStatus(String status) {
    if (status == 'Approved') {
      
    }
  }
}
