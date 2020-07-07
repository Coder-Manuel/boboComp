import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime initialDate;
  final DateTime lastDate;
  final Function callback;
  CustomDatePicker({
    this.firstDate,
    this.initialDate,
    this.lastDate,
    this.callback,
  });
  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _reservationDateTime;


  void _datePicker() async{
  DateTime dateValue = await showDatePicker(
      context: context,
      firstDate: widget.firstDate == null ? DateTime.now() : widget.firstDate,
      initialDate: widget.initialDate == null ? DateTime.now() : widget.initialDate,
      lastDate: widget.lastDate == null ? DateTime(DateTime.now().year, DateTime.now().month+6) : widget.lastDate,
    );
    TimeOfDay timeValue = TimeOfDay.now();
    if (dateValue != null){
      timeValue = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
      );
    }
      
    setState(() {
      if (dateValue != null && timeValue != null){
        _reservationDateTime= DateTime(
            dateValue.year,
            dateValue.month,
            dateValue.day,
            timeValue.hour,
            timeValue.minute,
        );
        widget.callback(_reservationDateTime);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  _reservationDateTime != null ? 
    Row(
      children: <Widget>[
        Text(
          _reservationDateTime.year.toString() + '/' + _reservationDateTime.month.toString() +'/' + _reservationDateTime.day.toString() + ' -- ' +
          _reservationDateTime.hour.toString() + ':' + _reservationDateTime.minute.toString() ,
          style: TextStyle(color: Colors.blue, fontSize: 19),
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.redAccent, size: 20,),
          onPressed: _datePicker,
        ),
      ],
    )
    :
    RaisedButton(
      color: Colors.white,
      child: Text(
        'Pick date and time',
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: _datePicker,
    );
  }
}