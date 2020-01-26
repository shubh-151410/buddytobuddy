import 'package:BuddyToBody/chat.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




import 'SettingUi.dart';

class ScheduleBuddy extends StatefulWidget {
  ScheduleBuddy({Key key}) : super(key: key);

  _ScheduleBuddyState createState() => _ScheduleBuddyState();
}

class _ScheduleBuddyState extends State<ScheduleBuddy> {
   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    final FirebaseMessaging _fcm = FirebaseMessaging();
    
    

   @override
   void initState() { 
     super.initState();
     
     
   }

    _saveDeviceToken() async {
       String fcmToken = await _fcm.getToken();

    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff905c96),
        title: Text("People Around You"),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              color: Color(0xff905c96),
              child: Center(
                child: StreamBuilder<QuerySnapshot>(
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
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildWidget(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, position) => Container(
        margin: EdgeInsets.only(
          top: 10.0,
          left: 20.0,
          right: 20.0,
        ),
       
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Color(0xfff2e3ea),
            borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          margin: EdgeInsets.only(
            top: 10.0,
            left: 10.0,
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  peerId: snapshot.data.documents[position]["id"],
                  peerAvatar: snapshot.data.documents[position]['photoUrl'],
                  name: snapshot.data.documents[position]['name'],
                ),
              ),
            ),
            child: Row(
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
                  borderRadius: BorderRadius.all(Radius.circular(25.0),),
                  clipBehavior: Clip.hardEdge,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: Text(
                    snapshot.data.documents[position]["name"],
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class Message {
  final String title;
  final String body;

  const Message({
    @required this.title,
    @required this.body,
  });
}
