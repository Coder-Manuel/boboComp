import 'package:bobocomp/modals/company_models/ticket_manager_model.dart';
import 'package:bobocomp/modules/company_modules/ticket_manager_module.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TicketManagerUi extends StatefulWidget {
  TicketManagerUi({this.eventId});
  final String eventId;
  @override
  _TicketManagerUiState createState() => _TicketManagerUiState();
}

class _TicketManagerUiState extends State<TicketManagerUi> {
  TextEditingController _category;
  TextEditingController _cost;
  TextEditingController _offerCost;
  TextEditingController _ticketsAvaivable;

  @override
  void initState() {
    super.initState();
    _category = TextEditingController();
    _cost = TextEditingController();
    _offerCost = TextEditingController();
    _ticketsAvaivable = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference eventRef =
        Firestore.instance.document('company_events/${widget.eventId}');
    return ChangeNotifierProvider<TicketManagerModule>(
      builder: (context) => TicketManagerModule(),
      child: Consumer<TicketManagerModule>(
        builder: (context, _ticketManagerModule, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Tickets Manager'),
            ),
            floatingActionButton: CircleAvatar(
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          children: <Widget>[
                            TextField(
                              controller: _category,
                              decoration:
                                  InputDecoration(labelText: 'Ticket category'),
                            ),
                            TextField(
                              keyboardType: TextInputType.number,
                              controller: _cost,
                              decoration: InputDecoration(labelText: 'Cost'),
                            ),
                            TextField(
                              keyboardType: TextInputType.number,
                              controller: _offerCost,
                              decoration:
                                  InputDecoration(labelText: 'Offer Cost'),
                            ),
                            TextField(
                              keyboardType: TextInputType.number,
                              controller: _ticketsAvaivable,
                              decoration: InputDecoration(
                                  labelText: 'No of Tickets Available'),
                            ),
                            RaisedButton(
                              onPressed: () {},
                              child: Text("Expireration Date"),
                            ),
                            MaterialButton(
                              minWidth: 340,
                              color: Colors.blue,
                              child: Text("create"),
                              onPressed: () {
                                final TicketManagerModel _ticketManagerModel =
                                    TicketManagerModel(
                                        category: _category.text,
                                        cost: double.parse(_cost.text),
                                        offerCost:
                                            double.parse(_offerCost.text),
                                        ticketsAvaivable:
                                            int.parse(_ticketsAvaivable.text),
                                        event: Firestore.instance.document(
                                            'company_events/${widget.eventId}'));

                                _ticketManagerModule
                                    .createTicketManager(_ticketManagerModel);
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      });
                },
              ),
            ),
            body: StreamBuilder(
                stream: Firestore.instance
                    .collection("ticket_managers")
                    .where('event', isEqualTo: eventRef)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text('Fetching.......');
                      break;
                    case ConnectionState.none:
                      return Text('Check your connection');
                      break;
                    case ConnectionState.active:
                      TicketManagerModel _tikectMnagerModel =
                          TicketManagerModel();
                      List<TicketManagerModel> _ticketsManagers = [];
                      _ticketsManagers =
                          snapshot.data.documents.map((documents) {
                        Map<String, dynamic> _map;
                        _map = documents.data;
                        _map['id'] = snapshot.data.documents[0].documentID;
                        return _tikectMnagerModel.fromMap(_map);
                      }).toList();
                      return ListView.builder(
                        itemCount: _ticketsManagers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              title:
                                  Text(_ticketsManagers[index].cost.toString()),
                              subtitle: Text(widget.eventId),
                            ),
                          );
                        },
                      );
                      break;
                    default:
                      return Text('...');
                  }
                }),
          );
        },
      ),
    );
  }
}
