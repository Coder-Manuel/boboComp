import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/modals/company_models/tickets_model.dart';
import 'package:bobocomp/modules/company_modules/ticket_module.dart';
import 'package:bobocomp/ui/ticket_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MpesaTopupModal extends StatefulWidget {
  final String ticketManagerId;
  final double amount;

  MpesaTopupModal({this.ticketManagerId, this.amount});
  @override
  _MpesaTopupModalState createState() => _MpesaTopupModalState();
}

class _MpesaTopupModalState extends State<MpesaTopupModal> {
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

  @override
  Widget build(BuildContext context) {
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
            labelText: "Phone Number (from)",
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
                  FirebaseUser _user = await auth.getCurrentUser();

                  TicketModule ticketModule = TicketModule();
                  final String _ticketManagerId =
                      await ticketModule.createTicket(TicketModel(
                          userId: _user.uid,
                          ticketManager: widget.ticketManagerId));
                  bool _success = await ticketModule.payTicketMpesa(
                      widget.amount, _ticketManagerId, _phoneNoController.text);
                  setState(() {
                    _isLoading = false;
                  });

                  if (_success) {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TicketPage()));
                  }
                },
              ),
      ],
    );
  }
}
