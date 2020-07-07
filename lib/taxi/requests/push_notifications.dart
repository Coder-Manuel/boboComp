import 'dart:io';
import 'dart:math';

import 'package:bobocomp/taxi/utils/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeleton_text/skeleton_text.dart';

final Firestore _db = Firestore.instance;
final FirebaseMessaging _fcm = FirebaseMessaging();
int max = 100000;

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

//PUSH MESSAGE CONFIGURATION
@override
void fcm(BuildContext context) {
  _fcm.configure(
    onMessage: (Map<String, dynamic> message) async {
      print("On Message: $message");
      final String head = message["data"]["head"];
      final String name = message["data"]["name"];
      final String image = message["data"]["photo"];
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
                title: head,
                name: name,
                image: image,
              ));
    },
    onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
      final String head = message["data"]["head"];
      final String name = message["data"]["name"];
      final String image = message["data"]["photo"];
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
                title: head,
                name: name,
                image: image,
              ));
    },
    onResume: (Map<String, dynamic> message) async {
      print("onResume: $message");
      final String head = message["data"]["head"];
      final String name = message["data"]["name"];
      final String image = message["data"]["photo"];
      showDialog(
          context: context,
          builder: (context) => CustomDialog(
                title: head,
                name: name,
                image: image,
              ));
    },
  );
}

// SEND A RIDE REQUEST
void requestRide(
    {String eTA,
    String distance,
    String destName,
    String token,
    String location,
    String hCoord,
    String coord}) async {
  var docID = Random().nextInt(max);
  try {
    FirebaseUser user = await FirebaseAuth.instance.currentUser().then((user) {
      _db.collection("users").document(user.uid).get().then((value) async {
        User _user = new User(
            dp: value.data['dp'],
            headedname: destName,
            headedlocdistance: distance,
            headedcoord: hCoord,
            token: token,
            documentId: docID.toString(),
            location: location,
            status: 0,
            client: value.data['username'],
            coordinate: coord);

        try {
          await _db
              .collection("Taxi_Request")
              .document(docID.toString())
              .setData(_user.asMap())
              .then((value) {
            // FlutterToast.showToast(msg: "Ride Request Succesful");
          });
        } catch (err) {
          // FlutterToast.showToast(msg: "Request Failed: $err");
        }
      });
    });
  } catch (err) {
    // FlutterToast.showToast(msg: "Username Retrieval Failed: $err");
  }
}

// GET THE DEVICE UNIQUE TOKEN
getToken() async {
  String token = await _fcm.getToken();
  print(token);
  return token;
}

// CHECK INTERNET CONNECTION
checkConnection() async {
  bool hasInternet = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      hasInternet = true;
      print('connected');
    }
  } on SocketException catch (_) {
    hasInternet = false;
    print('not connected');
  }
  return hasInternet;
}

class CustomDialog extends StatelessWidget {
  final String title, name, image;

  CustomDialog({
    @required this.title,
    @required this.name,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.0),
              Divider(),
              SizedBox(height: 8.0),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Divider(),
              SizedBox(height: 24.0),
            ],
          ),
        ),
        //...top circlular image part,
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: ClipOval(
            child: FutureBuilder<Widget>(
              future: Future.delayed(Duration(milliseconds: 100)),
              initialData: loading(),
              builder: (context, snapshot) {
                return image != null
                    ? Image.network(
                        image,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/avatar.png",
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: Consts.padding),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Consts.padding),
                  bottomRight: Radius.circular(Consts.padding)),
            ),
            child: MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget loading() {
    return new Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SkeletonAnimation(
              shimmerColor: Colors.grey[200],
              child: Container(
                height: 5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SkeletonAnimation(
              shimmerColor: Colors.grey[200],
              child: Container(
                height: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
