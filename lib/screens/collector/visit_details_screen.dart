import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inspetto/providers/biometric_provider.dart';
import 'package:inspetto/utils/my_button.dart';

class VisitDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> visitData;
  final String? dis;

  const VisitDetailsScreen({
    super.key,
    required this.visitData,
    required this.dis,
  });

  @override
  _VisitDetailsScreenState createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  void updateStatus() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore
        .collection(widget.dis.toString())
        .doc(widget.visitData['docId']);

    String newStatus;
    if (widget.visitData['status'] == "pending") {
      newStatus = "Approved";
    } else if (widget.visitData['status'] == "Approved") {
      newStatus = "Rejected";
    } else {
      newStatus = "Approved";
    }

    await docRef.update({'status': newStatus});

    setState(() {
      widget.visitData['status'] = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status updated to $newStatus")),
    );
  }

  BiometricService biometricService = BiometricService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Visit Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image at the Top
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: widget.visitData['photoUrl'] != null &&
                          widget.visitData['photoUrl'] != ''
                      ? DecorationImage(
                          image: NetworkImage(widget.visitData['photoUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: widget.visitData['photoUrl'] == null ||
                          widget.visitData['photoUrl'] == ''
                      ? Colors.grey.shade300
                      : null,
                ),
                child: widget.visitData['photoUrl'] == null ||
                        widget.visitData['photoUrl'] == ''
                    ? Icon(Icons.image_not_supported,
                        size: 100, color: Colors.black54)
                    : CachedNetworkImage(
                        imageUrl: widget.visitData['photoUrl'],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 300),
                      ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Work Title: ${capitalizeFirstLetter(widget.visitData['title'])}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              // Status
              Text(
                'Status: ${capitalizeFirstLetter(widget.visitData['status'])}',
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),

              // Date
              Text(
                'Date: ${widget.visitData['timestamp'] != null ? widget.visitData['timestamp'].toDate().toString().substring(0, 16) : "N/A"}',
                style: TextStyle(fontSize: 16),
              ),

              // Landmark
              Text(
                'Landmark: ${capitalizeFirstLetter(widget.visitData['place'])}',
                style: TextStyle(fontSize: 16),
              ),

              // Remarks
              SizedBox(height: 10),
              Text(
                'Remarks: ${widget.visitData['remarks'] ?? "No remarks provided"}',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 10),

              // Signature Image
              Center(
                child: Column(
                  children: [
                    Text("Signature",
                        style: TextStyle(fontSize: 19, color: Colors.red)),
                    SizedBox(height: 8),
                    Image.network(widget.visitData['signature'], height: 70),
                  ],
                ),
              ),

              SizedBox(height: 35),

              // Update Status Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyButton(
                    ontap: () async {
                      bool verify = await biometricService.verifyFingerprint();

                      if (verify) {
                        FirebaseFirestore firebaseFirestore =
                            FirebaseFirestore.instance;

                        setState(() {
                          updateStatus();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Fingerprint doesn't match"),
                          ),
                        );
                      }
                    },
                    name: widget.visitData['status'] == "Approved"
                        ? 'Reject'
                        : "Approve",
                    height: 50,
                    width: 320,
                    textcolor: Colors.white,
                    backgroundcolor: widget.visitData['status'] == "Approved"
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                ],
              ),

              SizedBox(height: 30),

              Center(
                  child: Text(
                "Copyrights @Inspetteo",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to capitalize first letter
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
