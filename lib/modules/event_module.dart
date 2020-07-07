import 'dart:io';
import 'dart:math';

import 'package:bobocomp/modals/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class EventModule extends ChangeNotifier {
  // Firebase
  final databaseReference = Firestore.instance;

  List<EventModel> _events = [];

  List<EventModel> get events => _events;

  Future<List<EventModel>> currenClubEvents(clubId) async {
    return await clubEvents(clubId);
  }

  set setEvents(List<EventModel> ev) {
    _events = ev;
  }

  set addEvent(EventModel ev) {
    createEvent(ev);
  }

  Future<List<EventModel>> clubEvents(String clubId) async {
    DocumentReference clubRef = databaseReference.document('clubs/$clubId');
    QuerySnapshot ref = await databaseReference
        .collection("events")
        .where('club', isEqualTo: clubRef)
        .getDocuments();
    return _convertToEventsModel(ref.documents);
  }

  void fetchClubEvents(String clubId) {
    DocumentReference clubRef = databaseReference.document('clubs/$clubId');
    Future<QuerySnapshot> ref = databaseReference
        .collection("events")
        .where('club', isEqualTo: clubRef)
        .getDocuments();
    ref.then((item) {
      setEvents = _convertToEventsModel(item.documents);
    });
  }

  void createEvent(EventModel ev) async {
    DocumentReference ref =
        await databaseReference.collection("events").add(ev.map);
  }

  DateTime _convertToDateTime(dt) {
    return dt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(dt.seconds * 1000);
  }

  List<EventModel> _convertToEventsModel(List<DocumentSnapshot> data) {
    List<EventModel> _eventsModel = [];
    data.forEach((item) {
      _eventsModel.add(EventModel(
        id: item.documentID,
        club: item.data['club'],
        title: item.data['title'],
        description: item.data['description'],
        image: item.data['image'],
        date: item.data['date'],
      ));
    });
    return _eventsModel;
  }

  Future<String> uploadImage(File image) async {
    String _url;
    if (image != null) {
      String _filePath = image.path;
      String _extension = _filePath.split('/').last.split('.').last;
      String _label = _filePath.split('/').last.split('.')[0];
      String _fileName =
          Random().nextInt(10000).toString() + _label + '.$_extension';
      final StorageReference _storageRef =
          FirebaseStorage.instance.ref().child(_fileName);

      final StorageUploadTask uploadTask = _storageRef.putFile(
        image,
      );
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      _url = (await downloadUrl.ref.getDownloadURL());
    }
    return _url;
  }
}
