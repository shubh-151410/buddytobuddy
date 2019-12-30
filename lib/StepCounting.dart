import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:toast/toast.dart';

class StepCounting extends StatefulWidget {
  @override
  _StepCountingState createState() => _StepCountingState();
}

class _StepCountingState extends State<StepCounting> {
  Pedometer _pedometer;
  StreamSubscription<int> _subscription;
  String _stepCountValue = '0';

  Completer<GoogleMapController> _controller = Completer();
  double lattitude;
  double langitude;
  LatLng _center;
  Position currentLocation;
  Geolocator geolocator = Geolocator();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
    _stepCountValue = '0';

    initPlatformState();
  }

  Future<void> initPlatformState() async {
    startListening();
  }

  void startListening() {
    _pedometer = new Pedometer();
    _subscription = _pedometer.pedometerStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void stopListening() {
    _subscription.cancel();
  }

  void _onData(int stepCountValue) async {
    setState(() => _stepCountValue = "$stepCountValue");
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
      body: Stack(
        children: <Widget>[
          googlemap(),
          Positioned(
            right: 20.0,
            top: 30.0,
            child: Opacity(
              opacity: 0.8,
              child: InkWell(
                onTap: (){
                  stopListening();
                  Toast.show("Buddy Stop", context,duration: Toast.LENGTH_SHORT,gravity:Toast.BOTTOM );
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
    if (lattitude != null && langitude != null) {
      return GoogleMap(
        mapType: MapType.normal,
        trafficEnabled: true,
      
        initialCameraPosition:
            CameraPosition(target: LatLng(lattitude, langitude), zoom: 20.0),
        zoomGesturesEnabled: true,
        compassEnabled: true,
        
        mapToolbarEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(<Marker>[
          Marker(
              visible: true,
              draggable: true,
              position: LatLng(lattitude, langitude),
              markerId: MarkerId("1"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),)
        ]),
      );
    } else {
      return CircularProgressIndicator(
        strokeWidth: 1.0,
      );
    }
  }

  @override
  void dispose() {
    // TODO: impl ement dispose
    super.dispose();
    _subscription.cancel();
  }
}
