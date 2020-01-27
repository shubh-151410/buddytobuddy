import 'dart:async';

import 'package:BuddyToBody/SettingUi.dart';
import 'package:BuddyToBody/chat.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './schedule.dart';
import 'buddyScheduling.dart';
import './SettingUi.dart';
import './HomeScreen.dart';

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  double lattitude;
  double langitude;
  LatLng _center;
  int _currentIndex = 0;
  Position currentLocation;
  String id;
  SharedPreferences prefs;
  Geolocator geolocator = Geolocator();
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Completer<GoogleMapController> _controller = Completer();

  TextEditingController controllerAddress = TextEditingController();
  CollectionReference collectionReference =
      Firestore.instance.collection('users');

  final List<Widget> _children = [
    HomeScreen(),
    ScheduleBuddy(),
    BuddyScheduling(),
    SettingScreen()
  ];

  double zoomCamera;

  @override
  void initState() {
    super.initState();

    getUserLocation();
//    getUserData();
    readlocal();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  readlocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    await Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'isActive': true});
  }

  Future<Position> locateUser() {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    try {
      currentLocation = await locateUser();
      lattitude = currentLocation.latitude;
      langitude = currentLocation.longitude;
      setState(() {
        lattitude = currentLocation.latitude;
        langitude = currentLocation.longitude;
      });
    } on Exception {
      currentLocation = null;
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xff905c96),
        ),
        child: BottomNavigationBar(
          elevation: 5.0,
          backgroundColor: Color(0xff905c96),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          unselectedLabelStyle: TextStyle(color: Colors.white),
          selectedFontSize: 15.0,
          onTap: onTabTapped, // new
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat), title: Text("Chat")),
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule), title: Text("Schedule")),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text("Setting")),
          ],
        ),
      ),
      body: _children[_currentIndex],
    );
  }
}
