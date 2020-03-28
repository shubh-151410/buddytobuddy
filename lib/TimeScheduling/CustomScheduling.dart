//import 'package:background_fetch/background_fetch.dart';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';

DateTime selectedDate = DateTime.now();
String time, date;

class CustomScheduling extends StatefulWidget {
  @override
  _CustomSchedulingState createState() => _CustomSchedulingState();
}

class _CustomSchedulingState extends State<CustomScheduling> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];
  String _id = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
    getUserId();
  }

  Future getUserId() async {
    var prefs = await SharedPreferences.getInstance();
    _id = prefs.getString('id');
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, new DateTime.now());
      });
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 47),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
              primaryColor: Color(0xff905c96), accentColor: Color(0xff905c96)),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          ),
        );
      },
    );
    if (picked != null) {
      print(picked.format(context));
      time = picked.format(context);
      _selectDate(context);
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget child) {
          return Theme(
              data: ThemeData.light().copyWith(
                  primaryColor: Color(0xff905c96),
                  accentColor: Color(0xff905c96)),
              child: child);
        });

    if (picked != null && picked != selectedDate) {
      addFriendDialog();
      setState(() {
        date = DateFormat('dd-MM-yyyy').format(picked);
        selectedDate = picked;
      });
    }
  }

  Future<void> addFriendDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SelectBuddy());
  }

  @override
  Widget build(BuildContext context) {
    //_onClickEnable(_enabled);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 5.0),
            margin: EdgeInsets.fromLTRB(5, 20, 5, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Create a new schedule",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                Row(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: Color(0xff905c96),
                        ),
                        child: Builder(
                          builder: (context) {
                            return FloatingActionButton(
                              mini: true,
                              backgroundColor:
                                  Color(0xff905c96).withOpacity(0.6),
                              onPressed: () => selectTime(context),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: Color(0xff905c96),
                          ),
                          child: Builder(
                            builder: (context) {
                              return FloatingActionButton(
                                mini: true,
                                backgroundColor:
                                    Color(0xff905c96).withOpacity(0.6),
                                onPressed: () async {
                                  var prefs =
                                      await SharedPreferences.getInstance();
                                  String id = prefs.getString('id');
                                  print(id);
                                  Firestore.instance
                                      .collection("scheduling")
                                      .document(id)
                                      .delete();

                                  //  print(a.snapshots().first);
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            height: 70.0,
            decoration: BoxDecoration(
              color: Color(0xff905c96).withOpacity(0.5),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, top: 3.0, right: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.7, color: Color(0xff905c96)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('scheduling')
                .document(_id)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                return scheduleWidget(context, snapshot);
              } else {
                return Container(
                  child: Text(""),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget scheduleWidget(
      BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.data.data == null) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.13,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Color(0xff905c96).withOpacity(0.5),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Time: ${snapshot.data.data["time"]}",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Text("Date: ${snapshot.data.data["Date"]}",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
          Wrap(
            spacing: 10,
            direction: Axis.horizontal,
            children: <Widget>[
              Text(
                "Friends: ",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              for (int i = 0; i < snapshot.data.data["Friends"].length; i++)
                Text(
                  snapshot.data.data["Friends"][i],
                  style: TextStyle(fontSize: 18, color: Colors.white),
                )
            ],
          )
        ],
      ),
    );
  }
}

class SelectBuddy extends StatefulWidget {
  @override
  _SelectBuddyState createState() => _SelectBuddyState();
}

class _SelectBuddyState extends State<SelectBuddy> {
  SharedPreferences prefs;
  bool isSelected = false;
  double height = 0;
  double width = 0;
  List<String> friendsName = List();
  @override
  void initState() {
    friendsName.clear();
    super.initState();
  }

  Future buddyDetails() async {}

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 0.0,
      backgroundColor: Color(0xffaf5dcc).withOpacity(0.8),
      child: Container(
        height: height * 0.8,
        width: width * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                      height: height * 0.7,
                      child: buildWidget(context, snapshot));
                } else {
                  return Container(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Container(
              margin: EdgeInsets.only(left: width * 0.02),
              child: FloatingActionButton(
                backgroundColor: Color(0xffaf5dcc),
                onPressed: () {
                  customScheduling();
                },
                child: Text("OK"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void customScheduling() async {
    prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id');

    await Firestore.instance.collection('scheduling').document(id).setData({
      'time': time,
      'Date': date,
      'Friends': friendsName,
    }).then((value) {
      Navigator.pop(context);
    });
    //Navigator.pop(context);
  }

  Widget buildWidget(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, count) {
        return Container(
          margin: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
          padding: EdgeInsets.only(bottom: 3.0),
          child: Padding(
            padding: EdgeInsets.only(bottom: 2.0),
            child: Row(
              children: <Widget>[
                Material(
                  child: snapshot.data.documents[count]['photoUrl'] != null
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                            ),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0),
                          ),
                          imageUrl: snapshot.data.documents[count]['photoUrl'],
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
                  width: width * 0.06,
                ),
                Container(
                  width: width * 0.3,
                  child: Text(
                    snapshot.data.documents[count]["name"],
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        friendsName.add(snapshot.data.documents[count]['name']);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: Center(
                          child: Text(
                            "Add",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Color(0xffaf5dcc),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 0.9),
            ),
          ),
        );
      },
    );
  }
}
