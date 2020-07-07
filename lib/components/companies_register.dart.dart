
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterCompany extends StatefulWidget {
  @override
  _RegisterCompanyState createState() => _RegisterCompanyState();
}

class _RegisterCompanyState extends State<RegisterCompany> {

  TextEditingController _companyName;
  TextEditingController _companyLocation;
  TextEditingController _companyEmail;
  TextEditingController _companyPhoneNumber;
  TextEditingController _kraPin;

  File _imageChoosen;

  @override
  void initState() {
    super.initState();
    _companyName = TextEditingController();
    _companyLocation = TextEditingController();
    _companyEmail = TextEditingController();
    _companyPhoneNumber = TextEditingController();
    _kraPin = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create company'),),    
      floatingActionButton: CircleAvatar(
        child: IconButton(
          icon: Icon(Icons.add),
          onPressed: (){
            showModalBottomSheet(
              context: context,
              builder: (context){
                return Column(
                  children: <Widget>[
                    TextField(
                      controller: _companyName,
                      decoration: InputDecoration(labelText: 'Company name'),
                    ),
                    TextField(
                      controller: _companyLocation,
                      decoration: InputDecoration(labelText: 'Company location'),
                    ),
                    TextField(
                      controller: _companyEmail,
                      decoration: InputDecoration(labelText: 'Company email'),
                    ),
                    TextField(
                      controller: _companyPhoneNumber,
                      decoration: InputDecoration(labelText: 'Company phone number'),
                    ),
                    TextField(
                      controller: _kraPin,
                      decoration: InputDecoration(labelText: 'Company certificate PIN'),
                    ),
                    
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _imageChoosen == null ? Container() : Image.file(_imageChoosen, height: 250,),
                        SizedBox(width: 10,),
                        RaisedButton(
                          onPressed: (){
                            ImagePicker.pickImage(source: ImageSource.gallery).then((value){
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
                      onPressed: (){},
                      minWidth: 340,
                      color: Colors.blue,
                      child: Text("create"),
                    )
                  ],
                );
              }
            );
          },
        ),
      ), 
      body: Container(),
    );
  }
}