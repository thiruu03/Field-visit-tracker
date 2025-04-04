import 'package:flutter/material.dart';
import 'package:inspetto/screens/Collector/collector_login_screen.dart';
import 'package:inspetto/screens/district_official/district_official_login_screen.dart';
import 'package:inspetto/utils/my_button.dart';

class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight / 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Inspetto.",
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'mont',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: screenHeight / 4,
              ),
              Text(
                "Login as",
                style: TextStyle(color: Colors.black, fontSize: 19),
              ),
              SizedBox(
                height: screenHeight / 19,
              ),
              MyButton(
                ontap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DistrictOfficialLoginScreen(),
                    ),
                  );
                },
                name: "District offcial",
                height: 50,
                width: 320,
                textcolor: Colors.white,
                backgroundcolor: Colors.black,
              ),
              SizedBox(
                height: screenHeight / 30,
              ),
              Text(
                'OR',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              SizedBox(
                height: screenHeight / 30,
              ),
              MyButton(
                ontap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectorLoginScreen(),
                    ),
                  );
                },
                name: "HOD / Collector",
                height: 50,
                width: 320,
                textcolor: Colors.white,
                backgroundcolor: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
