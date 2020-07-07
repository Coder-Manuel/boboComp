import 'dart:convert';

import 'package:bobocomp/modals/company_models/tickets_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class TicketModule {
  // Firebase
  final databaseReference = Firestore.instance;
  TicketModel _ticketModel = TicketModel();

  // create
  Future<String> createTicket(TicketModel ticketModel) async {
    final DocumentReference ref =
        await databaseReference.collection("tickets").add(ticketModel.asMap());
    return ref.documentID;
  }

  // update
  void updateTicket(TicketModel ticketModel) async {
    // TODO:
  }

  // fetchone
  Future<TicketModel> fetchOneTicket(String id) async {
    DocumentSnapshot _item =
        await databaseReference.document('tickets/$id').get();
    return _ticketModel.fromMap(_item.data);
  }

  // fetchall
  Stream<QuerySnapshot> fetchAllTicket(String userId) {
    Stream<QuerySnapshot> _qSnapshot = databaseReference
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .snapshots();
    return _qSnapshot;
  }

  Future<bool> payTicketMpesa(double amount, String ref, String phoneNo) async {
    String _number = phoneNo.substring(phoneNo.length - 8);
    final _payload = {
      "walletAccountNo": "001100000001",
      "phoneNo": '2547$_number',
      "amount": amount,
      "callBackUrl": "http://18.189.117.13:2011/test",
      "referenceNumber": ref,
      "transactionDesc": "genius test"
    };
    print("sending...");

    try {
      final http.Response res = await http.post(
          'http://18.189.117.13:2011/thirdParties/mpesa/depositRequest',
          body: json.encode(_payload),
          headers: {'content-type': 'application/json'});
      if (res.statusCode == 200) {
        return true;
      } else {
        print(res.statusCode);
        print(res.body);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
