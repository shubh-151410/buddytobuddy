import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isSwitched = true;
  bool isLoading = false;
  String urlPDFPath = "";
  String assetPDFPath = "";

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LogIn()),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();

//    getFileFromUrl("https://drive.google.com/open?id=13sRZzF4GsvHuHBgkRTYFiA3eFNr9Cbof").then((f) {
//      setState(() {
//        urlPDFPath = f.path;
//        print(urlPDFPath);
//      });
//    });

    getFileFromAsset("assets/policy.pdf").then((f) {
      setState(() {
        assetPDFPath = f.path;
        print(assetPDFPath);
      });
    });
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

//  Future<File> getFileFromUrl(String url) async {
//    try {
//      var data = await http.get(url);
//      var bytes = data.bodyBytes;
//      var dir = await getApplicationDocumentsDirectory();
//      File file = File("${dir.path}/mypdfonline.pdf");
//
//      File urlFile = await file.writeAsBytes(bytes);
//      return urlFile;
//    } catch (e) {
//      throw Exception("Error opening url file");
//    }
//  }

  Future pdfviewer() async {
    PDFDocument doc = await PDFDocument.fromURL(
        'https://drive.google.com/open?id=13sRZzF4GsvHuHBgkRTYFiA3eFNr9Cbof');
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
                // SizedBox(width: 24.0),
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
            Center(
                child: SingleChildScrollView(
              // Optional
              child: Container(
                  height: divheight,
                  color: Color(0xff334d83),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Accounts",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              )),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Linked Accounts",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (assetPDFPath != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfViewPage(
                                                        path: assetPDFPath)));
                                      }
                                    },
                                    child: Text(
                                      "Privacy",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Push Notification",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Change Password",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              //crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Text(
                                          "2 Factor Authentication",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      )),
                                ),
                                Align(
                                  // alignment: Alignment.topCenter,
                                  child: Switch(
                                      value: isSwitched,
                                      onChanged: (value) {
                                        setState(() {
                                          isSwitched = value;
                                        });
                                      },
                                      activeTrackColor: Color(0xff98c1ef),
                                      activeColor: Color(0xff147ae5)),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      handleSignOut();
                                    },
                                    child: Text(
                                      "Sign Out",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                child: Text(
                                  "Support",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              )),
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "FAQs",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Report a problems",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, top: 3.0, right: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff6f92c4),
                                      width: 4.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            )),
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xfff5a623))),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        ));
  }
}

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key key, this.path}) : super(key: key);

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy And Policy"),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            nightMode: false,
            onError: (e) {
              print(e);
            },
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages;
                pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onPageChanged: (int page, int total) {
              setState(() {});
            },
            onPageError: (page, e) {},
          ),
          !pdfReady
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Offstage()
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _currentPage > 0
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  label: Text("Go to ${_currentPage - 1}"),
                  onPressed: () {
                    _currentPage -= 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
          _currentPage + 1 < _totalPages
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.green,
                  label: Text("Go to ${_currentPage + 1}"),
                  onPressed: () {
                    _currentPage += 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
        ],
      ),
    );
  }
}
