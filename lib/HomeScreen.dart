import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   double lattitude;
  double langitude;
  LatLng _center;
  double zoomvalue = 12;
  Position currentLocation;
  Geolocator geolocator = Geolocator();
  Completer<GoogleMapController> _controller = Completer();
   CollectionReference collectionReference =
      Firestore.instance.collection('users');

      @override
  void initState() {
    // TODO: implement initState
    super.initState();
     getUserLocation();
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

  void zoomin(){
    print("CallingZoom");
    double a = zoomvalue*1.5;
      
    this.setState(() {
      this.zoomvalue = a;
    });
  


  }

  void zoomout(){

  }

  @override
  Widget build(BuildContext context) {
   return Container(
     width: MediaQuery.of(context).size.width,
     height: MediaQuery.of(context).size.height,
     child: Stack(
       children: <Widget>[
       StreamBuilder<QuerySnapshot>(
         stream: Firestore.instance.collection('users').snapshots(),
         
         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
           if(snapshot.hasData)
           {
             return googlemap(context,snapshot);
           }else{
             return Center(
               child: CircularProgressIndicator(),
             );
           }
         },
       ),
        // Positioned(
        //     right: 20.0,
        //     top: 30.0,
        //     child: Opacity(
        //         opacity: 0.8,
        //         child:InkWell(
        //           onTap: (){
        //             zoomin();
        //           },
        //           child: ClipOval(
        //             child: Container(
        //               color: Color(0xff905c96),
        //               height: 40,
        //               width: 40,
        //               child: Icon(
        //                 Icons.zoom_in,
        //                 color: Colors.white,
        //               ),
        //             ),
        //           ),
        //         )),
        //   ),
       ],
     ),
   );
  }

   Widget googlemap(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    GoogleMapController mapController;
    if (lattitude != null && langitude != null) {
      return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition:
              CameraPosition(target: LatLng(lattitude, langitude), zoom: zoomvalue),
          zoomGesturesEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(<Marker>[
            Marker(
                visible: true,
                draggable: true,
                markerId: MarkerId("1"),
                position: LatLng(lattitude, langitude),
                icon: BitmapDescriptor.defaultMarker),
            for (int i = 0; i < snapshot.data.documents.length; i++)
              if (snapshot.data.documents[i]["lattitude"] != null &&
                  snapshot.data.documents[i]["longitude"] != null)
                Marker(
                  visible: true,
                  draggable: true,
                  markerId: MarkerId("$i"),
                  position: LatLng(
                      double.parse(snapshot.data.documents[i]["lattitude"]),
                      double.parse(snapshot.data.documents[i]["longitude"])),
                  icon: BitmapDescriptor.fromAsset(
                      "assets/images/index_Recovered.png"),
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
      return Center(
        child: CircularProgressIndicator(

        ),
      );
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 0.0,
      backgroundColor: Colors.white,
      child: dialog(context),
    );
  }

  Widget dialog(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Container(
        height: 400,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(color: Color(0xff905c96)),
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
            (customDialog.userName != null)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        customDialog.userName,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ))
                : Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        "EmptyName",
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
                                        color: Colors.black, fontSize: 18),
                                  ),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            (customDialog.About != null)
                                ? Text(
                                    customDialog.About,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                                : Text(
                                    "Please Enter About",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff2e3ea),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}