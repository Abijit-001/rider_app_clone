import 'package:flutter/material.dart';

import '../model/vehicle_model.dart';

class ModalExpansionTile extends StatelessWidget {
  const ModalExpansionTile({
    super.key,
    required this.vehicle,
    required this.distance,
  });

  final Vehicle vehicle;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        leading: CircleAvatar(
          child: Image.asset(vehicle.logo),
        ),
        title: Text(vehicle.name),
        subtitle: Text(vehicle.moto),
        trailing: Text(
          'BDT ${(distance * vehicle.priceKm).ceil()}.',
          style: TextStyle(fontSize: 14),
        ),
        // onTap: () {},

        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Price per km : "),
                Text("BDT ${vehicle.priceKm}"),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Total distance in km : "),
                Text("${distance} km"),
              ]),
          Text("People"),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("People"),
                Text("${vehicle.people}"),
              ]),
        ]);
  }
}