import 'package:bobocomp/modals/company_models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModule with ChangeNotifier {
  List<EventModel> _companyEvents = [];

  set setCompanyEvents(List<EventModel> _items) {
    _companyEvents = _items;
    notifyListeners();
  }

  set addCompanyEvent(EventModel _item) {
    _companyEvents.add(_item);
    notifyListeners();
  }

  List<EventModel> get companyEvents => _companyEvents;

  void get fetchCompanyEvents async {
    List<EventModel> _items = await fetchAllEvent();
    setCompanyEvents = _items;
  }

  void fetchCompanyEventsByCompanyId(String companyId) async {
    List<EventModel> _items = await _fetchCompanyEventsByCompanyId(companyId);
    setCompanyEvents = _items;
  }

  // Firebase
  final databaseReference = Firestore.instance;
  EventModel _eventModel = EventModel();

  // create
  void createEvent(EventModel eventModel) async {
    // final DocumentReference ref =
    await databaseReference
        .collection("company_events")
        .add(eventModel.asMap());
  }

  // update
  void updateEvent(EventModel eventModel) async {
    // TODO:
  }

  // fetchone
  Future<EventModel> fetchOneEvent(String id) async {
    DocumentSnapshot _item =
        await databaseReference.document('company_events/$id').get();
    return _eventModel.fromMap(_item.data);
  }

  // fetchall
  Future<List<EventModel>> fetchAllEvent() async {
    QuerySnapshot _qSnapshot =
        await databaseReference.collection('company_events').getDocuments();

    return _qSnapshot.documents.map((documents) {
      Map<String, dynamic> _map;
      _map = documents.data;
      _map['id'] = _qSnapshot.documents[0].documentID;
      return _eventModel.fromMap(_map);
    }).toList();
  }

  // fetch by company
  Future<List<EventModel>> _fetchCompanyEventsByCompanyId(
      String companyId) async {
    DocumentReference companyRef =
        databaseReference.document('companies/$companyId');
    QuerySnapshot _qSnapshot = await databaseReference
        .collection("company_events")
        .where('company', isEqualTo: companyRef)
        .getDocuments();

    return _qSnapshot.documents.map((documents) {
      Map<String, dynamic> _map;
      _map = documents.data;
      _map['id'] = _qSnapshot.documents[0].documentID;
      return _eventModel.fromMap(_map);
    }).toList();
  }
}
