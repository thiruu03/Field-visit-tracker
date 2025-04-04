import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inspetto/providers/auth_provider.dart';
import 'package:inspetto/providers/location_provider.dart';
import 'package:inspetto/providers/visit_provider.dart';
import 'package:inspetto/splash_screen.dart';
import 'package:inspetto/themes/my_theme.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => VisitProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late VideoPlayerController controller;
  late Future<List<String>> rollCheck;
  @override
  void initState() {
    super.initState();
    rollCheck =
        Provider.of<AuthProvider>(context, listen: false).getLoginStatus();
    Provider.of<AuthProvider>(context, listen: false).debugFirestoreData();
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(rollCheck: rollCheck),
      theme: lightMode,
    );
  }
}
