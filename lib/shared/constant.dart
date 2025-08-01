import 'package:flutter/material.dart';

const kFirebaseKey = 'AIzaSyCskZyvjWUG-nDX7tVWCgtWZViDekSxWds';

var textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue.shade100, width: 2.0),
  ),
);

 const myTextInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black87, width: 1.0),
  ),
);


var textInputD = const InputDecoration(
  fillColor: Colors.white,
  filled: true,
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color:Colors.black87, width: 1.0),
  ),
);

var textInput = const InputDecoration(
  fillColor: Colors.white,
  filled: true,
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color:Colors.black87, width: 1.0),
  ),
  contentPadding: EdgeInsets.symmetric(
      vertical: 30.0,
      horizontal: 12.0), // Increase vertical padding to make the field taller
);

var textdecoration = InputDecoration(
  hintStyle: const TextStyle(
    fontWeight: FontWeight.normal, // Adjust the font weight as needed
    color: Colors.grey, // Optional: Change the color of the hint text
  ),
  fillColor: Colors.white,
  filled: true,
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue.shade100, width: 2.0),
  ),
);
