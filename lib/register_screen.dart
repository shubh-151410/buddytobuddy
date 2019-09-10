import 'dart:async';
import 'dart:io';

import 'package:BuddyToBody/SettingUi.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import './image_picker_handler.dart';
import 'mapScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, ImagePickerListener {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
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

  String name, email, password, confirmpassword, dogname, about, photourl;
  int Zip;

  StreamSubscription<DocumentSnapshot> subscription;

  final usernamecontroller = TextEditingController();
  final useremailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmpasswordcontroller = TextEditingController();
  final dog_namecontroller = TextEditingController();
  final aboutcontroller = TextEditingController();
  final zipcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    getUserLocation();
    getFileFromAsset("assets/policy.pdf").then((f) {
      setState(() {
        assetPDFPath = f.path;
        print(assetPDFPath);
      });
    });
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this, _controller);
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
      FirebaseAuth mAuth = FirebaseAuth.instance;

      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("UserPhoto");
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      final String Url = await taskSnapshot.ref.getDownloadURL();
      print(Url);
      Map<String, String> data = <String, String>{
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
        'chattingWith': null
      };

      await Firestore.instance.collection('userdetails').add(data);

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
          backgroundColor: Color(0xff182C61),
          elevation: 0.0,
        ),
        body: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Container(
              height: divheight,
              width: MediaQuery.of(context).size.width,
              color: Color(0xff182C61),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => imagePicker.showDialog(context),
                        child: new Container(
                          child: _image == null
                              ? new Stack(
                                  children: <Widget>[
                                    new Center(
                                      child: new CircleAvatar(
                                        radius: 50.0,
                                        backgroundColor:
                                            const Color(0xFF778899),
                                      ),
                                    ),
                                    new Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 25.0),
                                        child: new Image.asset(
                                          "assets/images/photo_camera.png",
                                          height: 50.0,
                                        ),
                                      ),
                                    )
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
                                    border: Border.all(
                                        color: Colors.white, width: 2.0),
                                    borderRadius: new BorderRadius.all(
                                        const Radius.circular(80.0)),
                                  ),
                                ),
                        ),
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
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            contentPadding: EdgeInsets.all(3.0),
            labelText: "Name",
            labelStyle: TextStyle(color: Colors.white),
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
            contentPadding: EdgeInsets.all(3.0),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            labelText: "E-mail",
            labelStyle: TextStyle(color: Colors.white),
            //errorText: useremailvalidate ? 'Email Can\'t Be Empty' : null,
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
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            contentPadding: EdgeInsets.all(3.0),
            labelText: "Password",
            labelStyle: TextStyle(color: Colors.white),
            //errorText: passwordvallidate ? 'Password Can\'t Be Empty' : null,
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
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            contentPadding: EdgeInsets.all(3.0),
            labelText: "ConfirmPassword",
            labelStyle: TextStyle(color: Colors.white),
            //errorText: confirmpasswordvalidate ? 'Password Can\'t Be Empty' : null,
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
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            contentPadding: EdgeInsets.all(3.0),
            labelText: "Dog Name",
            labelStyle: TextStyle(color: Colors.white),
            //errorText: dog_namevalidate ? 'Dog name Can\'t Be Empty' : null,
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
            contentPadding: EdgeInsets.all(3.0),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            labelText: "About",
            labelStyle: TextStyle(color: Colors.white),
            //errorText: aboutcontrollervalidate ? 'About Can\'t Be Empty' : null,
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
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            contentPadding: EdgeInsets.all(3.0),
            labelText: "Zip",
            labelStyle: TextStyle(color: Colors.white),
            //errorText: zipcontrollervalidate ? 'Zip Can\'t Be Empty' : null,
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
            color: Color(0xff274986),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                onPressed: _add,
                child: Text("SIGN UP", style: TextStyle(color: Colors.white)),
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Checkbox(
              onChanged: (bool abcd) {
                setState(() {
                  abcd = true;
                });
              },
              value: false,
            ),
            GestureDetector(
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
