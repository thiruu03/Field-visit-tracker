import 'package:flutter/material.dart';
import 'package:inspetto/providers/auth_provider.dart';
import 'package:inspetto/screens/district_official/district_official_otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:inspetto/utils/my_button.dart';

class DistrictOfficialLoginScreen extends StatefulWidget {
  const DistrictOfficialLoginScreen({super.key});

  @override
  State<DistrictOfficialLoginScreen> createState() =>
      _DistrictOfficialLoginScreenState();
}

class _DistrictOfficialLoginScreenState
    extends State<DistrictOfficialLoginScreen> {
  final TextEditingController dtcontroller = TextEditingController();
  bool _isLoading = false;

  void handleLogin(BuildContext context) async {
    if (dtcontroller.text.trim().length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid ID")),
      );
      return;
    }

    setState(() => _isLoading = true);

    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    String employeeId = dtcontroller.text.trim().toUpperCase();

    String? phoneNumber = await authProvider.getPhoneNumber(employeeId);

    if (phoneNumber != null) {
      authProvider.sendOTP(phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP sent successfully")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DistrictOfficialOtpScreen(
                  employeeId: employeeId,
                )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Employee ID not found")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("District Official", style: TextStyle(fontSize: 30)),
            SizedBox(height: 20),
            TextField(
              controller: dtcontroller,
              decoration: InputDecoration(
                hintText: "Enter the employee ID",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : MyButton(
                    ontap: () => handleLogin(context),
                    name: "Login",
                    height: 60,
                    width: 340,
                    textcolor: Colors.white,
                    backgroundcolor: Colors.black,
                  ),
          ],
        ),
      ),
    );
  }
}
