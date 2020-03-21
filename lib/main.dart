import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import './login.dart';

import 'package:splashscreen/splashscreen.dart';
import './mapScreen.dart';

import 'dart:async';

void main() {
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(
    new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomAppBarColor: Color(0xff905c96),
      ),
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/HomeScreen': (BuildContext context) => new LogIn()
      },
    ),
  );
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void backgroundFetchHeadlessTask(String taskId) async {
  BackgroundFetch.finish(taskId);
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;
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
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
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
