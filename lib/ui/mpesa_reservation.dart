import 'dart:async';

import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/components/add_reservation_ui.dart';
import 'package:bobocomp/modals/reservation_modal.dart';
import 'package:bobocomp/modules/company_modules/ticket_module.dart';
import 'package:bobocomp/modules/reservation_module.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mpesa/mpesa.dart';
import 'package:rich_alert/rich_alert.dart';

class MpesaTopupModalReservation extends StatefulWidget {
  final ReservationModal reservationModal;

  MpesaTopupModalReservation({this.reservationModal});
  @override
  _MpesaTopupModalReservationState createState() =>
      _MpesaTopupModalReservationState();
}

class _MpesaTopupModalReservationState
    extends State<MpesaTopupModalReservation> {
  BaseAuth auth = Auth();

  TextEditingController _phoneNoController;
  TextEditingController _amountController;
  TextEditingController _walletNoController;

  bool _phoneNoNull = true;
  bool _amountNull = true;
  bool _walletNoNull = true;

  bool _phoneNoError = false;
  bool _walletNoError = false;
  bool _amountError = false;
  bool _isLoading = false;
  bool _pasetNo = true;
  bool _pasetWallet = true;

  String checkoutIds = '';
  int _itemCount = 0;
  int total = 0;
  int period = 0;
  int amount = 174379;
  int number = 0;

  @override
  void initState() {
    super.initState();
    _phoneNoController = TextEditingController();
    _amountController = TextEditingController();
    _walletNoController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneNoController.dispose();
    _amountController.dispose();
    _walletNoController.dispose();
    super.dispose();
  }

  Mpesa mpesa = Mpesa(
      clientKey: "rs7A88SbpKEpnbuO3c5s32YX4Pom7hzn",
      clientSecret: "DjIVZCC9jQlhksZG",
      environment: "sandbox",
      initiatorPassword:
          "VeBVN1Fl987cBSW0+Mj3HAIJ1hacsTpum/W4Do1NpKcGro7TsxiMgP1FNXfwkT7AS4Kx0VLxYC6OrhMc4EXDrX/EqzSq41Puom7CRF2DqPOgJanOwnUioOA9hdaZCPKPOc8WYoJ/zEgM2mHJDyUgFwuj69gk/UNdFmc48R0yvIwbGA5E4fbe9KzeEr2mAWdOsBUFLE7sLmkHBVPja0Q1Y/ltuLICmbPqG2/Mdgc0t3ygtwbwmmmwrqBaW8g17wJzfZRedtEbyLAHPJ+SEkBAP3T1I3N9wWlloQbweBM86lvIBUjzqne1kjwlQEYixQuPiix0jXbPF+JZGovmAo45EQ==",
      passKey:
          "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919");

  void getsuccess(String checkout) async {
    await Firestore.instance
        .collection('mpesa')
        .where('checkoutId', isEqualTo: checkout)
        .snapshots()
        .listen((datas) {
      if (datas.documents.length != 0) {
        print(datas);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                  alertTitle: richTitle("Transaction Successful"),
                  alertSubtitle:
                      richSubtitle("Your mpesa transaction was succesful"),
                  alertType: RichAlertType.SUCCESS);
            });
        //  succes = 1;

      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                  alertTitle: richTitle("Transaction Failed"),
                  alertSubtitle:
                      richSubtitle("Mpesa transaction wasn't completed"),
                  alertType: RichAlertType.ERROR);
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReservationModule reservationModule =
        Provider.of<ReservationModule>(context);

    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisSize: MainAxisSize.min,

      children: <Widget>[
        // PhoneNo
        TextField(
          controller: _phoneNoController,
          keyboardType: TextInputType.number,
          onChanged: (_text) {
            setState(() {
              _phoneNoNull = _text == '';
              _phoneNoError = false;
            });
          },
          decoration: InputDecoration(
            labelText: "Phone Number",
            errorText: _phoneNoError ? "* Invalid Phone number" : null,
          ),
        ),
        // // Amount
        // TextField(
        //   controller: _amountController,
        //   keyboardType: TextInputType.number,
        //   onChanged: (_text){
        //     setState(() {
        //       _amountNull = _text == '';
        //       _amountError = false;
        //     });
        //   },
        //   decoration: InputDecoration(
        //     labelText: "Amount",
        //     errorText: _amountError ? "* Amount less than required" : null,
        //   ),
        // ),
        SizedBox(
          height: 8,
        ),
        _isLoading
            ? CircularProgressIndicator()
            : RaisedButton(
                child: Text('"Pay now"'),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  reservationModule.addReservation = widget.reservationModal;
                  TicketModule ticketModule = TicketModule();
                  bool _success = await ticketModule.payTicketMpesa(
                      widget.reservationModal.totalCost,
                      null,
                      _phoneNoController.text);
                  setState(() {
                    _isLoading = false;
                  });
                  //mpesa
                  mpesa
                      .lipaNaMpesa(
                          // static phonenumber for testing
                          phoneNumber: "254708108472",
                          amount: double.parse(
                              widget.reservationModal.totalCost.toString()),
                          transactionDescription: "Nest",
                          businessShortCode: amount.toString(),
                          callbackUrl:
                              "https://us-central1-maptest-4e1e0.cloudfunctions.net/custommpesa")
                      .then((result) {
                    print(result['CheckoutRequestID']);
                    checkoutIds = result['CheckoutRequestID'].toString();
                    Timer(Duration(seconds: 20), () {
                      getsuccess(checkoutIds);
                    });
                    final DocumentReference documentReference = Firestore
                        .instance
                        .collection("receipts_for_Mpesa")
                        .document();
                    Map<String, dynamic> data = <String, dynamic>{
                      'transaction': 'Mpesa',
                      'Amount': (widget.reservationModal.totalCost.toString()),
                      'Serial no.': result['CheckoutRequestID'],
                    };
                    documentReference.setData(data).whenComplete(() async {
                      await print("Document Added");
                    }).catchError((e) {
                      print(e);
                    });
                    if (_success) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  }).catchError((error) {
                    if (_success) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                    print(error.toString());
                  });
                },
              ),
      ],
    );
  }
}
