import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uassnake/home.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDpbRDqsBPw0DVTEbsuHU1EihiK5ZbJjC8",
          authDomain: "uasmobile-9e34f.firebaseapp.com",
          projectId: "uasmobile-9e34f",
          storageBucket: "uasmobile-9e34f.appspot.com",
          messagingSenderId: "979813166934",
          appId: "1:979813166934:web:9861c22255e3142b6630f7",
          measurementId: "G-X5W9LT4L4X"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
