import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:firebase_core/firebase_core.dart';  // Import Firebase Core
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/wrapper.dart';
import 'package:inventory_management/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // good
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Wrapper(),  // Ensure Wrapper widget is correctly implement
      ),
    );
  }
}
