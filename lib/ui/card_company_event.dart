import 'package:bobocomp/ui/ticket_page.dart';
import 'package:flutter/material.dart';

class CardTopupModal extends StatefulWidget {
  final String ticketManagerId;
  final double amount;

  const CardTopupModal({this.ticketManagerId, this.amount});
  @override
  _CardTopupModalState createState() => _CardTopupModalState();
}

class _CardTopupModalState extends State<CardTopupModal> {
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TicketPage()));
                        // Navigator.of(context).pop();
                        // Navigator.of(context).pop();
                        // Navigator.of(context).pop();
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
