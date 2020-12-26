import 'dart:async';
import 'dart:convert';

import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/elements/cards.dart';
import 'package:bitsbull_app/service/service.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'deposit.dart';
import 'portfolio.dart';
import 'broker.dart';
import 'settings.dart';

class MainBitsBull extends StatefulWidget {
  @override
  _BitsBullState createState() => _BitsBullState();
}

class _BitsBullState extends State<MainBitsBull>{
  int currPage = 0;

  PageController pageController = PageController(initialPage: 0);

  List<Widget> childrens = [
    FirstScreen(),
    DepositBull(),
    WithdrawBull(),
    BrokerLogin(),
    SettingsBull(),
  ];

  @override
  Widget build(BuildContext context){
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromRGBO(78, 2, 251, 1),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(78, 2, 251, 1), Color.fromRGBO(94,47,199, 1)]
          )
        ),
        height: screen.height,
        width: screen.width,
        child: Stack(
          children:[
            IndexedStack(
              index: currPage,
              children: childrens,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 5,
              child: bottomNavigationBar,
            ),
          ]
        )
      )
    );
  }

  updatePage(int index){
    setState(() {
      currPage = index;
      // pageController.animateToPage(index,duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  @override
  void dispose(){
    pageController?.dispose();
    super.dispose();
  }

  Widget get bottomNavigationBar {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(40),
        topLeft: Radius.circular(40),
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(94,47,199, 1),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        showUnselectedLabels: false,
        currentIndex: currPage,
        onTap: updatePage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
            activeIcon: Icon(Icons.home_filled)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: "Wallet",
            activeIcon: Icon(Icons.account_balance_wallet)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            label: "Portfolio",
            activeIcon: Icon(Icons.account_balance_sharp)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login_outlined),
            label: "Broker",
            activeIcon: Icon(Icons.login)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
            activeIcon: Icon(Icons.settings)
          )
        ],
      ),
    );
  }
}



class FirstScreen extends StatefulWidget{
  @override
  _First createState() => _First();
}

class _First extends State<FirstScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List currencies;
  List<Widget> cryptoWidget;
  Timer fetchTimer;
  String totalValue = "0.00";

  getCurrencies() async {
    try{
      Response btcResp = await Dio().get(bitsUrl+'?topList=20');
      var user = await getSaved(key:'bbull_user');
      Response btcResp2 = await Dio().get(bitsUrl+'?getCurr=3&mem_eid='+jsonDecode(user)['email']);
      if(btcResp2.data['total'] != null){
        setState(() {
          totalValue = double.parse(btcResp2.data['total'].toString()).toStringAsFixed(2);
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
  void initState() {
    init();
    super.initState();
  }

  init() async {
    var list = await getCurrencies();
    if(list != null && list.length > 0){
      List<Widget> dispList = [];
      for(var crypto in list){
        // print(crypto);
        Widget dispC = MainRobinCard(asset:crypto);
        dispList.add(dispC);
      }
      setState((){
        cryptoWidget = dispList;
      });
    }
    setState(() {
      fetchTimer = Timer.periodic(Duration(seconds:50), (timy) async {
        var list = await getCurrencies();
        if(list != null && list.length > 0){
          List<Widget> dispList = [];
          for(var crypto in list){
            // print(crypto);
            Widget dispC = MainRobinCard(asset:crypto);
            dispList.add(dispC);
          }
          setState((){
            cryptoWidget = dispList;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    fetchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:RobText("Crypto - Wallet"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                width: screen.width/2,
                decoration:BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end:Alignment.bottomRight,
                    colors: [Color.fromRGBO(94,47,199, .1), Color.fromRGBO(94,47,199, 1)]
                  )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RobText(
                      "Portfolio",
                      style: TextStyle(color: Colors.white, fontSize: 20.0)
                    ),
                    SizedBox(height:10.0),
                    RobText(
                      "\$ "+totalValue,
                      style: TextStyle(color: Colors.white, fontSize: 26.0)
                    )
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 68,
            left: 0,
            right: 0,
            child: Container(
              width: screen.width,
              height: 200.0,
              padding: EdgeInsets.only(bottom: 15.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color.fromRGBO(94,47,199, .3)]
                ),
                borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20.0), bottomRight: Radius.circular(20.0))
              ),
              child: cryptoWidget == null ? Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child:LinearProgressIndicator(backgroundColor: Colors.white.withOpacity(.7), valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(94,47,199, .3)),)
                  )
                ],
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(right:15.0, left:15.0),
                      scrollDirection: Axis.horizontal,
                      children:  cryptoWidget
                    )
                  )
                ]
              ),
            ),
          ),
          Positioned(
            top:150,
            child: Container(
              width: screen.width,
              child:SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/image/logo.png', width: 40.0,),
                      ]
                    ),
                    SizedBox(height:20.0),
                    RobText("10,000,000", style:TextStyle(fontSize: 42.0, color:Colors.white))
                  ],
                )
              )
            )
          ),
        ],
      ),
    );
  }
}




