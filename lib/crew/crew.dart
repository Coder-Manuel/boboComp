import 'package:bobocomp/crew/helper/authenticate.dart';
import 'package:bobocomp/crew/helper/helperfunctions.dart';
import 'package:bobocomp/crew/views/chatrooms.dart';
import 'package:flutter/material.dart';

class MyCrew extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyCrewState createState() => _MyCrewState();
}

class _MyCrewState extends State<MyCrew> {
  bool userIsLoggedIn;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CREW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff1F1F1F),
        accentColor: Color(0xff007EF4),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn != null
          ? userIsLoggedIn ? ChatRoom() : Authenticate()
          : Container(
              child: Center(
                child: Authenticate(),
              ),
            ),
    );
  }
}
