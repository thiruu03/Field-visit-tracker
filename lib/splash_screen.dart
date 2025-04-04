import 'package:flutter/material.dart';
import 'package:inspetto/screens/collector/collector_main_screen.dart';
import 'package:inspetto/screens/district_official/district_official_main_screen.dart';
import 'package:inspetto/screens/login_selection_screen.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final Future<List<String>> rollCheck;
  const SplashScreen({super.key, required this.rollCheck});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/intro.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      }).catchError((e) {
        print("Error initializing video: $e");
      });
    _controller.setLooping(false);
    _controller.setVolume(1.0); // Ensure volume is ON
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));
    List<String> userData = await widget.rollCheck;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            if (userData.isNotEmpty && userData[0].isNotEmpty) {
              if (userData[0] == "District Official") {
                return DistrictOfficialMainScreen(
                  empdistrict: userData[2],
                  empname: userData[1],
                );
              } else if (userData[0] == "District collector") {
                return CollectorMainScreen(
                  name: userData[1],
                  district: userData[2],
                );
              }
            }
            return LoginSelectionScreen();
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container() // Debug message
          ),
    );
  }
}
