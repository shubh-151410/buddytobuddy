import 'package:BuddyToBody/DogWalkingScheduling.dart';
import 'package:BuddyToBody/schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'TimeScheduling/BodyScheduling.dart';

class BuddyScheduling extends StatefulWidget {
  BuddyScheduling({Key key}) : super(key: key);

  _BuddySchedulingState createState() => _BuddySchedulingState();
}

class _BuddySchedulingState extends State<BuddyScheduling> {
  TimeOfDay _timeOfDay = TimeOfDay.now();

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
    if (picked != null && picked != _timeOfDay) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DogWalkingScheduling(
            time: picked.format(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
       backgroundColor: Color(0xff905c96),
        title: Text("Schedule Buddy"),
        centerTitle: true,
        leading:Text("")
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
       
       color: Color(0xff905c96),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
              Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchedulePage()
        ),
      );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                margin: EdgeInsets.all(10.0),
                child: Card(
                  borderOnForeground: true,
                  elevation: 3.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset("assets/images/dogwalking.jpg",height: 30.0,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Dog Walking",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
