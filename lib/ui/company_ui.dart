import 'dart:io';

import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/modals/company_models/company_model.dart';
import 'package:bobocomp/modules/company_modules/company_module.dart';
import 'package:bobocomp/modules/event_module.dart' as ev;
import 'package:bobocomp/ui/events_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';

class CompanyUi extends StatefulWidget {
  @override
  _CompanyUiState createState() => _CompanyUiState();
}

class _CompanyUiState extends State<CompanyUi> {
  TextEditingController _companyName;
  TextEditingController _companyLocation;
  TextEditingController _companyEmail;
  TextEditingController _companyPhoneNumber;
  TextEditingController _kraPin;
  TextEditingController _paybill;
  String _userId;

  File _imageChoosen;

  @override
  void initState() {
    super.initState();
    _companyName = TextEditingController();
    _companyLocation = TextEditingController();
    _companyEmail = TextEditingController();
    _companyPhoneNumber = TextEditingController();
    _kraPin = TextEditingController();
    _paybill = TextEditingController();
  }

  @override
  void dispose() {
    _companyName.dispose();
    _companyLocation.dispose();
    _companyEmail.dispose();
    _companyPhoneNumber.dispose();
    _kraPin.dispose();
    _paybill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseAuth auth = Auth();
    auth.getCurrentUser().then((userId) {
      setState(() {
        _userId = userId.uid.toString();
      });
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CompanyModule>(
          builder: (_) => CompanyModule(),
        ),
        ChangeNotifierProvider<ev.EventModule>(
          builder: (_) => ev.EventModule(),
        )
      ],
      child: Consumer<CompanyModule>(
        builder: (context, _companyModule, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Company'),
            ),
            floatingActionButton:
                Consumer<ev.EventModule>(builder: (context, _eventModule, _) {
              return CircleAvatar(
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                TextField(
                                  controller: _companyName,
                                  decoration: InputDecoration(
                                      labelText: 'Company name'),
                                ),
                                TextField(
                                  controller: _companyLocation,
                                  decoration: InputDecoration(
                                      labelText: 'Company location'),
                                ),
                                TextField(
                                  controller: _companyEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      labelText: 'Company email'),
                                ),
                                TextField(
                                  controller: _companyPhoneNumber,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      labelText: 'Company phone number'),
                                ),
                                TextField(
                                  controller: _kraPin,
                                  decoration: InputDecoration(
                                      labelText: 'Company certificate PIN'),
                                ),
                                TextField(
                                  controller: _paybill,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'Mpesa paybill'),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    _imageChoosen == null
                                        ? Container()
                                        : Image.file(
                                            _imageChoosen,
                                            height: 150,
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
                                      child: Text("Company certificate"),
                                    ),
                                  ],
                                ),
                                MaterialButton(
                                  minWidth: 340,
                                  color: Colors.blue,
                                  child: Text("create"),
                                  onPressed: () {
                                    _eventModule
                                        .uploadImage(_imageChoosen)
                                        .then((url) {
                                      final CompanyModel _companyModel =
                                          CompanyModel(
                                              companyName: _companyName.text,
                                              companyEmail: _companyEmail.text,
                                              companyPhoneNumber:
                                                  _companyPhoneNumber.text,
                                              companyLocation:
                                                  _companyLocation.text,
                                              companyCertificate: url,
                                              kraPin: _kraPin.text,
                                              paybill: _paybill.text,
                                              users: [_userId]);

                                      _companyModule
                                          .createCompany(_companyModel);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                          );
                        });
                  },
                ),
              );
            }),
            body: StreamBuilder(
                stream: Firestore.instance
                    .collection('companies')
                    .where('users', arrayContains: _userId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  switch (snapshot.connectionState) {
                    // case ConnectionState.waiting:
                    //   return Text('Fetching.......');
                    //   break;
                    case ConnectionState.none:
                      return Text('Check your connection');
                      break;
                    default:
                      if (snapshot.data == null) {
                        return Text('Fetching.......');
                      }

                      CompanyModel _companyModel = CompanyModel();
                      int i = 0;
                      List<CompanyModel> _companies =
                          snapshot.data.documents.map((documents) {
                        Map<String, dynamic> _map;
                        _map = documents.data;
                        _map['id'] = snapshot.data.documents[i].documentID;
                        i++;
                        return _companyModel.fromMap(_map);
                      }).toList();

                      return ListView.builder(
                        itemCount: _companies.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              title: Text(_companies[index].companyName),
                              subtitle: Text(_companies[index].status),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => EventUi(
                                        companyId: _companies[index].id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                  }
                }),
          );
        },
      ),
    );
  }
}
