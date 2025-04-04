
import 'package:flutter/material.dart';
import 'package:inspetto/providers/auth_provider.dart';
import 'package:inspetto/screens/district_official/district_offical_home_screen.dart';
import 'package:inspetto/screens/district_official/district_official_history_screen.dart';
import 'package:inspetto/screens/district_official/new_visit_screen.dart';
import 'package:inspetto/utils/profile_box.dart';
import 'package:provider/provider.dart';

class DistrictOfficialMainScreen extends StatefulWidget {
  final String? empdistrict;
  final String? empname;

  const DistrictOfficialMainScreen({
    super.key,
    required this.empdistrict,
    required this.empname,
  });

  @override
  DistrictOfficialHomeScreenState createState() =>
      DistrictOfficialHomeScreenState();
}

class DistrictOfficialHomeScreenState
    extends State<DistrictOfficialMainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AuthProvider authProvider = AuthProvider();



  @override
  Widget build(BuildContext context) {
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 30),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: ProfileBox(
                    name: capitalizeFirstLetter(
                      widget.empname.toString(),
                    ),
                    district: capitalizeFirstLetter(
                      widget.empdistrict.toString(),
                    ),
                  ),
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Logout Confirmation"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(), // Close dialog
                        child: Text("Cancel",
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () async {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.logout(
                              context); // Perform logout and close dialog
                        },
                        child:
                            Text("Logout", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: _selectedIndex == 0
          ? DistrictOfficalHomeScreen(
              empd: widget.empdistrict,
              empn: widget.empname,
            )
          : DistrictOfficialHistoryScreen(
              name: widget.empname.toString(),
              district: widget.empdistrict.toString(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewVisitScreen(
                  district: widget.empdistrict,
                ),
              ));
        },
        child: Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.all(0),
        shape: CircularNotchedRectangle(),
        notchMargin: 11,
        child: BottomNavigationBar(
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
