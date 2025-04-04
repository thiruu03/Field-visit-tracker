import 'package:flutter/material.dart';

class ProfileBox extends StatelessWidget {
  final String name;
  final String district;
  const ProfileBox({super.key, required this.name, required this.district});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 400,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 80,
            child: Icon(
              Icons.person_2,
              color: Colors.white,
              size: 50,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            name,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            district,
            style: TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
