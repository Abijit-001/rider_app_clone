import 'package:flutter/material.dart';

import '../screens/location_picker.dart';

class StartLocation extends StatelessWidget {
  StartLocation({
    super.key,
    required this.size,
    required this.startAddress,
  });

  final Size size;
  String startAddress;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50.0,
      left: size.width * 0.05,
      right: size.width * 0.05,
      child: Container(
        padding: EdgeInsets.all(8),
        width: size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: GestureDetector(
          onTap: () async {
            startAddress = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => LocationPicker(),));
            print(startAddress);
          },
          child: Row(
            children: [
              Icon(Icons.circle, color: Colors.greenAccent, size: 12),
              SizedBox(
                width: 5,
              ),
              Text('From : ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  startAddress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
