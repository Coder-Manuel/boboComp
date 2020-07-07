

import 'package:cloud_firestore/cloud_firestore.dart';

class TicketManagerModel{
  final String id;
  final String category;
  final DocumentReference event;
  final double cost;
  final double offerCost;
  final int ticketsAvaivable;
  final DateTime expireryDate;
  final DateTime dateCreated;

  TicketManagerModel({
    this.id = '',
    this.category,
    this.event,
    this.cost,
    this.offerCost,
    this.ticketsAvaivable = 10000,
    this.dateCreated,
    this.expireryDate
  });

  Map<String, dynamic> asMap(){
    return{
      'category': category,
      'event': event,
      'cost': cost,
      'offerCost': offerCost,
      'ticketsAvaivable': ticketsAvaivable,
      'dateCreated': dateCreated,
      'expireryDate': expireryDate,
    };
  }

  TicketManagerModel fromMap(Map<String, dynamic> obj){
    return obj == null ?
    null :
    TicketManagerModel(
      id: obj['id'],
      category: obj['category'],
      event: obj['event'],
      cost: obj['cost'],
      offerCost: obj['offerCost'],
      ticketsAvaivable: obj['ticketsAvaivable'],
      dateCreated: null, // TODO
      expireryDate: null, // TODO
    );
  }
}