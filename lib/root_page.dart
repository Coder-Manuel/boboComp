import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/home_page.dart';
import 'package:bobocomp/login_signup_page.dart';
import 'package:bobocomp/modules/club_module.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  // RootPage({this.auth});

  final BaseAuth auth = Auth();

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((FirebaseUser user) {
      setState(() {
        if (user != null) {
          // authStatus = AuthStatus.NOT_LOGGED_IN;
          authStatus = AuthStatus.LOGGED_IN;
        } else {
          authStatus = AuthStatus.NOT_LOGGED_IN;
        }
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      widget.auth.signOut();
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget _buildWaitingScreen() {
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        // return Container();
        break;
      case AuthStatus.LOGGED_IN:
        return Consumer<ClubModule>(
          builder: (context, clubModule, _) {
            // return Container();
            return GoogleMapPage(
              signOut: _onSignedOut,
            );
            // return GoogleMapPage(signOut: widget.auth.signOut,);
          },
        );
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
