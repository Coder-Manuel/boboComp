import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bobocomp/taxi/requests/push_notifications.dart';
import 'package:bobocomp/taxi/screens/search.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bobocomp/taxi/states/app_state.dart';

import '../states/app_state.dart';

class MyTaxiPage extends StatefulWidget {
  MyTaxiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyTaxiPageState createState() => _MyTaxiPageState();
}

class _MyTaxiPageState extends State<MyTaxiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Map());
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> with SingleTickerProviderStateMixin {
  AppState state = AppState();
  Geolocator loc = new Geolocator();
  static LatLng _initialPosition;
  TextEditingController locationController = TextEditingController();
  LatLng get initialPosition => _initialPosition;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  BitmapDescriptor myPin;
  AnimationController animationControllerMenu;
  CurvedAnimation curve;
  Animation<double> animationR;

  get currentMenuPercent => max;

  var offsetMenu = 0.0;

  bool isMenuOpen = false;
  @override
  void initState() {
    getUserLocation();
    _setCustomPin();
    super.initState();
  }

  void getUserLocation() async {
    print("GET USER LOCATION RUNNING =========");
    await loc.getCurrentPosition();
    var permission = GeolocationStatus.granted;
    await loc.checkGeolocationPermissionStatus().then((value) => {
          if (value == permission)
            {
              loc.isLocationServiceEnabled().then((value) {
                if (value) {
                  Stream<Position> position = loc.getPositionStream(
                      LocationOptions(accuracy: LocationAccuracy.high));
                  position.listen((location) async {
                    setState(() {
                      _initialPosition =
                          LatLng(location.latitude, location.longitude);
                      if (_initialPosition != null) {
                        setState(() {
                          state.setLocation(_initialPosition);
                        });
                      }
                    });

                    if (_initialPosition != null) {
                      try {
                        List<Placemark> placemark =
                            await loc.placemarkFromCoordinates(
                                _initialPosition.latitude,
                                _initialPosition.longitude);
                        setState(() {
                          locationController.text = placemark[0].name;
                        });
                        final GoogleMapController controller =
                            await _controller.future;
                        CameraPosition newPosition = new CameraPosition(
                            target: _initialPosition, zoom: 17.2);
                        controller.animateCamera(
                            CameraUpdate.newCameraPosition(newPosition));
                        setState(() {
                          var newPin = _initialPosition;
                          _markers.removeWhere((element) =>
                              element.markerId.value == "My Position");
                          _markers.add(Marker(
                              markerId: MarkerId("My Position"),
                              position: newPin,
                              icon: myPin));
                        });
                      } catch (err) {
                        print(err);
                      }
                    }
                    print(
                        "the latitude is: ${_initialPosition.longitude} and th longitude is: ${_initialPosition.longitude} ");
                    print(
                        "initial position is : ${_initialPosition.toString()}");
                  });
                }
              })
            }
        });
    // return _initialPosition;
  }

  void _setCustomPin() async {
    var pin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/assets/location.png');
    setState(() {
      myPin = pin;
    });
  }

  void animateMenu(bool open) {
    animationControllerMenu =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    curve =
        CurvedAnimation(parent: animationControllerMenu, curve: Curves.ease);
    animationR =
        Tween(begin: open ? 0.0 : 358.0, end: open ? 358.0 : 0.0).animate(curve)
          ..addListener(() {
            setState(() {
              offsetMenu = animationR.value;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              isMenuOpen = open;
            }
          });
    animationControllerMenu.forward();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.blue));
    final appState = Provider.of<AppState>(context);
    return SafeArea(
      child: initialPosition == null
          ? Container(
              color: Colors.blue,
              child: Stack(
                children: <Widget>[
                  new Container(
                    child: Center(
                      child: new Text("Bobo Taxi",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 58,
                          )),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 148.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.pink),
                          strokeWidth: 6,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          : Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: initialPosition, zoom: 17.2),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      setState(() {
                        _markers.add(Marker(
                            markerId: MarkerId("My Position"),
                            position: _initialPosition,
                            icon: myPin));
                      });
                    },
                    myLocationEnabled: false,
                    mapType: MapType.normal,
                    compassEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: _markers,
                    onCameraMove: appState.onCameraMove,
                    zoomControlsEnabled: false,
                    // polylines: appState.polyLines,
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                      child: ClipOval(
                        child: Material(
                          color: Colors.blue, // button color
                          child: InkWell(
                            splashColor: Colors.blue, // inkwell color
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            onTap: () {
                              appState.mapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                      initialPosition.latitude,
                                      initialPosition.longitude,
                                    ),
                                    zoom: 17.2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color: Colors.blue, // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                                onTap: () {
                                  appState.mapController.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ClipOval(
                            child: Material(
                              color: Colors.blue, // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  appState.mapController.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 50.0,
                    right: 15.0,
                    left: 15.0,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 5.0),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: TextField(
                          cursorColor: Colors.black,
                          controller: locationController,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 18.0),
                          decoration: InputDecoration(
                            icon: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 38,
                              ),
                            ),
                            hintText: "pick up",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(6.0),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 105.0,
                    right: 15.0,
                    left: 15.0,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 5.0),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: TextField(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search(
                                          location: locationController.text,
                                          locCoord:
                                              "${_initialPosition.latitude},${_initialPosition.longitude}",
                                        )));
                          },
                          cursorColor: Colors.black,
                          // controller: appState.destinationController,
                          readOnly: true,
                          textInputAction: TextInputAction.go,
                          // onSubmitted: (value) {
                          //   appState.sendRequest(value);
                          // },
                          decoration: InputDecoration(
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Icon(
                                Icons.add_circle,
                                color: Colors.green,
                                size: 38,
                              ),
                            ),
                            hintText: "Where To ?",
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),

//        Positioned(
//          top: 40,
//          right: 10,
//          child: FloatingActionButton(onPressed: _onAddMarkerPressed,
//          tooltip: "aadd marker",
//          backgroundColor: black,
//          child: Icon(Icons.add_location, color: white,),
//          ),
//        )
                ],
              ),
            ),
    );
  }
}
