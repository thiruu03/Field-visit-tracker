import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final dynamic Function() ontap;
  final String name;
  final double height;
  final double width;
  final Color textcolor;
  final Color backgroundcolor;

  const MyButton({
    super.key,
    required this.ontap,
    required this.name,
    required this.height,
    required this.width,
    required this.textcolor,
    required this.backgroundcolor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundcolor,
        ),
        padding: EdgeInsets.all(10),
        height: height,
        width: width,
        child: Center(
          child: Text(
            name,
            style: TextStyle(color: textcolor, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
