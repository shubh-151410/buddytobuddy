import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PasswordUi extends StatefulWidget {
  @override
  _PasswordUiState createState() => _PasswordUiState();
}

class _PasswordUiState extends State<PasswordUi> {
  GlobalKey<FormState> _key = GlobalKey();
  bool _validate = false;
  DocumentSnapshot _currentDocument;

  String password, confirmpassword, email;
  final passwordcontroller = TextEditingController();
  final confirmpasswordcontroller = TextEditingController();
  final emailcontroller = TextEditingController();

  Future _add() {
    if (_key.currentState.validate()) {
      _key.currentState.save();
    }
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
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

  Future<void> changePassword() async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      QuerySnapshot querySnapshot = await Firestore.instance
          .collection("users")
          .where("name")
          .getDocuments();
      var list = querySnapshot.documents;

      for (int i = 0; i < querySnapshot.documents.length; i++) {
        if (email == list[i]["email"]) {
          await Firestore.instance
              .collection('users')
              .document(querySnapshot.documents[i].documentID)
              .updateData(
                  {'password': password, 'confirmPassword': confirmpassword});
          Fluttertoast.showToast(msg: "Password Is Updated");
        } else {
          //Fluttertoast.showToast(msg: "Email id is not registered");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var divheight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xff905c96),
          elevation: 5.0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios),
          )),
      body: Container(
        height: divheight,
        color: Color(0xff905c96),
        child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Form(
              key: _key,
              autovalidate: _validate,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    //controller: useremailcontroller,
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    minLines: 1,
                    maxLines: 1,
                    obscureText: false,
                    autofocus: false,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                      labelText: "E-mail",
                      labelStyle: TextStyle(color: Colors.white),
                      //errorText: useremailvalidate ? 'Email Can\'t Be Empty' : null,
                    ),
                    validator: validateEmail,
                    onSaved: (String val) {
                      email = val;
                    },
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
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      contentPadding: EdgeInsets.all(10.0),
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.white),
                      //errorText: passwordvallidate ? 'Password Can\'t Be Empty' : null,
                    ),
                    validator: validatePassword,
                    onSaved: (String value) {
                      password = value;
                    },
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
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      contentPadding: EdgeInsets.all(10.0),
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
                    height: 10.0,
                  ),
                  Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color(0xffaf5dcc),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: MaterialButton(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          onPressed: changePassword,
                          child: Text("Change Password",
                              style: TextStyle(color: Colors.white)),
                        ),
                      )),
                ],
              ),
            )),
      ),
    );
  }
}
