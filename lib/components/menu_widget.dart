import 'dart:io';

import 'package:bobocomp/modals/user_model.dart';
import 'package:bobocomp/modules/event_module.dart';
import 'package:bobocomp/modules/user_module.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bobocomp/helper/ui_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// Drawer Menu
class MenuWidget extends StatefulWidget {
  final num currentMenuPercent;
  final Function signOut;
  final Function(bool) animateMenu;

  MenuWidget({Key key, this.currentMenuPercent, this.animateMenu, this.signOut})
      : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final menuItems = [
    // 'Club',
    // 'Event',
    'Companies',
    'Tickets',
    // 'Payment',
    'Crew',
    'Taxi',
    'Settings'
  ];

  UserModel userModel = UserModel(username: '', id: '', dp: '', email: '');

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: UserModule(),
      child: widget.currentMenuPercent != 0
          ? Positioned(
              left: realW(-358 + 358 * widget.currentMenuPercent),
              width: realW(358),
              height: screenHeight,
              child: Opacity(
                opacity: widget.currentMenuPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(realW(50))),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.16),
                          blurRadius: realW(20)),
                    ],
                  ),
                  child: Stack(
                    children: <Widget>[
                      NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (notification) {
                          notification.disallowGlow();
                        },
                        child: CustomScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Container(
                                height: realH(236),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(realW(50))),
                                    gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        colors: [
                                          Color(0xFF59C2FF),
                                          Color(0xFF1270E3),
                                        ])),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfile()));
                                  },
                                  child: Consumer<UserModule>(
                                    builder: (context, _userModule, _) {
                                      _userModule.currentUser();
                                      if (_userModule.getUser != null) {
                                        userModel = _userModule.getUser;
                                      }
                                      return Stack(
                                        children: <Widget>[
                                          Positioned(
                                            left: realW(10),
                                            bottom: realH(27),
                                            child: ClipOval(
                                              child: userModel.dp == null
                                                  ? Image.asset(
                                                      "assets/avatar.png",
                                                      width: realH(120),
                                                      height: realH(120),
                                                      fit: BoxFit.fitHeight,
                                                    )
                                                  : Image.network(
                                                      userModel.dp,
                                                      width: realH(120),
                                                      height: realH(120),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            left: realW(135),
                                            top: realH(110),
                                            child: DefaultTextStyle(
                                              style: TextStyle(
                                                  color: Colors.white),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    userModel.username
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: realW(18)),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                realH(11.0)),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text.rich(
                                                        TextSpan(
                                                          text: userModel.email
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  realW(16),
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.only(
                                  top: realH(34),
                                  bottom: realH(50),
                                  right: realW(37)),
                              sliver: SliverFixedExtentList(
                                itemExtent: realH(56),
                                delegate: new SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  String _routPath = '/';
                                  switch (menuItems[index]) {
                                    case 'Club':
                                      _routPath = '/club';
                                      break;
                                    case 'Crew':
                                      _routPath = '/crew';
                                      break;
                                    case 'Companies':
                                      _routPath = '/company';
                                      break;
                                    case 'Tickets':
                                      _routPath = '/tickets';
                                      break;
                                    case 'Payment':
                                      _routPath = '/payment';
                                      break;
                                    case 'Taxi':
                                      _routPath = '/taxi';
                                      break;
                                    case 'Settings':
                                      _routPath = '/settings';
                                      break;
                                    default:
                                      _routPath = '/';
                                  }
                                  //创建列表项
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed(_routPath);
                                    },
                                    child: Container(
                                      width: realW(321),
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(left: realW(20)),
                                      decoration: index == 0
                                          ? BoxDecoration(
                                              color: Color(0xFF379BF2)
                                                  .withOpacity(0.2),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(
                                                      realW(50)),
                                                  bottomRight: Radius.circular(
                                                      realW(50))))
                                          : null,
                                      child: Text(
                                        menuItems[index],
                                        style: TextStyle(
                                            color: index == 0
                                                ? Colors.blue
                                                : Colors.black,
                                            fontSize: realW(20)),
                                      ),
                                    ),
                                  );
                                }, childCount: menuItems.length),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.only(left: realW(20)),
                              sliver: SliverToBoxAdapter(
                                child: InkWell(
                                  onTap: () async {
                                    final FirebaseAuth _firebaseAuth =
                                        FirebaseAuth.instance;
                                    await _firebaseAuth.signOut();

                                    // widget.signOut();
                                    Navigator.of(context).pushNamed('/logout');
                                  },
                                  child: Text(
                                    'Signout',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: realW(20)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      // close button
                      Positioned(
                        bottom: realH(53),
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            widget.animateMenu(false);
                          },
                          child: Container(
                            width: realW(71),
                            height: realH(71),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: realW(17)),
                            child: Icon(
                              Icons.close,
                              color: Color(0xFFE96977),
                              size: realW(34),
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFB5E74).withOpacity(0.2),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(realW(36)),
                                  topLeft: Radius.circular(realW(36))),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : const Padding(padding: EdgeInsets.all(0)),
    );
  }
}

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  UserModel userModel = UserModel(username: '', id: '', dp: '', email: '');

  TextEditingController _userName = TextEditingController();

  File _dp;

  Image _image =
      Image.asset('assets/avatar.png', width: realH(320), height: realH(320));

  String _dbId;

  bool _isImage = false;

  String _dpUrl;

  @override
  void initState() {
    super.initState();
    UserModule userModule = new UserModule();
    userModule.currentUser().then((obj) {
      setState(() {
        userModel = obj;
        _userName.text = userModel.username == null ? '' : userModel.username;
        _dpUrl = obj.dp;

        if (userModel.dp != null) {
          _isImage = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                ImagePicker.pickImage(source: ImageSource.gallery)
                    .then((value) {
                  setState(() {
                    _dp = value;
                    _image = Image.file(
                      _dp,
                      width: realH(320),
                      height: realH(320),
                      fit: BoxFit.fitHeight,
                    );
                    _isImage = false;
                  });
                });
              },
              child: Container(
                child: !_isImage
                    ? _image
                    : Image.network(
                        _dpUrl,
                        width: realH(320),
                        height: realH(320),
                        fit: BoxFit.fitHeight,
                      ),
              ),
            ),
            Text(userModel.email),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _userName,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(
              height: 15,
            ),
            RaisedButton(
              child: Text('Update'),
              onPressed: () async {
                EventModule eventModule = EventModule();
                String url = _dpUrl;
                if (_dp != null) {
                  url = await eventModule.uploadImage(_dp);
                }
                UserModel _userModel = UserModel(
                  email: userModel.email,
                  username: _userName.text,
                  dp: url,
                  id: userModel.id,
                );
                UserModule _userModule = UserModule();
                _userModule.updateUser(_userModel);
                _userModule.currentUser().then((obj) {
                  setState(() {
                    userModel = obj;
                    _userName.text =
                        userModel.username == null ? '' : userModel.username;
                    _dpUrl = obj.dp;

                    if (userModel.dp != null) {
                      _isImage = true;
                    }
                  });
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
