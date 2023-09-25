import 'package:flutter/material.dart';
import 'package:rider_app_clone/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/ola_splash_image.jpg'),
        const SizedBox(
          height: 20,
        ),
        Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Text('Explore new ways to travel with Ola',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start)),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SigninScreen(),));
              },
              child: const Hero(
                tag: 'continue_with_email',
                child: Text(
                  'Continue with Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    ));
  }
}
