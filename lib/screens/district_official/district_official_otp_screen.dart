import 'package:flutter/material.dart';
import 'package:inspetto/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:inspetto/screens/district_official/district_official_main_screen.dart';
import 'package:inspetto/utils/my_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class DistrictOfficialOtpScreen extends StatefulWidget {
  final String employeeId;
  const DistrictOfficialOtpScreen({super.key, required this.employeeId});

  @override
  State<DistrictOfficialOtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<DistrictOfficialOtpScreen> {
  TextEditingController pinController = TextEditingController();
  bool _isVerifying = false;

  void verifyOtp(BuildContext context) async {
    setState(() => _isVerifying = true);

    String otp = pinController.text.trim();
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    Future<bool> success = authProvider.verifyOTP(
      otp,
      context,
    );

    if (await success) {
      final empDistrict = await authProvider.getDistrict(widget.employeeId);
      final empName = await authProvider.getName(widget.employeeId);
      final empid = widget.employeeId.toString();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DistrictOfficialMainScreen(
                  empdistrict: empDistrict,
                  empname: empName,
                )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Try again.")),
      );
    }

    setState(() => _isVerifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter the OTP to login", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            PinCodeTextField(
              length: 6,
              obscureText: false,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                selectedColor: Colors.black,
                selectedFillColor: Colors.white,
                inactiveColor: Colors.black,
                inactiveFillColor: Colors.white,
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 40,
                fieldWidth: 40,
              ),
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              controller: pinController,
              appContext: context,
            ),
            SizedBox(height: 10),
            _isVerifying
                ? CircularProgressIndicator()
                : MyButton(
                    ontap: () => verifyOtp(context),
                    name: "Verify OTP",
                    height: 50,
                    width: 300,
                    textcolor: Colors.white,
                    backgroundcolor: Colors.black,
                  ),
          ],
        ),
      ),
    );
  }
}
