import 'dart:convert';

import 'package:BuddyToBody/mapScreen.dart';
import 'package:BuddyToBody/password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

import './register_screen.dart';

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NewLogIn(),
    );
  }
}

class NewLogIn extends StatefulWidget {
  NewLogIn({Key key}) : super(key: key);

  _NewLogInState createState() => _NewLogInState();
}

class _NewLogInState extends State<NewLogIn> {
  bool _success;
  String _userID;
  bool isLoading = false;
  bool isLoggedIn = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = GoogleSignIn();
  FirebaseUser currentUser;
  bool isLogged = false;
  FirebaseUser myUser;
  var facebookLogin = FacebookLogin();
  var profileData;
  String email, password;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  SharedPreferences prefs;
  Position currentLocation;
  double lattitude;
  double langitude;
  LatLng _center;
  bool isPasswordRight = false;

  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: 'n4V8JJp393HIyjYgq8gddXHEZ',
    consumerSecret: 'abSPqsiKDMR9A3ZUJdkqJ1oWVlTwvvuniTDsrEnIDkMaA2HgJL',
  );
  String _message = 'Logged out.';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
    isSignedIn();
    //isFirebaseSignedIn();
  }

  @override
  // ignore: must_call_super
  void dispose() {
    useremailcontroller.clear();
    passwordcontroller.clear();
    this.setState(() {
      isLoading = false;
    });
  }

  Future<Position> locateUser() {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // void isFirebaseSignedIn() async{
  //   this.setState(() {
  //     isLoading = true;
  //   });
  //   prefs = await SharedPreferences.getInstance();

  // }

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
    //print('center $_center');
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = await _googlSignIn.isSignedIn();

    if (isLoggedIn) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Information()));
    }
    this.setState(() {
      isLoading = false;
    });
  }

  //
  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      print("Status Error");
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  void _login() async {
    final TwitterLoginResult result = await twitterLogin.authorize();
    String newMessage;

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        newMessage = 'Logged in! username: ${result.session.username}';

        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new Information(),
          ),
        );

        break;
      case TwitterLoginStatus.cancelledByUser:
        newMessage = 'Login cancelled by user.';

        break;
      case TwitterLoginStatus.error:
        newMessage = 'Login error: ${result.errorMessage}';

        break;
    }

    setState(() {
      _message = newMessage;
      print(_message);
    });
  }

  //

  //bool isLoggedIn = false;

  Future<FirebaseUser> _signIn(BuildContext context) async {
    try {
      prefs = await SharedPreferences.getInstance();
      this.setState(() {
        isLoading = true;
      });
      final GoogleSignInAccount googleUser = await _googlSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(googleUser);
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseUser userDetails =
          await _firebaseAuth.signInWithCredential(credential);
      ProviderDetails providerInfo =
          new ProviderDetails(userDetails.providerId);
      print(userDetails.displayName);
      if (userDetails != null) {
        final QuerySnapshot result = await Firestore.instance
            .collection('userdetails')
            .where('id', isEqualTo: userDetails.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        Firestore.instance
            .collection('userdetails')
            .document(userDetails.uid)
            .setData({
          'name': userDetails.displayName,
          'email': userDetails.email,
          'id': userDetails.uid,
          'photoUrl': userDetails.photoUrl,
          'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
          "lattitude": lattitude.toString(),
          "longitude": langitude.toString(),
          'chattingWith': null,
          'About': null,
          'DogName': null,
          'Zip': null
        });
        currentUser = userDetails;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('name', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Fluttertoast.showToast(msg: "Sign in fail");
        this.setState(() => {isLoading = false});
      }
      List<ProviderDetails> providerData = new List<ProviderDetails>();
      providerData.add(providerInfo);

      UserDetails details = new UserDetails(
        userDetails.providerId,
        userDetails.displayName,
        userDetails.photoUrl,
        userDetails.email,
        providerData,
      );
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new Information(),
        ),
      );
      return userDetails;
    } catch (e) {
      print(e);
      setState(() {
        this.isLoading = false;
      });
    }
  }

  final useremailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

