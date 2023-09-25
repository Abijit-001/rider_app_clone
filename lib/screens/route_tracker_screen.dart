import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as range;
import 'package:location/location.dart';

import '../data/dummy_data.dart';
import '../widgets/payment_button.dart';
import 'location_picker.dart';
import 'on_drive_screen.dart';

class RouteTrackerScreen extends StatefulWidget {
  const RouteTrackerScreen({super.key});

  @override
  State<RouteTrackerScreen> createState() => _RouteTrackerScreenState();
}

class _RouteTrackerScreenState extends State<RouteTrackerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng sourceLocation = LatLng(23.75536416198514, 90.37418030065523);
  var destination;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor riderIcon = BitmapDescriptor.defaultMarker;

  List<LatLng> polylineCoordinates = [];
  List<LatLng> ridersInRange = [];
  List<LatLng> riders = [
    LatLng(23.755614979384816, 90.37339084758224),
    LatLng(23.756439840232474, 90.37501090179913),
    LatLng(23.75629254403587, 90.37480705391754),
    LatLng(23.752845765456474, 90.369764501057),
    LatLng(23.753120725479388, 90.37732833035844),
    LatLng(23.751608438022103, 90.37833684094413),
    LatLng(23.751310492632502, 90.36833057111946),
  ];
  LocationData? currentLocation;
  LatLng currentLocationMarker =
      const LatLng(23.75536416198514, 90.37418030065523);
  final Set<Marker> markers = Set();

  // var address = 'Please pick a place...';
  var startAddress = '';
  var endAddress = 'Please pick a place...';
  var distance = 0.00;
  var duration = '';
  int selected = -1;
  var cost = 0;
  bool isLoading = true;

  void getPolyPoints() async {
    polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDLcwxUggpPZo8lcbH0TB4Crq5SJjtj4ag',
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      optimizeWaypoints: true,
    );

    distance = result.distanceValue! / 1000;
    duration = result.duration!;
    endAddress = result.endAddress!;
    startAddress = result.startAddress!;

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        // print(point);
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      });

      setState(() {});
    }

    /*print("All points : ");
    for (final i in polylineCoordinates) {
      print(i);
    }*/
  }

  Future _getAddress(LatLng position) async {
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude, position.longitude);
    geo.Placemark address = placemarks[0];
    String addresStr =
        "${address.street}, ${address.locality}, ${address.administrativeArea}, ${address.country}";
    return addresStr;
  }

  void _setStartAddress(LatLng position) async {
    startAddress = await _getAddress(position);
    getPolyPoints();
    _findRider(position);
    setState(() {});
  }

  void _setEndAddress(LatLng position) async {
    endAddress = await _getAddress(position);
    getPolyPoints();
    setState(() {});
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _findRider(LatLng position) {
    markers.clear();
    for (final i in riders) {
      double distanceInMeters = _coordinateDistance(
            position.latitude,
            position.longitude,
            i.latitude,
            i.longitude,
          ) *
          1000;
      print("distanceInMeters : $distanceInMeters");
      if (distanceInMeters < 500) {
        ridersInRange.add(i);
        markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position: i,
          icon: riderIcon, //Icon for Marker
        ));
      }
    }
    print("ridersInRange : $ridersInRange");
    /* for (final i in ridersInRange){
      Marker(
          markerId: const MarkerId("my_location$i"),
          position: LatLng(currentLocation!.latitude!,
              currentLocation!.longitude!),
          icon: markerIcon),
  }*/
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 5), (t) {
      setState(() {
        isLoading = false; //set loading to false
      });
      t.cancel(); //stops the timer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Found Rider'),
        ),
      );
    });
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    await myLocation();
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;

        sourceLocation =
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
        setState(() {});
      },
    );
  }

  Future<void> myLocation() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 13.5,
          target: LatLng(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
          ),
        ),
      ),
    );
  }

  void _openModal() {
    int selectedIndexExpansionTile = -1;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(height: 10,),
                  const SizedBox(width: double.infinity,child: Icon(Icons.keyboard_double_arrow_down_sharp,),),
                  for (var i = 0; i < availableVehicle.length; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                      child: ExpansionTile(
                          key: Key(selectedIndexExpansionTile.toString()),
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          collapsedShape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          leading: CircleAvatar(
                            child: Image.asset(availableVehicle[i].logo),
                          ),
                          title: Text(availableVehicle[i].name),
                          subtitle: Text(availableVehicle[i].moto),
                          trailing: Text(
                            'BDT ${(distance * availableVehicle[i].priceKm).ceil()}.',
                            style: TextStyle(fontSize: 14),
                          ),
                          initiallyExpanded: i == selected,
                          onExpansionChanged: (expanded) {
                            if (expanded) {
                              setState(() {
                                selected = i;
                                selectedIndexExpansionTile = i;
                                cost = (distance * availableVehicle[i].priceKm)
                                    .ceil();
                              });
                            } else {
                              selectedIndexExpansionTile = -1;
                            }
                            setState(() {});
                          },
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text("Price per km : "),
                                  Text("BDT ${availableVehicle[i].priceKm}"),
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text("Total distance in km : "),
                                  Text("$distance km"),
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text("People : "),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                      "\u{1F464} ${availableVehicle[i].people}"),
                                ]),
                          ]),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                      ),
                    ),
                    onPressed: () {
                      if (selected < 0) {
                        return;
                      }

                      Navigator.pop(context);
                      startTimer();
                      /*isLoading
                          ? showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Finding ${availableVehicle[selected].name} for you...",
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const LinearProgressIndicator(),
                                    ],
                                  ),
                                );
                              },
                            )
                          :*/
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnDriveScreen(
                            totalCost: (distance * availableVehicle[selected].priceKm).ceil(),
                            startAddress: sourceLocation,
                            endAddress: destination,
                            polylineCoordinates: polylineCoordinates,
                            distance: distance,
                            cost: availableVehicle[selected].priceKm,
                          ),
                        ),
                      );
                    },
                    child: selected >= 0
                        ? Text(
                            "Book a ${availableVehicle[selected].name}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )
                        : const Text(
                            "Book a vehicle",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  /*PaymentButton(
                    selected: selected,
                    amount: selected >= 0
                        ? (distance * availableVehicle[selected].priceKm).ceil()
                        : 0,
                  ),*/
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            "assets/logo/map_marker.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            "assets/logo/motorcycle_small.png")
        .then(
      (icon) {
        setState(() {
          riderIcon = icon;
        });
      },
    );
  }

  @override
  void initState() {
    // getPolyPoints();
    addCustomIcon();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            /*onTap: (argument) {
              destination = argument;
              getPolyPoints();
              // _findLocation(argument.latitude, argument.longitude);
            },*/
            zoomControlsEnabled: false,
            trafficEnabled: true,
            initialCameraPosition: CameraPosition(
              target: sourceLocation,
              zoom: 13.5,
            ),
            markers: destination != null
                ? {
                    Marker(
                        markerId: const MarkerId("source"),
                        position: sourceLocation,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen)),
                    Marker(
                        markerId: const MarkerId("destination"),
                        position: destination,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed)),
                    Marker(
                        markerId: const MarkerId("my_location"),
                        position: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!),
                        icon: markerIcon),
                    for (final mark in markers) mark
                  }
                : {
                    Marker(
                        markerId: const MarkerId("source"),
                        position: sourceLocation,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen)),
                  },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: polylineCoordinates,
                color: const Color(0xFF000000),
                width: 7,
              ),
            },
            circles: {
              Circle(
                circleId: const CircleId('1'),
                center: sourceLocation,
                radius: 450,
                strokeWidth: 1,
                fillColor: Colors.blue.withOpacity(0.2),
              ),
            },
            onMapCreated: (mapController) {
              _controller.complete(mapController);
            },
          ),
          Positioned(
            top: 50.0,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: Container(
              padding: EdgeInsets.all(8),
              width: size.width * 0.9,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      sourceLocation =
                          await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LocationPicker(),
                      ));
                      _setStartAddress(sourceLocation);
                    },
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          const SizedBox(width: 5,),
                          const Icon(Icons.circle,
                              color: Colors.greenAccent, size: 12),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text('From : ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              startAddress,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await myLocation();
                            },
                            icon: const Icon(Icons.my_location, size: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      destination =
                          await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LocationPicker(),
                      ));
                      _setEndAddress(destination);
                    },
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(Icons.circle, color: Colors.red, size: 12),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'To : ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Expanded(
                            child: Text(
                              endAddress,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // StartLocation(size: size, startAddress: startAddress),
          /*Positioned(
            top: 100.0,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: Container(
              padding: const EdgeInsets.all(8),
              width: size.width * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child:
            ),
          ),*/
          bottomPriceSheet(size, context),
        ],
      ),
    );
  }

  Positioned bottomPriceSheet(Size size, BuildContext context) {
    return Positioned(
      bottom: 20.0,
      left: size.width * 0.05,
      right: size.width * 0.05,
      child: Container(
        padding: EdgeInsets.all(8),
        width: size.width * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            int sensitivity = 8;
            if (details.delta.dy > sensitivity) {
              // Down Swipe
            } else if (details.delta.dy < -sensitivity) {
              // Up Swipe
              print("Swipe up : $sensitivity");
              _openModal();
            }
          },
          onTap: _openModal,
          child: Column(
            children: [
              const SizedBox(width: double.infinity,child: Icon(Icons.keyboard_double_arrow_up_sharp,),),
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Text(
                    'Total Distance : ',
                  ),
                  Expanded(
                    child: Text(
                      '${distance.toStringAsFixed(2)} km.',
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Text(
                    'Total Time : ',
                  ),
                  Expanded(
                    child: Text(
                      '$duration.',
                    ),
                  ),
                ],
              ),
              ListTile(
                tileColor: Theme.of(context).colorScheme.secondaryContainer,
                leading:
                    CircleAvatar(child: Image.asset('assets/logo/bike.png')),
                title: Text('Bike'),
                subtitle: Text('Beat the traffic on a bike'),
                trailing: Text(
                  'BDT ${(distance * 25).ceil()}.',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: _openModal,
              ),
              ListTile(
                tileColor: Theme.of(context).colorScheme.secondaryContainer,
                leading:
                    CircleAvatar(child: Image.asset('assets/logo/mini.png')),
                title: Text('Mini'),
                subtitle: Text('Comfy,economical cars'),
                trailing: Text(
                  'BDT ${(distance * 45).ceil()}.',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: _openModal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
