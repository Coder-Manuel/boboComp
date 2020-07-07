import 'dart:io';

import 'package:bobocomp/helper/date_picker.dart';
import 'package:bobocomp/modals/company_models/event_model.dart';
import 'package:bobocomp/modules/company_modules/event_module.dart';
import 'package:bobocomp/modules/event_module.dart' as ev;
import 'package:bobocomp/ui/tickets_manager_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EventUi extends StatefulWidget {
  EventUi({this.companyId});
  final String companyId;
  @override
  _EventUiState createState() => _EventUiState();
}

class _EventUiState extends State<EventUi> {
  TextEditingController _title;
  TextEditingController _description;
  List<EventModel> _companyEvents = [];
  DateTime _companyEentDate;

  File _imageChoosen;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _description = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference companyRef =
        Firestore.instance.document('companies/${widget.companyId}');
    return ChangeNotifierProvider<EventModule>(
      builder: (context) => EventModule(),
      child: Consumer<EventModule>(
        builder: (context, _eventMoule, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Events'),
            ),
            floatingActionButton: CircleAvatar(
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: _title,
                              decoration: InputDecoration(labelText: 'Title'),
                            ),
                            TextField(
                              maxLines: 5,
                              minLines: 2,
                              controller: _description,
                              decoration: InputDecoration(
                                labelText: 'Description',
                              ),
                            ),
                            CustomDatePicker(
                              callback: (_dateTime) {
                                _companyEentDate = _dateTime;
                              },
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _imageChoosen == null
                                    ? Container()
                                    : Image.file(
                                        _imageChoosen,
                                        height: 250,
                                      ),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    ImagePicker.pickImage(
                                            source: ImageSource.gallery)
                                        .then((value) {
                                      setState(() {
                                        _imageChoosen = value;
                                      });
                                    });
                                  },
                                  child: Text("Pick image"),
                                ),
                              ],
                            ),
                            ChangeNotifierProvider.value(
                              value: ev.EventModule(),
                              child: Consumer<ev.EventModule>(
                                  builder: (context, eventModule, _) {
                                return MaterialButton(
                                  minWidth: 340,
                                  color: Colors.blue,
                                  child: Text("create"),
                                  onPressed: () {
                                    // upload image first
                                    eventModule
                                        .uploadImage(_imageChoosen)
                                        .then((url) {
                                      final EventModel _eventModel = EventModel(
                                          title: _title.text,
                                          description: _description.text,
                                          company: Firestore.instance.document(
                                              'companies/${widget.companyId}'),
                                          image: url,
                                          date: _companyEentDate);
                                      _eventMoule.createEvent(_eventModel);
                                    });

                                    Navigator.pop(context);
                                  },
                                );
                              }),
                            )
                          ],
                        );
                      });
                },
              ),
            ),
            body: StreamBuilder(
                stream: Firestore.instance
                    .collection("company_events")
                    .where('company', isEqualTo: companyRef)
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
                      EventModel _eventModel = EventModel();

                      if (snapshot.data.documents == null) {
                        return Text("empty");
                      }
                      _companyEvents = [];
                      int i = 0;
                      _companyEvents = snapshot.data.documents.map((documents) {
                        Map<String, dynamic> _map;
                        _map = documents.data;
                        _map['id'] = snapshot.data.documents[i].documentID;
                        i++;
                        return _eventModel.fromMap(_map);
                      }).toList();
                      return ListView.builder(
                        itemCount: _companyEvents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              title: Text(_companyEvents[index].title),
                              subtitle: Image.network(
                                _companyEvents[index].image,
                                height: 200,
                                fit: BoxFit.fitWidth,
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => TicketManagerUi(
                                        eventId: _companyEvents[index].id)));
                              },
                            ),
                          );
                        },
                      );

                      //  return Text(".d.d");
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
