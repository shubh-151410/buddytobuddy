import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../MainMap/StepCounting.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Buddynow extends StatefulWidget {
  @override
  _BuddynowState createState() => _BuddynowState();
}

class _BuddynowState extends State<Buddynow> {
  final Distance distance = new Distance();
  Position currentLocation;
  Geolocator geolocator = Geolocator();
  double lattitude;
  double langitude;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final String serverToken =
      'APA91bHjnkjcufsyW7X1ueiSHY68rBAd7Fg7NvCkgEvfARI0lhw3pGZ0PQZ9g_9LAd5o4yt3zQMlblMzIfdwtk0JSOTQEXUtnscfQ432qhQ_BX9DgNWgllDnsZl0pR7Nn';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0.0),
      padding: EdgeInsets.only(top: 0.0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Color(0xff905c96),
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return buildWidget(context, snapshot);
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget buildWidget(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.documents.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, position) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StepCounting(
                    lattitude: double.tryParse(
                        snapshot.data.documents[position]["lattitude"]),
                    longitude: double.tryParse(
                        snapshot.data.documents[position]["longitude"]),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Material(
                  child: snapshot.data.documents[position]['photoUrl'] != null
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                            ),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0),
                          ),
                          imageUrl: snapshot.data.documents[position]
                              ['photoUrl'],
                          width: 50.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.account_circle,
                          size: 50.0, color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  flex: 4,
                  child: Column(
                    children: <Widget>[
                      Text(
                        snapshot.data.documents[position]["name"],
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      snapshot.data.documents[position]["DogName"] != null
                          ? Text(
                              snapshot.data.documents[position]["DogName"],
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            )
                          : Text("")
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: MaterialButton(
                    onPressed: () async {
                      await sendAndRetrieveMessage(
                          snapshot.data.documents[position]["pushToken"]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StepCounting(
                            lattitude: double.tryParse(
                                snapshot.data.documents[position]["lattitude"]),
                            longitude: double.tryParse(
                                snapshot.data.documents[position]["longitude"]),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "Request",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        (langitude != null && lattitude != null)
                            ? Text(
                                distance
                                        .as(
                                          LengthUnit.Kilometer,
                                          LatLng(lattitude, langitude),
                                          LatLng(
                                              double.tryParse(snapshot
                                                      .data.documents[position]
                                                  ["lattitude"]),
                                              double.tryParse(snapshot
                                                      .data.documents[position]
                                                  ["longitude"])),
                                        )
                                        .toString() +
                                    " Km Away",
                                style: TextStyle(color: Colors.white),
                              )
                            : Text("Waiting...")
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 0.7, color: Colors.white))),
        );
      },
    );
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage(
      String userpushtoken) async {
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    var a = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAA7rAJNeA:APA91bE88G3Thx1CsYkIAA04Y6wmfuHoFkjOY2ScigP_sZEPaC6967ppdd2Hh8TsbZVrOlk4dcd8I2lD1-bTtB7yVxoETy_VNbLmtIKIdvkGSbXOa4ObqAFSaOa67BKuTBGaZ6XIehrB',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Dog walking request',
            'title': 'BuddyToBuddy'
          },
          'priority': 'high',
          "data": {"title": "new messages", "score": "5x1", "time": "15:10"},
          "to": userpushtoken
        },
      ),
    );

    print("!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(a.body);
    print(a.statusCode);
    print(a.headers);

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }
}
