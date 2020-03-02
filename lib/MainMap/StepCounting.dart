import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:toast/toast.dart';
import './map_request.dart';

class StepCounting extends StatefulWidget {
  final double lattitude;
  final double longitude;
  StepCounting({@required this.lattitude, @required this.longitude});
  @override
  _StepCountingState createState() => _StepCountingState(
      destinationlattitude: lattitude, destinationlongitude: longitude);
}

class _StepCountingState extends State<StepCounting> {
  final double destinationlattitude;
  final double destinationlongitude;
  _StepCountingState(
      {@required this.destinationlattitude,
      @required this.destinationlongitude});
  Pedometer _pedometer;
  StreamSubscription<int> _subscription;
  String _stepCountValue = '0';

  Completer<GoogleMapController> _controller = Completer();
  double lattitude;
  double langitude;
  final Set<Polyline> _polyLines = {};
  final List<Marker> _markers = List();
  Set<Polyline> get polyLines => _polyLines;
  LatLng _center;
  Position currentLocation;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Geolocator geolocator = Geolocator();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
   // startMain();
    initPlatformState();
  }

  startMain() async {
    await firebaseCloudMessaging_Listeners();
  }

  firebaseCloudMessaging_Listeners() async {
    await _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        // await _showNotificationWithoutSound();
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );

    _firebaseMessaging.autoInitEnabled();
  }

  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print(data);
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  Future<void> initPlatformState() async {
    startListening();
  }

  void startListening() {
    _pedometer = new Pedometer();
    _subscription = _pedometer.pedometerStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void _onData(int stepCountValue) async {
    setState(() => this._stepCountValue = "$stepCountValue");
  }

  void stopListening() {
    _subscription.cancel();
  }

  void _onDone() => print("Finished pedometer tracking");

  void _onError(error) => print("Flutter Pedometer Error: $error");

  Future<Position> locateUser() {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    try {
      currentLocation = await locateUser();
      lattitude = currentLocation.latitude;
      langitude = currentLocation.longitude;
      await sendRequest(lattitude, langitude);
      setState(() {
        lattitude = currentLocation.latitude;
        langitude = currentLocation.longitude;
      });
    } on Exception {
      currentLocation = null;
    }
  }

  Future sendRequest(double originlatitide, double originlongitude) async {
    String route = await GoogleMapsServices().getRouteCoordinates(
        originlatitide,
        originlongitude,
        destinationlattitude,
        destinationlongitude);
    await createRoute(route);
    // _addMarker(
    //     LatLng(destinationlattitude, destinationlongitude), "KTHM Collage");
  }

  Future createRoute(String encondedPoly) async {
    _polyLines.add(
      Polyline(
          polylineId: PolylineId("a"),
          width: 4,
          visible: true,
          points: _convertToLatLng(_decodePoly(encondedPoly)),
          color: Colors.black),
    );
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId("112"),
        position: location,
        icon: BitmapDescriptor.defaultMarker));
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          googlemap(),
          Positioned(
            right: 20.0,
            top: 30.0,
            child: Opacity(
              opacity: 0.8,
              child: InkWell(
                onTap: () {
                  stopListening();
                  Toast.show("Buddy Stop", context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                },
                child: ClipOval(
                  child: Container(
                    color: Color(0xff905c96),
                    height: 40,
                    width: 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Stop",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              width: MediaQuery.of(context).size.width,
              color: Color(0xff905c96),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Step Count",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$_stepCountValue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        "Total Distance",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "0",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget googlemap() {
    GoogleMapController mapController;
    if (lattitude != null && langitude != null && polyLines != null) {
      return GoogleMap(
          mapType: MapType.normal,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,
          trafficEnabled: false,
          initialCameraPosition:
              CameraPosition(target: LatLng(lattitude, langitude), zoom: 20.0),
          zoomGesturesEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          polylines: polyLines,
          markers: Set<Marker>.of(<Marker>[
            Marker(
                markerId: MarkerId("112"),
                position: LatLng(destinationlattitude, destinationlongitude),
                icon: BitmapDescriptor.defaultMarker),
            Marker(
                markerId: MarkerId("abc"),
                position: LatLng(lattitude, langitude),
                icon: BitmapDescriptor.defaultMarker)
          ]));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    // TODO: impl ement dispose
    super.dispose();
    _subscription.cancel();
  }
}

class Fcm {
  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }
}
