import 'package:flutter/material.dart';
import './login.dart';

import 'package:splashscreen/splashscreen.dart';
import './mapScreen.dart';

import 'dart:async';

void main() {
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      bottomAppBarColor:  Color(0xff905c96),
    
    ),
    
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      '/HomeScreen': (BuildContext context) => new LogIn()
    },
  ));
}
void backgroundFetchHeadlessTask() async {
  print('[BackgroundFetch] Headless event received.');
  //BackgroundFetch.finish();
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
              "assets/images/logo.png",
            ),
            fit: BoxFit.fill),
      ),
    );
  }
}

