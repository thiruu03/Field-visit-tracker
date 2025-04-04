import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inspetto/providers/location_provider.dart';
import 'package:inspetto/providers/visit_provider.dart';
import 'package:inspetto/utils/my_button.dart';
import 'package:provider/provider.dart';

class DistrictOfficalHomeScreen extends StatefulWidget {
  final String? empd;
  final String? empn;
  const DistrictOfficalHomeScreen(
      {super.key, required this.empd, required this.empn});

  @override
  State<DistrictOfficalHomeScreen> createState() =>
      _DistrictOfficalHomeScreenState();
}

class _DistrictOfficalHomeScreenState extends State<DistrictOfficalHomeScreen> {

  @override
  void initState() {
   
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final visitProvider = Provider.of<VisitProvider>(context, listen: false);

    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    //capitalize first letter
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }


    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        body: FutureBuilder(
          future: visitProvider.fetchData(widget.empd.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.amber),
                      ),
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Center(child: Text("No visits found."));
            }

            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth / 20, vertical: screenWidth / 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent visits",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: screenHeight / 60,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        FirebaseFirestore firestore =
                            FirebaseFirestore.instance;
                        var visits = snapshot.data![index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.grey.shade300,
                            minTileHeight: 80,
                            contentPadding: EdgeInsets.all(10),
                            leading: visits['photoUrl'] != null &&
                                    visits['photoUrl'] != ''
                                ? CachedNetworkImage(
                                    imageUrl: visits['photoUrl'],
                                    height: 80,
                                    width: 90,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error, color: Colors.red),
                                  )
                                : Icon(Icons.image_not_supported, size: 60),
                            title: FutureBuilder<String>(
                              future: locationProvider.getLocationName(
                                  double.tryParse(visits['latitude']
                                              ?.toString()
                                              .trim() ??
                                          '0.0') ??
                                      0.0,
                                  double.tryParse(visits['longitude']
                                              ?.toString()
                                              .trim() ??
                                          '0.0') ??
                                      0.0),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text("Fetching location...");
                                }

                                if (snapshot.hasError) {
                                  return Text("Error fetching location");
                                }

                                return Consumer<LocationProvider>(
                                  builder: (context, locationprovider, child) {
                                    return Text(
                                      'Place : ${snapshot.data}',
                                      style: TextStyle(fontSize: 15),
                                    );
                                  },
                                );
                              },
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Work : ${capitalizeFirstLetter(
                                  visits['title'],
                                )}'),
                                Text('Status : ${capitalizeFirstLetter(
                                  visits['status'],
                                )}'),
                              ],
                            ),
                            horizontalTitleGap: 15,
                            minLeadingWidth: 20,
                            onTap: () => showVisitDetails(context, visits),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void showVisitDetails(BuildContext context, Map<String, dynamic> visitData) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
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
                  image: visitData['photoUrl'] != null &&
                          visitData['photoUrl'] != ''
                      ? DecorationImage(
                          image:
                              NetworkImage(visitData['photoUrl'], scale: 100),
                          fit: BoxFit.fitHeight,
                        )
                      : null,
                  color: visitData['photoUrl'] == null ||
                          visitData['photoUrl'] == ''
                      ? Colors.grey.shade300
                      : null,
                ),
                child:
                    visitData['photoUrl'] == null || visitData['photoUrl'] == ''
                        ? Icon(Icons.image_not_supported,
                            size: 100, color: Colors.black54)
                        : CachedNetworkImage(
                            imageUrl: visitData['photoUrl'],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 300),
                          ),
              ),

              SizedBox(height: 20),

              // Title
              Text(
                'Work Title : ${capitalizeFirstLetter(visitData['title'])}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              // Status
              Text(
                'Status : ${capitalizeFirstLetter(visitData['status'])}',
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),

              // Date
              Text(
                'Date : ${visitData['timestamp'] != null ? visitData['timestamp'].toDate().toString().substring(0, 16) : "N/A"}',
                style: TextStyle(fontSize: 16),
              ),

              // landmark
              Text(
                'Landmark : ${capitalizeFirstLetter(visitData['place'])}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              // Remarks
              SizedBox(height: 10),
              Text(
                'Remarks : ${visitData['remarks'] ?? "No remarks provided"}',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(
                height: 10,
              ),

              //siganture image
              Center(
                child: Column(
                  children: [
                    Text(
                      "Siganture",
                      style: TextStyle(fontSize: 19, color: Colors.red),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Image.network(
                      visitData['signature'],
                      height: 70,
                    ),
                  ],
                ),
              ),

              // Close Button
              SizedBox(height: 20),
              Center(
                child: MyButton(
                  ontap: () {
                    Navigator.pop(context);
                  },
                  name: "Close",
                  height: 40,
                  width: 150,
                  textcolor: Colors.white,
                  backgroundcolor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

//capitalize first letter
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
