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
    with TickerProviderStateMixin , WidgetsBindingObserver {
  AnimationController animationController;
  Animation<double> animation;
  double height = 0;
  double width = 0;

  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, navigationPage);
  }
  // WidgetsBinding.instance.addObserver(LifecycleEventHandler(
  //   detachedCallBack: () async => widget.appController.persistState(),
  //   resumeCallBack: () async {
  //     _log.finest('resume...');
  //   }));

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 2),
    );
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeIn);

    animation.addListener(() => this.setState(() {}));
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        startTime();
      }
    });
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/newbubbylogo.png",
          width: animation.value * (height * 4),
          height: animation.value * (height * 4),
        ),
      ),
    );
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      break;
      case AppLifecycleState.paused:
      break;
      case AppLifecycleState.detached:
        
      break;
      case AppLifecycleState.resumed:
        
        break;
    }
}
    }
