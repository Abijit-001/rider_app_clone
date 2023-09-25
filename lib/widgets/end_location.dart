import 'package:flutter/material.dart';


class EndLocation extends StatelessWidget {
  const EndLocation({
    super.key,
    required this.size,
    required this.endAddress,
  });

  final Size size;
  final String endAddress;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.0,
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
        child: Row(
          children: [
            Icon(Icons.circle, color: Colors.red, size: 12),
            SizedBox(
              width: 5,
            ),
            Text(
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
    );
  }
}