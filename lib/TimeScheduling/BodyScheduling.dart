import 'package:flutter/material.dart';
import './BuddyNowScheduling.dart';
import './CustomScheduling.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff905c96),
          bottom: TabBar(
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.grey.withOpacity(0.5),
              tabs: [
                Container(
                  child: Tab(
                    text: "BuddyNow",
                  ),
                ),
                Container(
                  child: Tab(
                    text: "ScheduleBuddy",
                  ),
                )
              ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Buddynow(),
            CustomScheduling(),
          ],
        ),
      ),
    );
  }
}
