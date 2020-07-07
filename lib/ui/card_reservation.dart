import 'package:bobocomp/components/add_reservation_ui.dart';
import 'package:bobocomp/modals/reservation_modal.dart';
import 'package:bobocomp/modules/reservation_module.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rave_flutter/rave_flutter.dart';

class CardTopupModalReservation extends StatefulWidget {
  final ReservationModal reservationModal;
  final double amount;

  const CardTopupModalReservation({this.reservationModal, this.amount});
  @override
  _CardTopupModalReservationState createState() =>
      _CardTopupModalReservationState();
}

class _CardTopupModalReservationState extends State<CardTopupModalReservation> {
  TextEditingController _cardNoController;
  TextEditingController _amountController;
  TextEditingController _walletNoController;
  TextEditingController _monthController;
  TextEditingController _yearController;
  TextEditingController _cvvController;
  TextEditingController _emailController;

  bool _cardNoNull = false;
  bool _amountNull = true;
  bool _walletNoNull = true;
  bool _monthNull = false;
  bool _yearNull = false;
  bool _emailNull = true;
  bool _cvvNull = false;

  bool _cardNoError = false;
  bool _walletNoError = false;
  bool _amountError = false;
  // bool _emailError = false;
  bool _isLoading = false;

  bool _pasetWallet = true;

  @override
  void initState() {
    super.initState();
    _cardNoController = TextEditingController();
    _amountController = TextEditingController();
    _walletNoController = TextEditingController();
    _emailController = TextEditingController();
    _monthController = TextEditingController();
    _yearController = TextEditingController();
    _cvvController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNoController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    _walletNoController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReservationModule reservationModule =
        Provider.of<ReservationModule>(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // CardNo
              TextField(
                controller: _cardNoController,
                keyboardType: TextInputType.number,
                onChanged: (_text) {
                  setState(() {
                    _cardNoNull = _text == '';
                    _cardNoError = false;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Card Number",
                  errorText: _cardNoError ? "* Invalid Card number" : null,
                ),
              ),
              // dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // month
                  Expanded(
                    child: TextField(
                        controller: _monthController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Month",
                        ),
                        onChanged: (_text) {
                          setState(() {
                            _monthNull = _text == '';
                          });
                        }),
                  ),

                  SizedBox(
                    width: 8,
                  ),

                  // year
                  Expanded(
                    child: TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Year",
                        ),
                        onChanged: (_text) {
                          setState(() {
                            _yearNull = _text == '';
                          });
                        }),
                  ),

                  SizedBox(
                    width: 8,
                  ),

                  // cvv
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "CVV",
                      ),
                      onChanged: (_text) {
                        setState(() {
                          _cvvNull = _text == '';
                        });
                      },
                    ),
                  ),
                ],
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
                      onPressed: () {
                        //
                        //startPayment();
                        //
//                      Navigator.of(context).pop();
//                      Navigator.of(context).pop();
//                      Navigator.of(context).pop();
//                      Navigator.of(context).pop();
//                      reservationModule.addReservation = widget.reservationModal;
                      },
                      child: Text(
                        '"Pay now"',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
