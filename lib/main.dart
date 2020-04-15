import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import './login.dart';
import 'package:video_player/video_player.dart';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController animationController;
  Animation<double> animation;
  double height = 0;
  double width = 0;
  VideoPlayerController _controller;

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
    _controller =
        VideoPlayerController.asset('assets/video/finallogoanimation.mp4');
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
    _controller.addListener(() {
      print(_controller.value.position);
   
      
      if (_controller.value.position.inSeconds == 6) {
        Navigator.of(context).pushReplacementNamed('/HomeScreen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffD88DD4),
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
             
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio/1.5,
                child: VideoPlayer(_controller),
              ),
            ),
            
          ],
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
