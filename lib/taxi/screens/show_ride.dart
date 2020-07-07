import 'package:bobocomp/taxi/modals/taxi.dart';
import 'package:bobocomp/taxi/requests/google_maps_requests.dart';
import 'package:bobocomp/taxi/requests/push_notifications.dart';
import 'package:bobocomp/taxi/states/app_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';

class RideShow extends StatefulWidget {
  final String destname;
  final String location;
  final String locname;

  const RideShow({this.location, this.locname, this.destname});
  @override
  _RideShowState createState() => _RideShowState();
}

class _RideShowState extends State<RideShow> {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  // final name;
  // final String coord;
  String token;
  // String deslocation;
  // String posCoords;
  final List<TaxiType> taxiTypes = [
    TaxiType.Classic,
    TaxiType.Premium,
    TaxiType.Executive
  ];
  TaxiType selectedTaxi;
  double rideCost = 0.0;
  AppState state = AppState();
  bool isRide = false;
  bool awaitingDriver = false;
  bool rideAccepted = false;
  bool inittial = true;
  // _RideShowState(this.name, this.coord);

  String head;
  String name;
  String image;

  void fcm(BuildContext context) {
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("On Message: $message");
        setState(() {
          head = message["data"]["head"];
          name = message["data"]["name"];
          image = message["data"]["photo"];
          rideAccepted = true;
          awaitingDriver = false;
        });

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
        setState(() {
          head = message["data"]["head"];
          name = message["data"]["name"];
          image = message["data"]["photo"];
          rideAccepted = true;
          awaitingDriver = false;
        });
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
        setState(() {
          head = message["data"]["head"];
          name = message["data"]["name"];
          image = message["data"]["photo"];
          rideAccepted = true;
          awaitingDriver = false;
        });
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

  @override
  void initState() {
    setToken();
    fcm(context);
    selectedTaxi = TaxiType.Classic;
    setState(() {
      // deslocation = name;
      // posCoords = coord;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setToken() async {
    String tkn = await getToken();
    setState(() {
      token = tkn;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.blue));
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: Container(
        child: new Stack(
          children: <Widget>[
            new Container(
              height: MediaQuery.of(context).size.height / 2 + 90,
              child: Stack(children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: appState.initialPosition, zoom: 16, tilt: 10.0),
                  onMapCreated: appState.onCreated,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  compassEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: appState.markers != null
                      ? Set<Marker>.from(appState.markers)
                      : null,
                  onCameraMove: appState.onCameraMove,
                  polylines: appState.polyLines,
                  trafficEnabled: true,
                  buildingsEnabled: true,
                  mapToolbarEnabled: true,
                  zoomControlsEnabled: false,
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
                                    appState.initialPosition.latitude,
                                    appState.initialPosition.longitude,
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
              ]),
            ),
            Visibility(
              child: _waitingDriver(),
              visible: awaitingDriver == true,
            ),
            Visibility(
              child: _rideRequest(),
              visible: inittial == true,
            ),
            Visibility(
              child: _driverDisplay(),
              visible: rideAccepted == true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _taxi() {
    return Container(
      child: new Column(
        children: <Widget>[
          Expanded(
            child: new Container(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Text(
                          "Choose Taxi",
                          style: Theme.of(context).textTheme.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      buildTaxis(),
                      buildPriceDetails(),
                      _rideButton()
                    ])),
          )
        ],
      ),
    );
  }

  Widget _rideButton() {
    final appState = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
      child: new Container(
        // height: 50,
        decoration: BoxDecoration(
            color: Colors.blue[400], borderRadius: BorderRadius.circular(20)),
        child: new MaterialButton(
          onPressed: () {
            requestRide(
                location: widget.locname,
                coord: widget.location,
                destName: widget.destname,
                hCoord:
                    "${appState.destination.latitude},${appState.destination.longitude}",
                distance: "${appState.placeDistance}",
                token: token);
            setState(() {
              awaitingDriver = true;
              inittial = false;
            });
          },
          child: new Text(
            "SELECT RIDE",
            style: new TextStyle(color: Colors.white, fontSize: 28.0),
          ),
        ),
      ),
    );
  }

  Widget buildTaxis() {
    final appState = Provider.of<AppState>(context);
    Future.delayed(Duration(seconds: 1), () {
      calculator(selectedTaxi, appState.placeDistance);
    });
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: taxiTypes
              .map((val) => InkWell(
                    onTap: () {
                      var d = appState.placeDistance;
                      setState(() {
                        selectedTaxi = val;
                        calculator(val, d);
                      });
                    },
                    child: Opacity(
                      opacity: val == selectedTaxi ? 1.0 : 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.asset(
                                "assets/assets/taxi.jpg",
                                height: MediaQuery.of(context).size.width / 6,
                                width: MediaQuery.of(context).size.width / 6,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 12.0,
                            ),
                            Text(
                              val.toString().replaceFirst("TaxiType.", ""),
                              style: Theme.of(context).textTheme.title,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void calculator(TaxiType taxi, distance) {
    double busFare, time, disCost;
    Future.delayed(Duration(seconds: 0)).then((value) {
      switch (taxi) {
        case TaxiType.Classic:
          setState(() {
            busFare = 160.0;
            disCost = (distance * 40.0);
            time = 20.0;
            rideCost = (busFare + disCost + time).truncateToDouble();
          });
          break;
        case TaxiType.Premium:
          setState(() {
            busFare = 200.0;
            disCost = (distance * 60.0);
            time = 40.0;
            rideCost = (busFare + disCost + time).truncateToDouble();
          });
          break;
        case TaxiType.Executive:
          setState(() {
            busFare = 300.0;
            disCost = (distance * 100.0);
            time = 60.0;
            rideCost = (busFare + disCost + time).truncateToDouble();
          });
          break;
        default:
          {
            setState(() {
              rideCost = 0.0;
            });
          }
      }
    });

    // return rideCost;
  }

  Widget buildPriceDetails() {
    final appState = Provider.of<AppState>(context);
    if (rideCost == 0) {
      return _loading();
    } else {
      return Column(
        children: <Widget>[
          Divider(),
          SizedBox(
            height: 14.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildIconText("${appState.placeDistance} Km", Icons.directions),
              buildIconText("Ksh $rideCost", Icons.assistant),
            ],
          ),
          SizedBox(
            height: 14.0,
          ),
          Divider()
        ],
      );
    }
  }

  Widget buildIconText(String text, IconData iconData) {
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          size: 22.0,
          color: Colors.black,
        ),
        Text(
          " $text",
          style: Theme.of(context).textTheme.title,
        )
      ],
    );
  }

  Widget _loading() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SkeletonAnimation(
              child: Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey[350],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SkeletonAnimation(
                    child: Container(
                      height: 15,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[350]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: SkeletonAnimation(
                      child: Container(
                        width: 60,
                        height: 33,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[350]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rideRequest() {
    return Container(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: new Container(
          height: MediaQuery.of(context).size.height / 2 - 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, 5.0),
                  blurRadius: 10,
                  spreadRadius: 3)
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 15 + 265,
                decoration: BoxDecoration(
                  color: Colors.grey[300].withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                ),
                child: _taxi(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _waitingDriver() {
    return Container(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: new Container(
          height: MediaQuery.of(context).size.height / 2 - 80,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, 5.0),
                  blurRadius: 10,
                  spreadRadius: 3)
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 15 + 265,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: new Text("Kindly Wait",
                          style:
                              new TextStyle(color: Colors.white, fontSize: 30)),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                          height: 70,
                          width: 70,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.pink),
                            strokeWidth: 5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    new Text("Searching For Driver",
                        style: new TextStyle(color: Colors.white, fontSize: 30))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _driverDisplay() {
    return Container(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: new Container(
          height: MediaQuery.of(context).size.height / 2 - 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, 5.0),
                  blurRadius: 10,
                  spreadRadius: 3)
            ],
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: new Container(
              height: MediaQuery.of(context).size.height / 2 - 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(35)),
              child: new Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          child: new Text(
                            "Here's your Driver",
                            maxLines: 2,
                            style: new TextStyle(
                                color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            child: ClipOval(
                              child: Container(
                                height: 150,
                                width: 150,
                                child: ClipOval(
                                    child: image == null
                                        ? Image.asset(
                                            "assets/assets/avatar.png")
                                        : Image.network(image)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: new Text(
                                    name == null ? "No UserName" : name,
                                    maxLines: 2,
                                    style: new TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
