import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/modals/company_models/event_model.dart';
import 'package:bobocomp/modals/company_models/ticket_manager_model.dart';
import 'package:bobocomp/modals/company_models/tickets_model.dart';
import 'package:bobocomp/modules/company_modules/event_module.dart';
import 'package:bobocomp/modules/company_modules/ticket_manager_module.dart';
import 'package:bobocomp/modules/company_modules/ticket_module.dart';
import 'package:bobocomp/ui/card_company_event.dart';
import 'package:bobocomp/ui/mpesa_company_event.dart';
import 'package:bobocomp/ui/ticket_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompanyEventDetails extends StatefulWidget {
  final String eventId;

  CompanyEventDetails({this.eventId});

  @override
  _CompanyEventDetailsState createState() => _CompanyEventDetailsState();
}

class _CompanyEventDetailsState extends State<CompanyEventDetails> {
  BaseAuth auth = Auth();

  final EventModule _eventModule = EventModule();
  final TicketManagerModule _ticketManagerModule = TicketManagerModule();
  List<TicketManagerModel> _ticketsManagerList = [];
  EventModel _event;

  TextEditingController phoneNoController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _eventModule.fetchOneEvent(widget.eventId).then((item) {
      setState(() {
        _event = item;
      });
    });
    _ticketManagerModule
        .fetchCompanyEventsByEventId(widget.eventId)
        .then((items) {
      setState(() {
        _ticketsManagerList = items;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: _event == null
            ? Text('...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Image
                  _event.image == 'null'
                      ? Image.asset(
                          'assets/banner_1.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _event.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  // Title and Buy ticket
                  Text(
                    _event.title,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),

                  // Description
                  Text(_event.description),
                  for (TicketManagerModel ticketManager in _ticketsManagerList)
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RaisedButton(
                                      child: Text("Pay via Mpesa"),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return MpesaTopupModal(
                                                ticketManagerId:
                                                    ticketManager.id,
                                                amount: ticketManager.cost,
                                              );
                                            });
                                      },
                                    ),
                                    RaisedButton(
                                      child: Text("Pay via Card"),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return CardTopupModal(
                                                ticketManagerId:
                                                    ticketManager.id,
                                                amount: ticketManager.cost,
                                              );
                                            });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Card(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Ticket cost: ${ticketManager.cost.toString()}',
                              style: TextStyle(
                                  fontSize: 22, fontStyle: FontStyle.italic),
                            ),
                            Container(
                              height: 80,
                              width: 60,
                              color: Colors.blue,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
