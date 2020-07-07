import 'dart:async';

import 'package:bobocomp/taxi/credentials/credentials.dart';
import 'package:bobocomp/taxi/screens/show_ride.dart';
import 'package:bobocomp/taxi/states/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';

class Search extends StatefulWidget {
  final String location;
  final String locCoord;

  const Search({Key key, this.location, this.locCoord}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController search = TextEditingController();
  TextEditingController myLocation = TextEditingController();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: placeApiKey);
  String name;
  String plcId;
  Timer throttle;
  bool isDestination = true;
  AppState state = AppState();

  @override
  void initState() {
    state.destinationController = search;
    myLocation.text = widget.location;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.blue));
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                ),
                Spacer(),
                new Text(
                  "Set Destination",
                  style: new TextStyle(
                      color: Colors.blue,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: new Container(
                height: MediaQuery.of(context).size.height / 16,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: myLocation,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blue,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(8.0),
                      hintText: "From "),
                  onChanged: (input) {
                    setState(() {
                      isDestination = false;
                    });
                    if (throttle?.isActive ?? false) throttle.cancel();
                    throttle = Timer(const Duration(milliseconds: 500), () {
                      appState.locationAuto(input);
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: new Container(
                height: MediaQuery.of(context).size.height / 16,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: search,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Icon(
                          Icons.add_location,
                          color: Colors.blue,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(8.0),
                      hintText: "Where To ?"),
                  onChanged: (input) {
                    setState(() {
                      isDestination = true;
                    });
                    if (throttle?.isActive ?? false) throttle.cancel();
                    throttle = Timer(const Duration(milliseconds: 500), () {
                      appState.locationAuto(input);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: isDestination
                  ? new ListView.builder(
                      itemCount: appState.results.length,
                      itemBuilder: (context, int index) {
                        if (appState.results.isEmpty) {
                          return _loading();
                        } else {
                          return ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.black54,
                              ),
                            ),
                            title: new Text(appState.results[index].name),
                            // subtitle: new Text(appState.results[index].details),
                            onTap: () {
                              setState(() {
                                name = appState.results[index].name.toString();
                                plcId =
                                    appState.results[index].placeId.toString();
                                search.text = appState.results[index].name;
                                appState.destinationController = search;

                                appState.sendRequest(
                                  name,
                                  plcId,
                                );
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RideShow(
                                              locname: widget.location,
                                              location: widget.locCoord,
                                              destname: name,
                                              // destloc: "${appState.destination.latitude},${appState.destination.longitude}",
                                            )));
                                // map.setState(() { });
                              });
                            },
                          );
                        }
                      },
                    )
                  : new ListView.builder(
                      itemCount: appState.results.length,
                      itemBuilder: (context, int index) {
                        if (appState.results.isEmpty) {
                          return _loading();
                        } else {
                          return ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.black54,
                              ),
                            ),
                            title: new Text(appState.results[index].name),
                            // subtitle: new Text(appState.results[index].details),
                            onTap: () {
                              setState(() {
                                myLocation.text =
                                    appState.results[index].name.toString();
                                plcId =
                                    appState.results[index].placeId.toString();
                                _myLocation(plcId);
                              });
                            },
                          );
                        }
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  void _myLocation(String place) async {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(place);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    LatLng myPoint = LatLng(lat, lng);
    setState(() {
      state.search = myPoint;
      print("This is the Location from search: $myPoint");
      print("This is the Location set in AppState: ${state.search}");
    });
  }

  Widget _loading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white70),
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
                    color: Colors.grey[300],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
                    child: SkeletonAnimation(
                      child: Container(
                        height: 15,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300]),
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
                          height: 13,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
