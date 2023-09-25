import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:rider_app_clone/consts/color.dart';
import 'package:rider_app_clone/screens/home_screen.dart';
import 'package:rider_app_clone/screens/signin_screen.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Stripe.publishableKey = "pk_test_51Njh5MBrgg9vq6KSHqVET8jncwNv4sg1D8NazRCfEzYS8NratKjt58twODtdXPybLOOz1lBxashUicm8rYApCw3p00OUCfqGWD";

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorConstants.kLightGreen),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
