import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app/screen/splash_screen.dart';

void main()=>runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Color(0xFF21243d),systemNavigationBarColor: Colors.transparent),
          child: SplashScreen()),
      title: "DEMO",

    );
  }
}


