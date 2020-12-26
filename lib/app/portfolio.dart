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

class WithdrawBull extends StatefulWidget {
  @override
  _WithdrawBullState createState() => _WithdrawBullState();
}

class _WithdrawBullState extends State<WithdrawBull> {

  List currencies;
  List<Widget> cryptoWidget;
  Timer fetchTimer;
  String totalValue = "0.00";

  RefreshController refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    print("refreshing");
    await init();
    await Future.delayed(Duration(milliseconds: 1000));
    refreshController.refreshCompleted();
  }

  getCurrencies() async {
    try{
      var user = await getSaved(key:"bbull_user");
      Response btcResp = await Dio().get(bitsUrl+'?getCurr=3&mem_eid='+jsonDecode(user)['email']);
      print(btcResp.data);
      if(btcResp.data['total'] != null){
        setState(() {
          totalValue = double.parse(btcResp.data['total'].toString()).toStringAsFixed(2);
        });
      }
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
          Widget dispC = PortFolioCard(asset: crypto);
          dispList.add(dispC);
        }
        else{
          Widget dispC = PortFolioCard(asset: crypto, isCustom: true,);
          dispList.add(dispC);
        }
      }
      setState((){
        cryptoWidget = dispList;
      });
    }
    else{
      setState(() {
        cryptoWidget = [
          Container(
            padding: EdgeInsets.all(16.0),
            child: RobText("No holdings for your account!", style: TextStyle(color: Colors.white))
          )
        ];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    Size size = new Size(MediaQuery.of(context).size.width, 200.0);
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   title:RobText("BitsBull - Portfolio"),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      // ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        waveBody(size: size, xOffset: 0, yOffset: 0, color: Colors.red, totalValue: totalValue,),
                        Opacity(
                          opacity: 0.9,
                          child: new waveBody(
                            size: size,
                            xOffset: 60,
                            yOffset: 10,
                            totalValue: totalValue,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: false,
                        controller: refreshController,
                        header: WaterDropHeader(
                          waterDropColor: Colors.white,
                        ),
                        onRefresh: _onRefresh,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                         child: Column(
                            children: cryptoWidget != null ? cryptoWidget : [
                              Container(
                                padding: EdgeInsets.all(16.0),
                                child:RobText("Loading holdings ...", style: TextStyle(color:Colors.white))
                              )
                            ],
                          )
                        )
                      )
                    )
                  ],
                )
            ),
          )
        ],
      ),
    );
  }
}