//google sign in
  GoogleSignIn googleAuth = GoogleSignIn();

  Future _authenticationFireBase() async {
    this.setState(() {
      isLoading = true;
      isPasswordRight = false;
    });
    if (_key.currentState.validate()) {
      _key.currentState.save();
      QuerySnapshot querySnapshot = await Firestore.instance
          .collection("userdetails")
          .where("name")
          .getDocuments();
      var list = querySnapshot.documents;
      for (int i = 0; i < querySnapshot.documents.length; i++) {
        if (email == list[i]["email"] && password == list[i]["password"]) {
          await prefs.setString(
              "loginId", querySnapshot.documents[i].documentID);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Information()),
          );
        } else {
          this.setState(() {
            isLoading = false;
            isPasswordRight = true;
          });
        }
      }
    } else {
      setState(() {
        _validate = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Edit Text For Email Id
    final username_email = TextFormField(
      controller: useremailcontroller,
      keyboardType: TextInputType.emailAddress,
      minLines: 1,
      maxLines: 1,
      obscureText: false,
      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      autofocus: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        focusColor: Colors.blueAccent,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        contentPadding: EdgeInsets.all(3.0),
        hintText: "EMAIL ID",
        hintStyle: TextStyle(color: Colors.blueAccent),
      ),
      validator: validateEmail,
      onSaved: (String value) {
        email = value;
      },
    );

    // Password
    final PasswordField = TextFormField(
      controller: passwordcontroller,
      minLines: 1,
      maxLines: 1,
      obscureText: true,
      autofocus: true,
      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        contentPadding: EdgeInsets.all(3.0),
        hintText: "PASSWORD",
        hintStyle: TextStyle(color: Colors.blueAccent),
      ),
      validator: validatePassword,
      onSaved: (String value) {
        password = value;
      },
    );
    final signup_button = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff274986),
        child: Container(
          width: 120.0,
          height: 50.0,
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("SIGN UP", style: TextStyle(color: Colors.white)),
          ),
        ));
    final signin_button = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff274986),
        child: Container(
          width: 120.0,
          height: 50.0,
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: _authenticationFireBase,
            //TODO: calling  Authentication

            child: Text("SIGN IN", style: TextStyle(color: Colors.white)),
          ),
        ));
    final txtview_or = Text("OR", style: TextStyle(color: Colors.blueAccent));

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Center(
                child: SingleChildScrollView(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(36.0, 93.0, 36.0, 30),
                    child: Center(
                        child: Form(
                      key: _key,
                      autovalidate: _validate,
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                              child: Image.asset(
                                "assets/images/ColorLogoMedium.png",
                                height: 150,
                                width: 150,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: username_email,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: PasswordField,
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PasswordUi()));
                                  },
                                  child: Text(
                                    "Forgot Password ?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Visibility(
                                  visible: isPasswordRight,
                                  child: Text("Wrong Password Please Try Again!",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 12.0),),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              signup_button,
                              SizedBox(
                                width: 20.0,
                              ),
                              signin_button
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          txtview_or,
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                // child: Image.asset("assets/images/Twitter.png"),
                                child: GestureDetector(
                                  child:
                                      Image.asset("assets/images/Twitter.png"),
                                  onTap: _login,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                // child: Image.asset("assets/images/Googleplus.png"),
                                child: GestureDetector(
                                  child: Image.asset(
                                      "assets/images/Googleplus.png"),
                                  onTap: () => _signIn(context)
                                      .then((FirebaseUser user) => print(user))
                                      .catchError((e) => print(e)),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                  height: 50,
                                  width: 50,
                                  // child: Image.asset("assets/images/Facebook.png"),
                                  child: GestureDetector(
                                      child: Image.asset(
                                          "assets/images/Facebook.png"),
                                      onTap: () => initiateFacebookLogin())),
                            ],
                          )
                        ],
                      ),
                    )),
                  )),
            )),
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

  String validateEmail(String value) {
    if (value.length == 0) {
      return "EmailId Is Required";
    } else {
      return null;
    }
  }

  String validatePassword(String value) {
    if (value.length == 0) {
      return "Password Is Required";
    } else {
      return null;
    }
  }

  Future<FirebaseUser> initiateFacebookLogin() async {
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new Information(),
          ),
        );

        //onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }

  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);
    print("Logged out");
  }
}

class UserDetails {
  final String providerDetails;
  final String userName;
  final String photoUrl;
  final String userEmail;
  final List<ProviderDetails> providerData;

  UserDetails(this.providerDetails, this.userName, this.photoUrl,
      this.userEmail, this.providerData);
}

class ProviderDetails {
  ProviderDetails(this.providerDetails);

  final String providerDetails;
}
