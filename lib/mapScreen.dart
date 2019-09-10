import 'package:BuddyToBody/SettingUi.dart';
import 'package:BuddyToBody/profilescreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/cupertino.dart';

import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  double lattitude;
  double langitude;
  LatLng _center;
  Position currentLocation;
  Geolocator geolocator = Geolocator();
  Completer<GoogleMapController> _controller = Completer();

  TextEditingController controllerAddress = TextEditingController();
  CollectionReference collectionReference =
      Firestore.instance.collection('userdetails');

  double zoomCamera;

  @override
  void initState() {
    super.initState();

    getUserLocation();
//    getUserData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
            child: Container(
          height: 63.0,
          decoration: new BoxDecoration(
              color: Colors.transparent,
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0))),
          child: new Opacity(
              opacity: 0.8,
              child: Container(
                decoration: new BoxDecoration(
                    color: Color(0xff002064),
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(50.0),
                        topRight: const Radius.circular(50.0))),
                child: new Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // SizedBox(width: 22.0),
                    Container(
                      height: 35,
                      width: 35,
                      child: Image.asset(
                        "assets/images/Home.png",
                        color: Colors.white,
                      ),
                    ),
                    // SizedBox(width: 40.0),
                    Container(
                      height: 35,
                      width: 35,
                      child: Image.asset(
                        "assets/images/shopping-cart.png",
                        color: Colors.white,
                      ),
                    ),
                    //SizedBox(width: 40.0),
                    Container(
                      height: 35,
                      width: 35,
                      child: Image.asset(
                        "assets/images/Chat.png",
                        color: Colors.white.withOpacity(1.0),
                      ),
                    ),
                    // SizedBox(
                    //   width: 40,
                    // ),
                    Container(
                      height: 35,
                      width: 35,
                      child: Image.asset(
                        "assets/images/Schedule.png",
                        color: Colors.white,
                      ),
                    ),
                    //SizedBox(width: 50),
                    Container(
                        height: 35,
                        width: 35,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingScreen()),
                            );
                          },
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 40.0,
                          ),
                        ))
                  ],
                )),
              )),
        )),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('userdetails').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return googlemap(context, snapshot);
            } else {
              return Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        backgroundColor: Colors.black,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Loading...",
                        style: TextStyle(),
                      )
                    ],
                  ),
                ),
              );
            }
          },
        ));
  }

  Widget googlemap(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    GoogleMapController mapController;
    if (lattitude != null && langitude != null) {
      return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition:
              CameraPosition(target: LatLng(lattitude, langitude), zoom: 10),
          zoomGesturesEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController.setMapStyle(
                '[{"featureType": "all","stylers": [{ "color": "#C0C0C0" }]},{"featureType": "road.arterial","elementType": "geometry","stylers": [{ "color": "#CCFFFF" }]},{"featureType": "landscape","elementType": "labels","stylers": [{ "visibility": "off" }]}]');
          },
          markers: Set<Marker>.of(<Marker>[
            for (int i = 0; i < snapshot.data.documents.length; i++)
              Marker(
                visible: true,
                draggable: true,
                markerId: MarkerId("$i"),
                position: LatLng(
                    double.parse(snapshot.data.documents[i]["lattitude"]),
                    double.parse(snapshot.data.documents[i]["longitude"])),
                icon: BitmapDescriptor.defaultMarker,
                onTap: () {
                  print(snapshot.data.documents[i]["About"]);
                  profileDialogInfo(
                      snapshot.data.documents[i]["name"],
                      snapshot.data.documents[i]["photoUrl"],
                      snapshot.data.documents[i]["About"]);
                },
              ),
          ]));
    } else {
      return Container();
    }
  }

  Future<void> profileDialogInfo(
      String name, String photoUrl, String about) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return customDialog(name, photoUrl, about);
        });
  }
}

class customDialog extends StatefulWidget {
  static String userName;
  static String userphotoUrl;
  static String About;
  customDialog(String name, String photoUrl, String about) {
    userName = name;
    userphotoUrl = photoUrl;
    About = about;
  }
  @override
  _customDialogState createState() => _customDialogState();
}

class _customDialogState extends State<customDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.white,
      child: dialog(context),
    );
  }

  Widget dialog(BuildContext context) {
    print(customDialog.About);
    print(customDialog.userName);
    return Container(
      height: 400,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(color: Color(0xff2183e7)),
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 0.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                ),
              )),
          Center(
              child: Stack(
            children: <Widget>[
              (customDialog.userphotoUrl != '')
                  ? Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                          width: 90.0,
                          height: 90.0,
                          padding: EdgeInsets.all(20.0),
                        ),
                        imageUrl: customDialog.userphotoUrl,
                        width: 90.0,
                        height: 90.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(45.0)),
                      clipBehavior: Clip.hardEdge,
                    )
                  : Icon(
                      Icons.account_circle,
                      size: 90.0,
                      color: Colors.grey,
                    )
            ],
          )),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  customDialog.userName,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 113,
              margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              padding: EdgeInsets.only(left: 50.0, right: 50.0),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  "ABOUT",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          (customDialog.About != '')
                              ? Text(
                                  customDialog.About,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                )
                              : Text("about")
                        ],
                      )
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                  color: Color(0xff052e73),
                  borderRadius: BorderRadius.circular(20.0)),
            ),
          )
        ],
      ),
    );
  }
}

//
