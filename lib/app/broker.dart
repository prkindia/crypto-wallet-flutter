import 'dart:async';
import 'dart:convert';

import 'package:bitsbull_app/elements/cards.dart';
import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/service/service.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bitsbull_app/elements/animation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BrokerLogin extends StatefulWidget {
  @override
  _BrokerState createState() => _BrokerState();
}

class _BrokerState extends State<BrokerLogin> {

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:RobText("BitsBull - Broker"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Container(
            alignment: Alignment.center,
            height: screen.height/2 + 50,
            child: RobinCard(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset('assets/image/News_Image/CryptoBroker.jpg'),
                    Input(
                      hint: "Enter email",
                      label: "you@example.com"
                    ),
                    SizedBox(height: 10.0,),
                    Input(
                      hint: "Enter password",
                      label: "Password"
                    ),
                    SizedBox(height: 10.0,),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)
                      ),
                      child: RobText("Login To Broker Account"),
                      onPressed: (){

                      },
                      color:Colors.amber
                    )
                  ],
                )
              )
            ),
          ),
        ]
      )
    );
  }
}
