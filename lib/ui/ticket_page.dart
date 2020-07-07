import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/modals/company_models/event_model.dart';
import 'package:bobocomp/modals/company_models/ticket_manager_model.dart';
import 'package:bobocomp/modals/company_models/tickets_model.dart';
import 'package:bobocomp/modules/company_modules/event_module.dart';
import 'package:bobocomp/modules/company_modules/ticket_manager_module.dart';
import 'package:bobocomp/modules/company_modules/ticket_module.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  BaseAuth auth = Auth();
  FirebaseUser _user;
  List<TicketModel> _tickets;

  final TicketModel _ticketModel = TicketModel();

  @override
  void initState() {
    super.initState();
    auth.getCurrentUser().then((value) {
      _user = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              TicketModule().fetchAllTicket(_user == null ? null : _user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return Text('Fetching....');
            } else {
              if (snapshot.data.documents == null) {
                return Text("Empty");
              } else {
                int i = 0;
                _tickets = snapshot.data.documents.map((item) {
                  Map<String, dynamic> _map;
                  _map = item.data;
                  _map['id'] = snapshot.data.documents[i].documentID;
                  i++;
                  return _ticketModel.fromMap(_map);
                }).toList();
                return ListView.builder(
                  itemCount: _tickets.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TicketUi(ticket: _tickets[index]);
                  },
                );
              }
            }
          }),
    );
  }
}

class TicketUi extends StatefulWidget {
  TicketUi({this.ticket});

  final TicketModel ticket;

  @override
  _TicketUiState createState() => _TicketUiState();
}

class _TicketUiState extends State<TicketUi> {
  final TicketManagerModule ticketManagerModule = TicketManagerModule();
  final EventModule eventModule = EventModule();
  TicketManagerModel ticketManagerModel;
  EventModel eventModel;

  Future<TicketManagerModel> getTicketManager() async {
    return ticketManagerModule
        .fetchOneTicketManager(widget.ticket.ticketManager);
  }

  Future<EventModel> getEvent(String id) async {
    return eventModule.fetchOneEvent(id);
  }

  @override
  void initState() {
    super.initState();
    getTicketManager().then((value) {
      setState(() {
        ticketManagerModel = value;
      });
      getEvent(value.event.documentID).then((item) {
        setState(() {
          eventModel = item;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 270,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Event',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                ),
                                Text(
                                  eventModel == null ? '' : eventModel.title,
                                  // 'Event 1',
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Date',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                ),
                                Text(
                                  eventModel == null
                                      ? ''
                                      : eventModel.date.toString(),
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Time',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                ),
                                Text(
                                  eventModel == null
                                      ? ''
                                      : eventModel.date.toString(),
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Ticket class',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                ),
                                Text(
                                  ticketManagerModel == null
                                      ? ''
                                      : ticketManagerModel.category.toString(),
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'State',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                ),
                                Text(
                                  widget.ticket.state,
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: QrImage(
                data: widget.ticket.id,
                size: 180,
              ),
            )
          ],
        ),
      ),
    );
  }
}
