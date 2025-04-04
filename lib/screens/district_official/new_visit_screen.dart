import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspetto/providers/visit_provider.dart';
import 'package:inspetto/utils/my_button.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

class NewVisitScreen extends StatefulWidget {
  final String? district;
  final String? name;
  const NewVisitScreen({super.key, required this.district, this.name});

  @override
  // ignore: library_private_types_in_public_api
  _NewVisitScreenState createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  String selectedDateTime = "Select Date & Time"; // Ensure it's initialized

  //date time picker
  // void _showDateTimePicker() {
  //   DatePicker.showDateTimePicker(
  //     context,
  //     showTitleActions: true,
  //     minTime: DateTime(2000, 1, 1),
  //     maxTime: DateTime(2100, 12, 31),
  //     onConfirm: (date) {
  //       String formattedDate =
  //           "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  //       String formattedTime =
  //           "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

  //       setState(() {
  //         selectedDateTime =
  //             "Date : $formattedDate\nTime : $formattedTime"; // Show Date and Time
  //       });
  //     },
  //     currentTime: DateTime.now(),
  //   );
  // }

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? _signatureImage; // Stores the signature as an image

  // Function to save signature

  void _saveSignature() async {
    final signature = await _controller.toPngBytes();

    if (signature != null) {
      setState(() {
        _signatureImage = signature;
      });
    }
  }

  // Function to clear the signature pad
  void _clearSignature() {
    _controller.clear();
    setState(() {
      _signatureImage = null;
    });
  }

  //capitalize first letter
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  TextEditingController workNameController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController areaController = TextEditingController();

  //add image
  File? image;
  Future<void> takePicture(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();

    try {
      XFile? imagefile = await imagePicker.pickImage(source: source);
      if (imagefile != null) {
        setState(() {
          image = File(imagefile.path);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void submitVisit(BuildContext context) async {
    if (image == null ||
        _signatureImage == null ||
        workNameController.text.isEmpty ||
        widget.district.toString().isEmpty ||
        areaController.text.isEmpty ||
        remarksController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields and upload required files."),
        ),
      );
      return;
    }

    // Show Loading Indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents user from dismissing during upload
      builder: (context) => Center(
          child: CircularProgressIndicator(
        color: Colors.white,
        backgroundColor: Colors.black12,
      )),
    );

    try {
      await Provider.of<VisitProvider>(context, listen: false).addVisitData(
          title: workNameController.text.trim(),
          district: widget.district.toString().trim(),
          place: areaController.text.trim(),
          remarks: remarksController.text.trim(),
          imageFile: image!,
          signatureBytes: _signatureImage!,
          uploadedBy: capitalizeFirstLetter(widget.name.toString()));

      // Close Loading Dialog
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Visit data uploaded successfully!")),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      // Close Loading Dialog if there's an error
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("Add Visit"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth / 30, vertical: screenHeight / 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  takePicture(ImageSource.camera);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                  height: 200,

                  width: double.infinity, // Fixed width issue
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(
                      color: Colors.black,
                      width: 4,
                    ),
                  ),
                  child: image != null
                      ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.camera_alt, size: 60),
                ),
              ),
              SizedBox(height: screenHeight / 40),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: workNameController,
                decoration: InputDecoration(
                  hintText: "Work name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight / 50),
              TextFormField(
                controller: areaController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Area / Street / Landmark",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight / 40),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,

                controller: remarksController,
                maxLines: 4, // Allows multiline input
                decoration: InputDecoration(
                  labelText: "Comments / Remarks",
                  border: OutlineInputBorder(), // Adds a border
                ),
              ),
              SizedBox(height: screenHeight / 50),
              Text(
                "Add your signature",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: screenHeight / 100),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Signature(
                  controller: _controller,
                  height: 100,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MyButton(
                    ontap: _clearSignature, // Direct function call
                    name: 'Clear',
                    height: 50,
                    width: 160,
                    textcolor: Colors.white,
                    backgroundcolor: Colors.black,
                  ),
                  MyButton(
                    ontap:
                        _saveSignature, // Only save; UI will update automatically
                    name: 'Save',
                    height: 50,
                    width: 160,
                    textcolor: Colors.white,
                    backgroundcolor: Colors.black,
                  ),
                ],
              ),
              SizedBox(height: screenHeight / 50),
              if (_signatureImage != null) // Show only if signature is saved
                Column(
                  children: [
                    Text("Saved Signature:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Center(
                      child: Image.memory(_signatureImage!, height: 100),
                    ),
                  ],
                ),
              SizedBox(height: screenHeight / 100),
              Center(
                child: MyButton(
                  ontap: () {
                    submitVisit(context);
                  },
                  name: "Submit",
                  height: 60,
                  width: 380,
                  textcolor: Colors.white,
                  backgroundcolor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
