import 'package:flutter/material.dart';
import 'package:inspetto/providers/visit_provider.dart';
import 'package:inspetto/screens/collector/visit_details_screen.dart';
import 'package:provider/provider.dart';

class CollectorHistoryScreen extends StatefulWidget {
  final String? name;
  final String? district;

  const CollectorHistoryScreen({
    super.key,
    required this.name,
    required this.district,
  });

  @override
  State<CollectorHistoryScreen> createState() => _CollectorHistoryScreenState();
}

class _CollectorHistoryScreenState extends State<CollectorHistoryScreen> {
  //values for chip
  List values = ['All Visits', 'Approved', 'Rejected', 'Pending'];
  int selectedIndex = 0;

  //filter visits
  List<dynamic> allVisits = [];
  List<dynamic> filteredVisits = [];
  void filterVisits(String filter) {
    setState(() {
      if (filter == 'All Visits') {
        filteredVisits = allVisits; // Show all data
      } else {
        filteredVisits = allVisits
            .where((visit) =>
                visit['status'].toString().toLowerCase() ==
                filter.toLowerCase())
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await Provider.of<VisitProvider>(context, listen: false)
        .fetchData(widget.district.toString());

    if (mounted) {
      setState(() {
        allVisits = data;
        filterVisits('All Visits');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth / 27,
            vertical: screenWidth / 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          filterVisits(values[index]);
                        },
                        child: Chip(
                          backgroundColor: selectedIndex == index
                              ? Colors.black
                              : Colors.white,
                          label: Text(
                            values[index],
                            style: TextStyle(
                              color: selectedIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: screenHeight / 60),

              Text("History of visits", style: TextStyle(fontSize: 20)),

              SizedBox(height: screenHeight / 60),

              // Filtered List Display
              Expanded(
                child: filteredVisits.isEmpty
                    ? Center(
                        child: Text("No visits match the selected filter."))
                    : ListView.builder(
                        itemCount: filteredVisits.length,
                        itemBuilder: (context, index) {
                          var visits = filteredVisits[index];

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tileColor: Colors.grey.shade300,
                              minTileHeight: 80,
                              contentPadding: EdgeInsets.all(10),
                              leading: Text(
                                widget.district
                                    .toString()
                                    .substring(0, 3)
                                    .toUpperCase(),
                                style: TextStyle(fontSize: 20),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Work : ${capitalizeFirstLetter(
                                    visits['title'],
                                  )}'),
                                  Text('Landmark : ${capitalizeFirstLetter(
                                    visits['place'],
                                  )}'),
                                ],
                              ),
                              trailing: statusSymbol(visits['status']),
                              horizontalTitleGap: 25,
                              minLeadingWidth: 20,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitDetailsScreen(
                                    visitData: visits,
                                    dis: widget.district!,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Icon for Status
  Widget statusSymbol(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icon(Icons.check_circle_rounded, color: Colors.green, size: 30);
      case 'rejected':
        return Icon(Icons.cancel_rounded, color: Colors.red, size: 30);
      case 'pending':
        return Icon(Icons.hourglass_bottom, color: Colors.blue, size: 30);
      default:
        return Icon(Icons.help, color: Colors.grey, size: 30);
    }
  }
}

// Helper function to capitalize first letter
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
