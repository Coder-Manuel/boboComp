import 'dart:async';
import 'dart:math';
import 'package:bobocomp/taxi/utils/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bobocomp/taxi/requests/google_maps_requests.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:bobocomp/taxi/credentials/credentials.dart';
import 'package:dio/dio.dart';

class AppState with ChangeNotifier {
  Geolocator loc = new Geolocator();
  static LatLng _initialPosition;
  LatLng _destination;
  LatLng search;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  Position northEast;
  Position southWest;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  LatLng get initialPosition => _initialPosition;
  LatLng get destination => _destination;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: placeApiKey);
  List<Place> results = [
    Place('Kfc-Nakuru, Town East, West Road', 'ChIJkeTKj7-NKRgRjJgS8zF7IP8',
        'Nakuru Town, West Road'),
    Place('Westside Mall, Nakuru, Kenya', 'ChIJG6qqaL-NKRgRPxJLIKX_b4U',
        'Nakuru, Kenya'),
    Place('TOWER ONE, Nakuru, Kenya', 'ChIJReNqS5SNKRgRZzWs42JU4So',
        'Nakuru, Kenya'),
    Place('Assumption Centre CDN, Nakuru, Kenya', 'ChIJ3a-EjeuNKRgR4V7ncDl6RBc',
        'Nakuru Kenya'),
    Place('Afraha Stadium, Nakuru, Kenya', 'ChIJqQzGYe-NKRgRwerpHQuZYHE',
        'Nakuru, Kenya'),
    Place('The Ole-Ken Hotel, West Road, Nakuru, Kenya',
        'ChIJpY4xwMCNKRgRvGaTuJqgjTw', 'West Road, Makuru'),
    Place('Rift Valley Sports Club, Nakuru, Kenya',
        'ChIJ88tdm5SNKRgR0CWoxvhN8UQ', 'Nakuru, Kenya'),
    Place('Kenya Commercial Bank, Nakuru, Kenya', 'ChIJTeUTOr6NKRgRXfwu8vyla5A',
        'Nakuru, Kenya'),
  ];
  String name, placeId, details;
  double totalDistance = 0;
  var placeDistance;
  int max = 1000000;

  AppState() {
    _loadingInitialPosition();
  }
// ! TO GET THE USERS LOCATION
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
                    _initialPosition =
                        LatLng(location.latitude, location.longitude);
                    List<Placemark> placemark =
                        await loc.placemarkFromCoordinates(
                            _initialPosition.latitude,
                            _initialPosition.longitude);
                    locationController.text = placemark[0].name;
                    print(
                        "the latitude is: ${_initialPosition.longitude} and th longitude is: ${_initialPosition.longitude} ");
                    print(
                        "initial position is : ${_initialPosition.toString()}");
                    notifyListeners();
                  });
                }
              })
            }
        });
    // return _initialPosition;
  }

  void setLocation(LatLng pos) {
    _initialPosition = pos;
  }

  // ! TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.clear();
    _polyLines.add(Polyline(
        startCap: Cap.roundCap,
        endCap: Cap.buttCap,
        polylineId: PolylineId(_lastPosition.toString()),
        width: 3,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.blue));
    notifyListeners();
  }

  // ! ADD A MARKER ON THE MAP
  void _addMarker({LatLng location1, location2, String address1, address2}) {
    _markers.clear();
    _markers.add(Marker(
        markerId: MarkerId(location1.toString()),
        position: location1,
        infoWindow: InfoWindow(title: address1, snippet: "Go Here"),
        icon: BitmapDescriptor.defaultMarker));
    _markers.add(Marker(
        markerId: MarkerId(location2.toString()),
        position: location2,
        infoWindow: InfoWindow(title: address2, snippet: "Go Here"),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  // ! CREATE LAGLNG LIST
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  // ! SEND REQUEST
  void sendRequest(String intendedLocation, String place) async {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(place);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    _destination = LatLng(lat, lng);
    if (search != null) {
      if (search != _initialPosition) {
        _initialPosition = search;
      }
    }
    _addMarker(
        location1: _initialPosition,
        location2: destination,
        address1: locationController.text,
        address2: intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    createRoute(route);

//=====CALCULATE THE TOTAL DISTANCE BETWEEN THE TWO POINTS========
    totalDistance = 0;
    for (int i = 0; i < _polyLines.first.points.length - 1; i++) {
      totalDistance += _coordinateDistance(
          _polyLines.first.points[i].latitude,
          _polyLines.first.points[i].longitude,
          _polyLines.first.points[i + 1].latitude,
          _polyLines.first.points[i + 1].longitude);
    }
    placeDistance = double.parse(totalDistance.toStringAsFixed(2));
    _setMapFitToTour(_polyLines);

    notifyListeners();
  }

  // CALCULATE THE TOTAL DISTANCE
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

// ANIMATE CAMERA TO FIT THE ROUTE
  void _setMapFitToTour(Set<Polyline> p) {
    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;
    p.forEach((poly) {
      poly.points.forEach((point) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      });
    });
    mapController.moveCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        100));
  }

  // GET DESTINATION BY AUTOCOMPLETE
  void locationAuto(String input) async {
    results.clear();
    var session = Random().nextInt(max);
    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String comp = "country:ke";
    var raddi = 32189;
    LatLng location = _initialPosition;
    String request =
        "$baseUrl?input=$input&components=$comp&location=$location&radius=$raddi&key=$placeApiKey&sessiontoken=$session";
    Response response = await Dio().get(request);

    final predictions = response.data["predictions"];

    for (var i = 0; i < predictions.length; i++) {
      name = predictions[i]["description"];
      placeId = predictions[i]["place_id"];
      details = predictions[i]["secondary_text"];

      results.add(Place(name, placeId, details));
    }
    print(response);
    notifyListeners();
  }

  // ! ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

//  LOADING INITIAL POSITION
  void _loadingInitialPosition() async {
    print("GET 23 LOCATION RUNNING =========");
    await Future.delayed(Duration(seconds: 10)).then((v) {
      if (_initialPosition == null) {
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }
}
