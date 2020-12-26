import 'dart:async';

import 'package:bitsbull_app/elements/cards.dart';
import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/service/service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DepositBull extends StatefulWidget {
  @override
  _DepositBullState createState() => _DepositBullState();
}

class _DepositBullState extends State<DepositBull> {

  List currencies;
  List<Widget> cryptoWidget;
  Timer fetchTimer;

  getCurrencies() async {
    try{
      Response btcResp = await Dio().get(bitsUrl+'?getCurrDepo=3');
      return btcResp.data['data'];
    }
    catch(err){
      print(err);
      return [];
    }
  }

  @override
  void initState(){
    init();
    super.initState();
  }

  init() async {
    var list = await getCurrencies();
    if(list != null && list.length > 0){
      List<Widget> dispList = [];
      for(var crypto in list){
        if(crypto['custom'] == null) {
          Widget dispC = DepositRobinCard(asset: crypto);
          dispList.add(dispC);
        }
        else{
          Widget dispC = DepositRobinCard(asset: crypto, isCustom:true);
          dispList.add(dispC);
        }
      }
      setState((){
        cryptoWidget = dispList;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:RobText("BitsBull - Deposit"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: cryptoWidget != null ? cryptoWidget : [
                  LinearProgressIndicator(backgroundColor: Colors.white.withOpacity(.5), valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(.3)),)
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}
