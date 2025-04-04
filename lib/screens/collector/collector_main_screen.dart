import 'package:flutter/material.dart';
import 'package:inspetto/providers/auth_provider.dart';
import 'package:inspetto/providers/biometric_provider.dart';
import 'package:inspetto/screens/collector/collector_history_screen.dart';
import 'package:inspetto/screens/collector/collector_home_screen.dart';
import 'package:inspetto/utils/profile_box.dart';
import 'package:provider/provider.dart';

class CollectorMainScreen extends StatefulWidget {
  final String? name;
  final String? district;

  const CollectorMainScreen({
    super.key,
    required this.name,
    required this.district,
  });

  @override
  State<CollectorMainScreen> createState() => _CollectorMainScreenState();
}

class _CollectorMainScreenState extends State<CollectorMainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  BiometricService biometricService = BiometricService();

  @override
void initState() {
  super.initState();
  _checkAndSaveFingerprint(); // Call the async function
}

void _checkAndSaveFingerprint() async {
  bool isData = await biometricService.checkFingerprint();

  if (!isData) {
    await biometricService.saveFingerprint(); // Await fingerprint saving
  }

  if (mounted) {
    setState(() {}); // Ensure the widget is still mounted before updating state
  }
}

  @override
  Widget build(BuildContext context) {
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
                      widget.name.toString(),
                    ),
                    district: capitalizeFirstLetter(
                      widget.district.toString(),
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
          ? CollectorHomeScreen(
              empd: widget.district,
              empn: widget.name,
            )
          : CollectorHistoryScreen(
              name: capitalizeFirstLetter(widget.name.toString()),
              district: widget.district.toString(),
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
