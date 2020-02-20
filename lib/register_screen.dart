import 'dart:async';
import 'dart:io';

import 'package:BuddyToBody/SettingUi.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './image_picker_handler.dart';
import 'mapScreen.dart';

String twitterUserName;

class HomeScreen extends StatefulWidget {
  HomeScreen([String name]) {
    twitterUserName = name;
  }
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, ImagePickerListener {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseMessaging _fcm = FirebaseMessaging();


  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  double lattitude;
  double langitude;
  LatLng _center;
  Position currentLocation;
  Geolocator geolocator = Geolocator();
  String urlPDFPath = "";
  String assetPDFPath = "";
  bool isLoading = false;
  bool isCheck = false;
  String name, email, password, confirmpassword, dogname, about, photourl;
  int Zip;

  StreamSubscription<DocumentSnapshot> subscription;

  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  TextEditingController dog_namecontroller = TextEditingController();
  TextEditingController aboutcontroller = TextEditingController();
  TextEditingController zipcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (twitterUserName != null) {
      setState(() {
        usernamecontroller = TextEditingController(text: twitterUserName);
      });
    }
    getUserLocation();
    getFileFromAsset("assets/policy.pdf").then((f) {
      setState(() {
        assetPDFPath = f.path;
        print(assetPDFPath);
      });
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  Future<File> getFileFromAsset(String asset) async {
    try {
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/policy.pdf");

      File assetFile = await file.writeAsBytes(bytes);
      return assetFile;
    } catch (e) {
      throw Exception("Error opening asset file");
    }
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _add() async {
    this.setState(() {
      isLoading = true;
    });
    if (_key.currentState.validate()) {
      _key.currentState.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final Firestore _firestore = Firestore.instance;
       String fcmToken = await _fcm.getToken();
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("UserPhoto");
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      final String Url = await taskSnapshot.ref.getDownloadURL();
      FirebaseUser user = await _auth.currentUser();
      Map<String, dynamic> data = <String, dynamic>{
        "name": name,
        "email": email,
        "password": password,
        "confirmPassword": confirmpassword,
        "About": about,
        "Zip": Zip.toString(),
        "DogName": dogname,
        "lattitude": lattitude.toString(),
        "longitude": langitude.toString(),
        "photoUrl": Url,
        'chattingWith': null,
        'id': null,
        'isActive':false,
        'pushToken':fcmToken,
        
      };

      var userId = await Firestore.instance.collection('users').add(data);
      await prefs.setString('id', userId.documentID);
      await Firestore.instance
          .collection('users')
          .document(userId.documentID)
          .updateData({'id': '${userId.documentID}'});

           if (fcmToken != null) {
          var tokens = Firestore.instance
              .collection('users')
              .document(userId.documentID)
              .collection('tokens')
              .document(fcmToken);

          await tokens.setData({
            'token': fcmToken,
            'createdAt': FieldValue.serverTimestamp(), // optional
            // optional
          });
        }

      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new Information(),
        ),
      );
      this.setState(() {
        isLoading = false;
      });
    } else {
      this.setState(() {
        _validate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var divheight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
          centerTitle: true,
          backgroundColor: Color(0xff905c96),
          elevation: 0.0,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: divheight,
              width: MediaQuery.of(context).size.width,
              color: Color(0xff905c96),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      InkWell(
                        onTap: () => imagePicker.showDialog(context),
                        child: new Center(
                          child: _image == null
                              ? new Stack(
                                  children: <Widget>[
                                    new Center(
                                      child: new CircleAvatar(
                                        radius: 60.0,
                                        backgroundColor:
                                            const Color(0xFF778899),
                                      ),
                                    ),
                                    new Center(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: new Image.asset(
                                          "assets/images/photo_camera.png",
                                          height: 60,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : new Container(
                                  height: 160.0,
                                  width: 160.0,
                                  decoration: new BoxDecoration(
                                    color: const Color(0xff7c94b6),
                                    image: new DecorationImage(
                                      image: new ExactAssetImage(_image.path),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(width: 5.0),
                                    borderRadius: new BorderRadius.all(
                                        const Radius.circular(100.0)),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Form(
                        key: _key,
                        autovalidate: _validate,
                        child: FormUI(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xfff5a623)),
                        ),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        ));
  }

  Widget FormUI(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          //controller: useremailcontroller,
          controller: usernamecontroller,
          keyboardType: TextInputType.text,
          minLines: 1,
          maxLines: 1,
          style: TextStyle(color: Colors.white),
          obscureText: false,
          autofocus: false,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Color(0xffaf5dcc),
            filled: true,
            prefixIcon: Icon(Icons.person,color: Colors.white,),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            hintText: 'User Name',
            contentPadding: new EdgeInsets.all(5.0),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: validateName,
          onSaved: (String val) {
            name = val;
          },
        ),
        SizedBox(
          height: 10,
        ),
        //
        TextFormField(
          //controller: useremailcontroller,
          controller: useremailcontroller,
          keyboardType: TextInputType.emailAddress,
          minLines: 1,
          maxLines: 1,
          obscureText: false,
          autofocus: false,
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            fillColor: Color(0xffaf5dcc),
            filled: true,
            prefixIcon: Icon(Icons.email,color: Colors.white,),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            hintText: 'Email',
            contentPadding: new EdgeInsets.all(5.0),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: validateEmail,
          onSaved: (String val) {
            email = val;
          },
        ),
        SizedBox(
          height: 10,
        ),

        TextFormField(
          //controller: useremailcontroller,
          controller: passwordcontroller,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          minLines: 1,
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Color(0xffaf5dcc),
            filled: true,
            prefixIcon: Icon(Icons.vpn_key,color: Colors.white,),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            hintText: 'Password',
            contentPadding: new EdgeInsets.all(5.0),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: validatePassword,
          onSaved: (String value) {
            password = value;
          },
        ),
        SizedBox(
          height: 10,
        ),

        TextFormField(
          //controller: useremailcontroller,
          controller: confirmpasswordcontroller,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white),
          minLines: 1,
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Color(0xffaf5dcc),
            filled: true,
            prefixIcon: Icon(Icons.vpn_key,color: Colors.white,),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            hintText: 'Confirm Password',
            contentPadding: new EdgeInsets.all(5.0),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: validateConfirmPassword,
          onSaved: (String val) {
            confirmpassword = val;
          },
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          //controller: useremailcontroller,
          controller: dog_namecontroller,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white),
          minLines: 1,
          maxLines: 1,
          obscureText: false,
          autofocus: false,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Color(0xffaf5dcc),
            filled: true,
            prefixIcon: Icon(Icons.pets,color: Colors.white,),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            hintText: 'Dog Name',
            contentPadding: new EdgeInsets.all(5.0),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: validateDogName,
          onSaved: (String val) {
            dogname = val;
          },
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          //controller: useremailcontroller,
          controller: aboutcontroller,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          minLines: 1,
          maxLines: 2,
          obscureText: false,
          autofocus: false,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Color(0xffaf5dcc),
            filled: true,
            prefixIcon: Icon(Icons.assignment_ind,color: Colors.white,),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            hintText: 'About',
            contentPadding: new EdgeInsets.all(5.0),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: validateAbout,
          onSaved: (String value) {
            about = value;
          },
        ),
        SizedBox(
          height: 10,
        ),

        TextFormField(
          //controller: useremailcontroller,
          controller: zipcontroller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Colors.white,
          ),
          minLines: 1,

          maxLines: 1,
          obscureText: false,
          autofocus: false,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            fillColor: Color(0xffaf5dcc),
            filled: true,
            prefixIcon: Icon(Icons.fiber_pin,color: Colors.white,),
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffaf5dcc), width: 1.5),
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            hintText: 'Pin',
            contentPadding: new EdgeInsets.all(5.0),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: validateZip,
          onSaved: (String value) {
            Zip = int.parse(value);
          },
        ),
        SizedBox(
          height: 10,
        ),
        Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(30.0),
            color: Color(0xffaf5dcc),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: MaterialButton(
                //disabledColor:(isCheck)?Colors.white: Color(0xffaf5dcc),

                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                onPressed: _add,
                child: Text("SIGN UP",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Checkbox(
              checkColor: Colors.black,
              onChanged: (bool abcd) {
                this.setState(() {
                  this.isCheck = abcd;
                });
              },
              value: isCheck,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PdfViewPage(path: assetPDFPath)));
              },
              child: Text(
                "By Signing in,you are agreeing to our Terms of services",
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            )
          ],
        ),
      ],
    );
  }

  String validateName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return null;
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  String validatePassword(String value) {
    //String pattern = r'^((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%]).{6,20})$';
    //RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      return "Password is Required";
    } else if (value.length < 6) {
      return "Password Contain Atleast 6 Length ";
    } else {
      return null;
    }
  }

  String validateConfirmPassword(String value) {
    if (value.length == 0) {
      return "Confirm Password Is Required";
    } else {
      return null;
    }
  }

  String validateDogName(String value) {
    if (value.length == 0) {
      return "Dog Name Is Rewuired";
    } else {
      return null;
    }
  }

  String validateAbout(String value) {
    if (value.length == 0) {
      return "About Field Is Required";
    } else {
      return null;
    }
  }

  String validateZip(String value) {
    if (value.length == 0) {
      return "Zip Field Is Required";
    } else {
      return null;
    }
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }
}
