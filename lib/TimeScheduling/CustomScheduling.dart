//import 'package:background_fetch/background_fetch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  // Future<void> initPlatformState() async {
  //   // Configure BackgroundFetch.
  //   BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //           minimumFetchInterval: 15,
  //           stopOnTerminate: false,
  //           enableHeadless: false,
  //           requiresBatteryNotLow: false,
  //           requiresCharging: false,
  //           requiresStorageNotLow: false,
  //           requiresDeviceIdle: false,
  //           requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_NONE),
  //       () async {
  //     // This is the fetch-event callback.
  //     print('[BackgroundFetch] Event received');
  //     setState(() {
  //       _events.insert(0, new DateTime.now());
  //     });
  //     // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
  //     // for taking too long in the background.
  //     BackgroundFetch.finish();
  //   }).then((int status) {
  //     print('[BackgroundFetch] configure success: $status');
  //     setState(() {
  //       _status = status;
  //     });
  //   }).catchError((e) {
  //     print('[BackgroundFetch] configure ERROR: $e');
  //     setState(() {
  //       _status = e;
  //     });
  //   });

  //   // Optionally query the current BackgroundFetch status.
  //   int status = await BackgroundFetch.status;
  //   setState(() {
  //     _status = status;
  //   });

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  // }

  // void _onClickEnable(enabled) {
  //   setState(() {
  //     _enabled = enabled;
  //   });
  //   if (enabled) {
  //     BackgroundFetch.start().then((int status) {
  //       print('[BackgroundFetch] start success: $status');
  //     }).catchError((e) {
  //       print('[BackgroundFetch] start FAILURE: $e');
  //     });
  //   } else {
  //     BackgroundFetch.stop().then((int status) {
  //       print('[BackgroundFetch] stop success: $status');
  //     });
  //   }
  // }

  // void _onClickStatus() async {
  //   int status = await BackgroundFetch.status;
  //   print('[BackgroundFetch] status: $status');
  //   setState(() {
  //     _status = status;
  //   });
  // }

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 47),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
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
        lastDate: DateTime(2101));
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
            margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Create a new schedule",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                SizedBox(
                  width: 50.0,
                ),
                FloatingActionButton(
                  backgroundColor: Color(0xff905c96).withOpacity(0.6),
                  onPressed: () => selectTime(context),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 35.0,
                  ),
                )
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
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('scheduling').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: EdgeInsets.all(10),
      height: 90,
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
                "Time: ${snapshot.data.documents.first["time"]}",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Text("Date: ${snapshot.data.documents.first["Date"]}",
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
              for (int i = 0;
                  i < snapshot.data.documents.first["Friends"].length;
                  i++)
                Text(
                  snapshot.data.documents.first["Friends"][i],
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
  List<String> friendsName = List();
  @override
  void initState() {
    friendsName.clear();
    super.initState();
  }

  Future buddyDetails() async {}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 0.0,
      backgroundColor: Color(0xffaf5dcc).withOpacity(0.8),
      child: Container(
        height: 500,
        width: 200,
        child: Stack(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return buildWidget(context, snapshot);
                } else {
                  return Container(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Positioned(
              left: 10.0,
              bottom: 10.0,
              child: FloatingActionButton(
                backgroundColor: Color(0xffaf5dcc),
                onPressed: () {
                  customScheduling();
                },
                child: Text("OK"),
              ),
            )
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
    });
    Navigator.pop(context);
  }

  Widget buildWidget(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
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
                  width: 5.0,
                ),
                Text(
                  snapshot.data.documents[count]["name"],
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(
                  width: 5.0,
                ),
                InkWell(
                  onTap: () {
                    friendsName.add(snapshot.data.documents[count]['name']);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        "Add",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
