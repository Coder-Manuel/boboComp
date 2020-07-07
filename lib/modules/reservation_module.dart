import 'package:bobocomp/modals/preoder_modal.dart';
import 'package:bobocomp/modals/product_modal.dart';
import 'package:bobocomp/modals/reservation_modal.dart';
import 'package:bobocomp/modals/table_modal.dart';
import 'package:bobocomp/modals/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservationModule extends ChangeNotifier {
  // Firebase
  final databaseReference = Firestore.instance;

  List<ReservationModal> _reservations = [];
  List<ReservationModal> _currenClubReservation = [];

  // dummy data

  //////////////////////////

  // get reservations => (ClubModal res){
  //   List<ReservationModal> items = [];

  //   _reservations.forEach((item){
  //     if(item.club == res){
  //       items.add(item);
  //     }
  //   });
  //   return items;
  // };

  get reservations => _reservations = [];

  get resCount => _reservations.length;

  get currenClubReservation => (clubId) {
        fetchClubReservations(clubId);
        return _currenClubReservation;
      };

  set setCurrenClubReservation(List<ReservationModal> reserv) {
    _currenClubReservation = reserv;
    notifyListeners();
  }

  set addReservation(ReservationModal item) {
    createReservation(item);
    notifyListeners();
  }

  // id is preffered since each reservation will have a unique id/key
  set _removeResevation(int index) {
    _reservations.removeAt(index);
    notifyListeners();
  }

  get convertToReservationModal => (List<DocumentSnapshot> data) {
        return _convertToReservationModal(data);
      };

  void removeResevation(String id) async {
    DocumentReference r = await databaseReference.document('reservations/$id');
    r.delete();
  }

  void createReservation(ReservationModal reserv) {
    databaseReference
        .collection("reservations")
        .add(reserv.map)
        .then((respense) {});
  }

  void fetchClubReservations(String clubId) {
    DocumentReference clubRef = databaseReference.document('clubs/$clubId');
    Future<QuerySnapshot> ref = databaseReference
        .collection("reservations")
        .where('club', isEqualTo: clubRef)
        .getDocuments();
    ref.then((item) {
      setCurrenClubReservation = _convertToReservationModal(item.documents);
    });
  }

  List<ReservationModal> _convertToReservationModal(
      List<DocumentSnapshot> data) {
    List<ReservationModal> _reservationModals = [];

    data.forEach((item) {
      TableModal _tb = TableModal(
        label: item.data['table']['label'],
        maxNoChairs: item.data['table']['maxNoChairs'],
        minNoChairs: item.data['table']['minNoChairs'],
        reserveCostPerChair: item.data['table']['reserveCostPerChair'],
      );

      List<OderItemModal> _orderItems() {
        List<OderItemModal> _ls = [];
        item.data['preoderModal']['orderItems'].forEach((item) {
          _ls.add(OderItemModal(
            product: ProductModal(
              name: item['product']['name'],
              price: item['product']['price'],
            ),
            quantity: item['quantity'],
          ));
        });
        return _ls;
      }

      PreoderModal _pre = PreoderModal(
          id: item.data['preoderModal']['id'], orderItems: _orderItems());

      DateTime _convertToDateTime(dt) {
        return dt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(dt.seconds * 1000);
      }

      _reservationModals.add(ReservationModal(
        id: item.documentID,
        state: item.data['state'],
        user: item.data['user'],
        club: item.data['club'],
        table: _tb,
        noChairs: item.data['noChairs'],
        reserveDateTime: _convertToDateTime(item.data['reserveDateTime']),
        dateTimeBooked: _convertToDateTime(item.data['dateTimeBooked']),
        preoderModal: _pre,
      ));
    });
    return _reservationModals;
  }
}
