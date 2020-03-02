import './MainMap/StepCounting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class DogWalkingScheduling extends StatefulWidget {
  final String time;
  DogWalkingScheduling({@required this.time});
  @override
  _DogWalkingSchedulingState createState() =>
      _DogWalkingSchedulingState(time: time);
}

class _DogWalkingSchedulingState extends State<DogWalkingScheduling> {
  final String time;
  _DogWalkingSchedulingState({@required this.time});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule For $time"),
        centerTitle: true,
        backgroundColor: Color(0xff905c96),
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 0.0),
        padding: EdgeInsets.only(top: 0.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Color(0xff905c96),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('users').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return buildWidget(context, snapshot);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
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
                MaterialPageRoute(builder: (context) => StepCounting()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  width: 100,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StepCounting()),
                      );
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: Center(
                          child: Text(
                            "Dog Walk",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        width: 90.0,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
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
}
