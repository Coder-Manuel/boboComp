

import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel{
  final String id;
  final String club;
  // final String company;
  final DocumentReference company;
  final String title;
  final String description;
  final String image;
  final DateTime date;

  EventModel({
    this.id = '',
    this.club,
    this.company,
    this.title,
    this.description,
    this.image,
    this.date
  });


  Map<String, dynamic>  asMap(){
    return{
      'club': club,
      'company': company,
      'title': title,
      'description': description,
      'image': image,
      'date': date,
    };
  }

  EventModel fromMap(Map<String, dynamic> obj){
    return obj == null ? 
    null :
    EventModel(
      id: obj['id'].toString(),
      club: obj['club'].toString(),
      company: obj['company'],
      title: obj['title'].toString(),
      description: obj['description'].toString(),
      image: obj['image'].toString(),
      date: null // TODO
    );
  }
}