import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel{
  final String id;
  final DocumentReference club;
  final String title;
  final String description;
  final String image;
  final DateTime date;

  EventModel({
    this.id = '',
    this.club,
    this.title,
    this.description,
    this.image,
    this.date
  });

  Map<String, dynamic> get map => _map();

  _map(){
    return{
      'club': club,
      'title': title,
      'description': description,
      'image': image,
      'date': date,
    };
  }
}