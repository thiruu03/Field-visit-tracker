import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inspetto/providers/location_provider.dart';
import 'package:inspetto/providers/visit_provider.dart';
import 'package:inspetto/screens/collector/visit_details_screen.dart';
import 'package:provider/provider.dart';

class CollectorHomeScreen extends StatefulWidget {
  final String? empd;
  final String? empn;
  const CollectorHomeScreen({super.key, this.empd, this.empn});

  @override
  State<CollectorHomeScreen> createState() => _CollectorHomeScreenState();
}

class _CollectorHomeScreenState extends State<CollectorHomeScreen> {
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
                      child: CircularProgressIndicator(),
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
                                    height: 70,
                                    width: 90,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
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

                                return Text(
                                  'Place : ${snapshot.data}',
                                  style: TextStyle(fontSize: 15),
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
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VisitDetailsScreen(
                                        visitData: visits,
                                        dis: widget.empd.toString()),
                                  ));
                            },
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
