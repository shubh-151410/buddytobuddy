import 'package:flutter/material.dart';

class CustomScheduling extends StatefulWidget {
  @override
  _CustomSchedulingState createState() => _CustomSchedulingState();
}

class _CustomSchedulingState extends State<CustomScheduling> {
  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {},
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
        ],
      ),
    );
  }
}
