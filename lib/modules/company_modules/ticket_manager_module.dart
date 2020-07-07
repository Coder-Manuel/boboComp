import 'package:bobocomp/modals/company_models/ticket_manager_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TicketManagerModule with ChangeNotifier {
  List<TicketManagerModel> _ticketManagers = [];

  set setTicketManagers(List<TicketManagerModel> _items) {
    _ticketManagers = _items;
    notifyListeners();
  }

  set addTicketManager(TicketManagerModel _item) {
    _ticketManagers.add(_item);
    notifyListeners();
  }

  List<TicketManagerModel> get ticketManagers => _ticketManagers;

  void get fetchTicketManagers async {
    List<TicketManagerModel> _items = await fetchAllTicketManager();
    setTicketManagers = _items;
  }

  void getfetchCompanyEventsByEventId(String eventId) async {
    List<TicketManagerModel> _items =
        await fetchCompanyEventsByEventId(eventId);
    setTicketManagers = _items;
  }

  // Firebase
  final databaseReference = Firestore.instance;
  TicketManagerModel _ticketManagerModel = TicketManagerModel();

  // create
  void createTicketManager(TicketManagerModel ticketManagerModel) async {
    // final DocumentReference ref =
    await databaseReference
        .collection("ticket_managers")
        .add(ticketManagerModel.asMap());
  }

  // update
  void updateTicketManager(TicketManagerModel ticketManagerModel) async {
    // TODO:
  }

  // fetchone
  Future<TicketManagerModel> fetchOneTicketManager(String id) async {
    DocumentSnapshot _item =
        await databaseReference.document('ticket_managers/$id').get();
    return _ticketManagerModel.fromMap(_item.data);
  }

  // fetchall
  Future<List<TicketManagerModel>> fetchAllTicketManager() async {
    QuerySnapshot _qSnapshot =
        await databaseReference.collection('ticket_managers').getDocuments();
    return _qSnapshot.documents.map((documents) {
      Map<String, dynamic> _map;
      _map = documents.data;
      _map['id'] = _qSnapshot.documents[0].documentID;
      return _ticketManagerModel.fromMap(_map);
    }).toList();
  }

  // fetch by company event
  Future<List<TicketManagerModel>> fetchCompanyEventsByEventId(
      String eventId) async {
    DocumentReference eventRef =
        databaseReference.document('company_events/$eventId');
    QuerySnapshot _qSnapshot = await databaseReference
        .collection("ticket_managers")
        .where('event', isEqualTo: eventRef)
        .getDocuments();
    return _qSnapshot.documents.map((documents) {
      Map<String, dynamic> _map;
      _map = documents.data;
      _map['id'] = _qSnapshot.documents[0].documentID;
      return _ticketManagerModel.fromMap(_map);
    }).toList();
  }
}
