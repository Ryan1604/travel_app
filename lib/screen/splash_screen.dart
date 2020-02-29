import 'package:flutter/material.dart';
import 'package:travel_app/screen/home.dart';
import 'package:travel_app/utils/helper.dart';
import 'package:travel_app/utils/style.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_)=>HomePage()
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            height: 130,
            width: 130,
            child: Image.asset("assets/images/logo.png")),
      ),
      bottomNavigationBar: Container(
        height: 100,
        width: double.maxFinite,
        child: Text("Powered by Indonesian Student",textAlign: TextAlign.center,style: Text2Style,),
      ),
    );
  }
}

