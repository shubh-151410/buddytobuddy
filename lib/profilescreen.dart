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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    print(id);
    DocumentSnapshot result =
        await Firestore.instance.collection('users').document(id).get();
    print(result.data["name"]);
    nickname = result.data["name"];
    photoUrl = result.data["photoUrl"];
    aboutMe = result.data["About"];
    DogName = result.data["DogName"];
    Zip = result.data["Zip"];
    // nickname = prefs.getString('name') ?? '';

    // aboutMe = prefs.getString('aboutMe') ?? '';
    // photoUrl = prefs.getString('photoUrl') ?? '';

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
            'photoUrl': photoUrl,
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
    // focusNodeNickname.unfocus();
    // focusNodeAboutMe.unfocus();

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
      Navigator.pop(context);
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
          title: Text(
            "Profile",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff905c96),
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
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios),
          )),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              color: Color(0xff905c96),
              height: MediaQuery.of(context).size.height,
              child: Column(
               
                children: <Widget>[
                  Container(
                    color: Color(0xff905c96),
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          GestureDetector(
                            onTap: getImage,
                            child: (avatarImageFile == null)
                                ? (photoUrl != ''
                                    ? Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, photoUrl) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      themeColor),
                                            ),
                                            width: 90.0,
                                            height: 90.0,
                                            padding: EdgeInsets.all(10.0),
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
                          )
                        ],
                      ),
                    ),
                    width: double.infinity,
                    margin: EdgeInsets.all(10.0),
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
                        nickname.toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      SizedBox(
                        width: 6.0,
                      ),
                    ],
                  )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
        
                    children: <Widget>[
                      Container(
                          child: TextFormField(
                            minLines: 1,
                            maxLines: 1,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              fillColor: Color(0xffaf5dcc),
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffaf5dcc), width: 1.5),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffaf5dcc), width: 1.5),
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
                            controller: controllerNickname,
                            onChanged: (value) {
                              nickname = value;
                            },
                            //focusNode: focusNodeNickname,
                          ),
                          margin: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10.0)),
                        
                      Container(
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              fillColor: Color(0xffaf5dcc),
                              filled: true,
                              hintText: 'About',
                              contentPadding: new EdgeInsets.all(5.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffaf5dcc), width: 1.5),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xffaf5dcc),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(30.0)),
                              hintStyle: TextStyle(color: Colors.white),
                            ),
                            controller: controllerAboutMe,
                            onChanged: (value) {
                              aboutMe = value;
                            },
                            //focusNode: focusNodeAboutMe,
                          ),
                          margin: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10.0)),
                      Container(
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffaf5dcc),
                              hintText: 'Dog Name',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffaf5dcc), width: 1.5),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                      color: Color(0xffaf5dcc), width: 1.5))),
                          controller: controllerDogName,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          // focusNode: focusNodeAboutMe,
                        ),
                        margin:
                            EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      ),
                     
                      Container(
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffaf5dcc),
                              hintText: 'Zip',
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffaf5dcc), width: 1.5),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                      color: Color(0xffaf5dcc), width: 1.5))),
                          controller: controllerZip,
                          onChanged: (value) {
                            Zip = value;
                          },
                          //focusNode: focusNodeAboutMe,
                        ),
                        margin:
                            EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Material(
                      elevation: 10.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color(0xffaf5dcc),
                      child: Container(
                        width: 120.0,
                        height: 50.0,
                        child: MaterialButton(
                          // elevation: 5.0,
                          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          onPressed: handleUpdateData,
                          child: Text("SAVE",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
