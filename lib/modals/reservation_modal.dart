import 'package:bobocomp/modals/preoder_modal.dart';
import 'package:bobocomp/modals/table_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservationModal {
  ReservationState state;
  final String id;
  final String user;
  final DocumentReference club;
  final TableModal table;
  final int noChairs;
  final DateTime reserveDateTime;
  final DateTime dateTimeBooked;
  final PreoderModal preoderModal;

  get key => _key();

  get tableReservationCost => noChairs * table.reserveCostPerChair;
  get preoderCost => preoderModal.totalAmount;

  get totalCost => calcTotalCost();

  get autoCompleteReservation => _autoCompleteState;
  get map => _map();

  set updateState(ReservationState stt) {
    state = stt;
  }

  ReservationModal({
    this.state = ReservationState.pending,
    this.id = '',
    @required this.user,
    @required this.club,
    @required this.table,
    this.noChairs = 1,
    @required this.reserveDateTime,
    this.dateTimeBooked,
    this.preoderModal,
  });

  double calcTotalCost() {
    double total = 0;
    total = noChairs * table.reserveCostPerChair;
    if (preoderModal != null) {
      total += preoderModal.totalAmount;
    }
    return total;
  }

  void _autoCompleteState() {
    if (state != ReservationState.cancled &&
        state != ReservationState.complete &&
        DateTime.now().isAfter(reserveDateTime)) {
      updateState = ReservationState.complete;
    }
  }

  String _key() {
    return club.documentID + user + dateTimeBooked.toString();
  }

  Map<String, dynamic> _map() {
    DocumentReference _clubRef =
        Firestore.instance.document('clubs/${club.documentID}');
    return {
      'state': state != null ? state.toString().split('.').last : null,
      'user': user,
      'club': club,
      'table': table != null ? table.map : null,
      'noChairs': noChairs,
      'reserveDateTime': reserveDateTime,
      'dateTimeBooked': dateTimeBooked,
      'preoderModal': preoderModal != null ? preoderModal.map : null,
    };
  }
}

enum ReservationState {
  pending,
  cancled,
  complete,
}
