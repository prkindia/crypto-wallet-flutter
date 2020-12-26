import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

toast(String msg, { Color color }){
  Fluttertoast.showToast(
    msg: msg,
    gravity: ToastGravity.TOP,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: color != null ? color : Colors.black,
    textColor: Colors.white
  );
}