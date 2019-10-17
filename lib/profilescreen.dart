import 'dart:io';

import 'package:BuddyToBody/SettingUi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController controllerNickname = TextEditingController();
  TextEditingController controllerAboutMe = TextEditingController();
  TextEditingController controllerDogName = TextEditingController();
  TextEditingController controllerZip = TextEditingController();
  SharedPreferences prefs;
  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String DogName = '';
  String Zip = '';

  bool isLoading = false;
  File avatarImageFile;
  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('name') ?? '';

    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    setState(() {
      controllerNickname = new TextEditingController(text: nickname);
      controllerAboutMe = new TextEditingController(text: aboutMe);
      controllerDogName = TextEditingController(text: DogName);
      controllerZip = TextEditingController(text: Zip);
    });
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;

          Firestore.instance.collection('users').document(id).updateData({
            'name': nickname,
            'About': aboutMe,
            'photourl': photoUrl,
          }).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((error) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: error.toString());
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This File is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    Firestore.instance.collection('users').document(id).updateData({
      'name': nickname,
      'About': aboutMe,
      'photoUrl': photoUrl,
      'DogName': DogName,
      'Zip': Zip
    }).then((data) async {
      await prefs.setString('name', nickname);
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var divheight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff334d83),
          elevation: 0.0,
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
                  child: Icon(
                    Icons.notifications_active,
                  ),
                )
              ],
            )
          ],
          leading: Icon(Icons.arrow_back_ios),
        ),
        bottomNavigationBar: Container(
            child: Container(
          height: 63.0,
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(0.0),
                  topRight: const Radius.circular(0.0))),
          child: Container(
            decoration: new BoxDecoration(
                color: Color(0xff334d83),
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(0.0),
                    topRight: const Radius.circular(0.0))),
            child: new Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // SizedBox(width: 22.0),
                Container(
                  height: 35,
                  width: 35,
                  child: Image.asset(
                    "assets/images/Home.png",
                    color: Colors.white,
                  ),
                ),
                // SizedBox(width: 40.0),
                Container(
                  height: 35,
                  width: 35,
                  child: Image.asset(
                    "assets/images/shopping-cart.png",
                    color: Colors.white,
                  ),
                ),
                //SizedBox(width: 40.0),
                Container(
                  height: 35,
                  width: 35,
                  child: Image.asset(
                    "assets/images/Chat.png",
                    color: Colors.white.withOpacity(1.0),
                  ),
                ),
                // SizedBox(
                //   width: 40,
                // ),
                Container(
                  height: 35,
                  width: 35,
                  child: Image.asset(
                    "assets/images/Schedule.png",
                    color: Colors.white,
                  ),
                ),
                //SizedBox(width: 50),
                Container(
                    height: 35,
                    width: 35,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingScreen()),
                        );
                      },
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ))
              ],
            )),
          ),
        )),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          (avatarImageFile == null)
                              ? (photoUrl != ''
                                  ? Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    themeColor),
                                          ),
                                          width: 90.0,
                                          height: 90.0,
                                          padding: EdgeInsets.all(20.0),
                                        ),
                                        imageUrl: photoUrl,
                                        width: 90.0,
                                        height: 90.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(45.0)),
                                      clipBehavior: Clip.hardEdge,
                                    )
                                  : Icon(
                                      Icons.account_circle,
                                      size: 90.0,
                                      color: greyColor,
                                    ))
                              : Material(
                                  child: Image.file(
                                    avatarImageFile,
                                    width: 90.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: primaryColor.withOpacity(0.5),
                            ),
                            onPressed: getImage,
                            padding: EdgeInsets.all(30.0),
                            splashColor: Colors.transparent,
                            highlightColor: greyColor,
                            iconSize: 30.0,
                          ),
                        ],
                      ),
                    ),
                    width: double.infinity,
                    margin: EdgeInsets.all(20.0),
                  ),
                  Center(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.perm_identity,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 6.0,
                      ),
                      Text(
                        "Shubhanshu",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      SizedBox(
                        width: 6.0,
                      ),
                      Text(
                        "23",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      )
                    ],
                  )),
                  Column(
                    children: <Widget>[
                      // Username
                      Container(
                        child: Text(
                          'Nickname',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        margin:
                            EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                      ),
                      Container(
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Sweetie',
                              contentPadding: new EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: greyColor),
                            ),
                            controller: controllerNickname,
                            onChanged: (value) {
                              nickname = value;
                            },
                            focusNode: focusNodeNickname,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),

                      //Email

                      // About me
                      Container(
                        child: Text(
                          'About me',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        margin:
                            EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                      ),
                      Container(
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Fun, like travel and play PES...',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: greyColor),
                            ),
                            controller: controllerAboutMe,
                            onChanged: (value) {
                              aboutMe = value;
                            },
                            focusNode: focusNodeAboutMe,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),
                      Container(
                        child: Text(
                          'Dog Name',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        margin:
                            EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                      ),
                      Container(
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Dog Name',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: greyColor),
                            ),
                            controller: controllerDogName,
                            onChanged: (value) {
                              aboutMe = value;
                            },
                            focusNode: focusNodeAboutMe,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),
                      Container(
                        child: Text(
                          'Zip',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        margin:
                            EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                      ),
                      Container(
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Zip',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: greyColor),
                            ),
                            controller: controllerZip,
                            onChanged: (value) {
                              aboutMe = value;
                            },
                            focusNode: focusNodeAboutMe,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color(0xff274986),
                      child: Container(
                        width: 120.0,
                        height: 50.0,
                        child: MaterialButton(
                          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          onPressed: handleUpdateData,
                          child: Text("SAVE",
                              style: TextStyle(color: Colors.white)),
                        ),
                      )),
                ],
              ),
            )
          ],
        ));
  }
}
