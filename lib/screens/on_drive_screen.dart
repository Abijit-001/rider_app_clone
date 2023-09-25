import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../widgets/payment_button.dart';

class OnDriveScreen extends StatefulWidget {
  const OnDriveScreen(
      {super.key,
      required this.startAddress,
      required this.endAddress,
      required this.polylineCoordinates,
      required this.distance,
      required this.cost,
      required this.totalCost});

  final startAddress;
  final endAddress;
  final List<LatLng> polylineCoordinates;
  final distance;
  final cost;
  final totalCost;

  @override
  State<OnDriveScreen> createState() => _OnDriveScreenState();
}

class _OnDriveScreenState extends State<OnDriveScreen> {
 /* Map<String, dynamic>? paymentIntent;

  Future<void> payment() async {
    print('${widget.totalCost}');

    try {
      Map<String, dynamic> body = {
        'amount': "${widget.totalCost}00",
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

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }*/

  void locationProgress() {
    Timer.periodic(
        const Duration(
          milliseconds: 100,
        ), (timer) {
      if (widget.polylineCoordinates.length > 1) {
        setState(() {
          widget.polylineCoordinates.removeAt(0);
        });
      } else {
        openPaymentModal();
        timer.cancel();
      }
    });
  }

  void openPaymentModal() {
    showModalBottomSheet(

      isDismissible: false,
      context: context,
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: [
              const SizedBox(
                height: 20,
              ),
              const Text("Make Payment",
                  style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Text("Distance traveled ${widget.distance}km",
                  style: TextStyle(fontSize: 17)),
              const SizedBox(
                height: 10,
              ),
              Text("Cost (km) BDT ${widget.cost}",
                  style: TextStyle(fontSize: 17)),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Total cost : BDT ${widget.totalCost}",
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              PaymentButton(amount: widget.totalCost),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  /*void openPaymentModal() {
    print('object');
    Alert(
        style: AlertStyle(
          backgroundColor: Colors.white,
        ),
        context: context,
        title: 'Make Payment',
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text("Distance traveled ${widget.distance}km",
                style: TextStyle(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            Text("Cost (km) BDT ${widget.cost}",
                style: TextStyle(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Total cost : BDT ${widget.totalCost}",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        buttons: [DialogButton(
            color: Colors.blue,
            child: const Text(
              "PAY NOW",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            onPressed: ()
              async {
                await payment();
              },
          )
        ]).show();
  }*/

  @override
  void initState() {
    locationProgress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.startAddress,
        zoom: 13.5,
      ),
      markers: {
        Marker(
            markerId: const MarkerId("source"),
            position: widget.polylineCoordinates[0],
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen)),
        Marker(
            markerId: const MarkerId("destination"),
            position: widget.endAddress,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
        /*Marker(
            markerId: const MarkerId("my_location"),
            position:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            icon: markerIcon),
        for (final mark in markers) mark*/
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId("route"),
          points: widget.polylineCoordinates,
          color: const Color(0xFF000000),
          width: 7,
        ),
      },
    );
  }
}
