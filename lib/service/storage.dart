import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

String currVers = '1.0.7';
String BUSER = 'bbull_user';
String FINGER = 'FINGER_DATA';
String PIN = 'PIN_DATA';

Future<SharedPreferences> shared() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
}
Future<bool> isLogged() async {
  var prefs = await shared();
  return prefs.getString('bbull_user') != null;
}

Future<void> saveLog({var data}) async {
  var prefs = await shared();
  prefs.setString('bbull_user', jsonEncode(data));
}

Future<String> getSaved({var key}) async {
  var prefs = await shared();
  return prefs.getString(key);
}

Future<void> save({var key, var data}) async {
  var prefs = await shared();
  prefs.setString(key, data);
}

clear() async {
  var prefs = await shared();
  prefs.clear();
}

clearKey(String key) async {
  var prefs = await shared();
  prefs.remove(key);
}


showLoading(BuildContext context, var msg){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return Dialog(
        child: Container(
          // width: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              RefreshProgressIndicator(),
              SizedBox(width:20.0),
              Text(msg!=null?msg:'', style: GoogleFonts.ptSans())
            ]
          )
        )
      );
    }
  );
}
cancel(BuildContext context){
  Navigator.of(context).pop();
}
