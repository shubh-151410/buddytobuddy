import 'package:BuddyToBody/SettingUi.dart';
import 'package:BuddyToBody/profilescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
                                  builder: (context) => Profile()),
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
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
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
                  infoWindow:
                      InfoWindow(title: snapshot.data.documents[i]["name"])),
          ]));
    } else {
      return Container();
    }
  }
}
