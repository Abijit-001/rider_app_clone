import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rider_app_clone/screens/route_tracker_screen.dart';

import '../data/dummy_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

class PaymentButton extends StatefulWidget {
  const PaymentButton({
    super.key,
    required this.amount,
  });

  final int amount;

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> {
  Map<String, dynamic>? paymentIntent;

  Future<void> payment() async {
    print('${widget.amount}');

    try {
      Map<String, dynamic> body = {
        'amount': "${widget.amount}00",
        'currency': "BDT",
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51Njh5MBrgg9vq6KSWxReEvKMARIecrWPksvJtCKNH6cDBShXcXLVqZLsf5UUU15BqjFSzOBowcV7xofycQ9Gcv3N00Nphmevz5',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      paymentIntent = json.decode(response.body);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
        ),
      );
    }

    await stripe.Stripe.instance
        .initPaymentSheet(
            paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Abijit',
        ))
        .then((value) {});

    try {
      await stripe.Stripe.instance.presentPaymentSheet().then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Successful'),
          ),
        );
      });
    } catch (e) {}

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RouteTrackerScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
      onPressed: () async {
        await payment();
      },
      child: const Text(
        'PAY NOW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
