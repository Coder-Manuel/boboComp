import 'package:flutter/material.dart';

const Color black = Colors.black;
const Color white = Colors.white;

class Place {
  final name;
  final placeId;
  final details;

  Place(this.name, this.placeId, this.details);
}

class User {
  final token;
  final client;
  final dp;
  final location;
  final coordinate;
  final status;
  final headedname;
  final headedcoord;
  final headedlocdistance;
  final documentId;

  User(
      {this.dp,
      this.headedname,
      this.headedcoord,
      this.headedlocdistance,
      this.token,
      this.location,
      this.status,
      this.client,
      this.coordinate,
      this.documentId});

  Map<String, dynamic> asMap() {
    return {
      "token": token,
      "location": location,
      "status": status,
      "client": client,
      "coordinate": coordinate,
      "dp": dp,
      "headedname": headedname,
      "headedcoord": headedcoord,
      "headedlocdistance": headedlocdistance,
      "documentID": documentId,
    };
  }
}