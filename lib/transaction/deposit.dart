import 'dart:async';
import 'dart:convert';

import 'package:bitsbull_app/elements/cards.dart';
import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/producers/producers.dart';
import 'package:bitsbull_app/service/service.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RobinDeposit extends StatefulWidget {
  var asset;
  bool isCustom;
  RobinDeposit({this.asset, this.isCustom});
  @override
  _DepoRobinState createState() => _DepoRobinState();
}

class _DepoRobinState extends State<RobinDeposit> {

  bool isProcessed = false;
  double total = 0.00;

  bool transCreated = false;

  String statUrl = "";
  String status =  "";
  String cryptoCust = "BTC";
  String inpL = "";
  bool isCustom = false;
  String imgAddr;


  Timer statTimer;

  @override
  void initState(){
    init();
    super.initState();
  }

  init() async {
    setState(() {
      isCustom = widget.isCustom;
    });
  }

  deposit({var amt, var crypto}) async {
    if(isCustom){
      var user = await getSaved(key:'bbull_user');
      var email = jsonDecode(user)['email'];

      setState(() {
        isProcessed = true;
        status = "Creating transaction...";
      });
      var resp = await postMe(url:'payment.php', data: {'data':{'amount': amt, 'deposit_currency': cryptoCust, 'email':email}, 'makePayment': true});
      print(resp.data);
      setState(() {
        status = "Transaction created successfully";
        if(resp.data['error'] != 'ok'){
          toast(resp.data['error']);
          setState(() {
            status = "Transaction creation failed!";
            isProcessed = false;
            transCreated = false;
          });
        }
        else{
          toast("Transaction created..");
          imgAddr = resp.data['result']['qrcode_url'];
          statUrl = resp.data['result']['checkout_url'];
          transCreated = true;
          statTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
            var respStat = await postMe(url:'payment.php', data:{'data':{'txn_id':resp.data['result']['txn_id']}, 'getInfo':true});
            print(respStat.data);
            if(respStat.data['error'] != 'ok'){
              toast(respStat.data['error']);
              timer.cancel();
            }
          });
          Timer(Duration(seconds: 5), (){
            setState(() {
              status = "Awaiting payment confirmation....";
            });
          });
        }
      });
      return;
    }
    setState(() {
      isProcessed = true;
      status = "Creating transaction...";
    });
    var user = await getSaved(key:'bbull_user');
    var email = jsonDecode(user)['email'];

    var resp = await postMe(url:'payment.php', data: {'data':{'amount': amt, 'deposit_currency': crypto, 'email':email}, 'makePayment': true});
    print(resp.data);
    setState(() {
      status = "Transaction created successfully";
      if(resp.data['error'] != 'ok'){
        toast(resp.data['error']);
        setState(() {
          status = "Transaction creation failed!";
          isProcessed = false;
          transCreated = false;
        });
      }
      else{
        toast("Transaction created..");
        imgAddr = resp.data['result']['qrcode_url'];
        statUrl = resp.data['result']['checkout_url'];
        transCreated = true;
        statTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
          var respStat = await postMe(url:'payment.php', data:{'data':{'txn_id':resp.data['result']['txn_id']}, 'getInfo':true});
          print(respStat.data);
          if(respStat.data['error'] != 'ok'){
            toast(respStat.data['error']);
            timer.cancel();
          }
        });
        Timer(Duration(seconds: 5), (){
          setState(() {
            status = "Awaiting payment confirmation....";
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title:RobText("Deposit - "+(isCustom ? widget.asset['name'] : widget.asset['symbol'])),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromRGBO(78, 2, 251, 1), Color.fromRGBO(94,47,199, 1)]
          )
        ),
        padding: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child:Column(
          // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SizedBox(height: 80.0,),
              Image.network(
                isCustom ? baseUrl+"coins/"+widget.asset['symbol']+".png"
                :"https://s2.coinmarketcap.com/static/img/coins/128x128/"+widget.asset['id'].toString()+".png",
                width: 80.0,
              ),
              SizedBox(height: 30.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: isProcessed ? 0.0 : 7.0, left: isProcessed ? 12.0 : 0.0),
                    child: !isProcessed ? RobText(
                        "Deposit ( "+widget.asset['name']+" )",
                      style: TextStyle(color: Colors.white)
                    ) : Text.rich(
                      TextSpan(
                        style: Common(
                          style: TextStyle(color: Colors.white)
                        ),
                        children: [
                          TextSpan(text:"Depositing "),
                          TextSpan(text: inpL, style: Common(
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                          )),
                          TextSpan(
                            text: " "+widget.asset['symbol'],
                          )
                        ]
                      )
                    ),
                  ),
                  SizedBox(width: 15.0,),
                  !isProcessed ? Expanded(
                    child: Input(
                      hint: "No. Of Coins",
                      // label: "Coins",
                        input: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color:Colors.white70),
                      labelStyle: TextStyle(color:Colors.white54),
                      onChanged: (inp){
                        var val = widget.asset['quote']['USD']['price'];
                        double finVal = double.parse(val.toString());
                        double outp = finVal * double.parse(inp.toString());
                        setState(() {
                          total = outp;
                          inpL = inp;
                        });
                      }
                    ),
                  ) : SizedBox()
                ],
              ),
              SizedBox(height: 20.0,),
              RobText(
                "Amount : \$ "+total.toStringAsFixed(2),
                style: TextStyle(color: Colors.white)
              ),
              SizedBox(height: 20.0,),
              isCustom ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RobText(
                    "Choose Crypto",
                    style: TextStyle(
                      color: Colors.white
                    )
                  ),
                  DropdownButton(
                    style: Common(style: TextStyle(backgroundColor: Colors.white, letterSpacing: 1.0)),
                    value: cryptoCust,
                    items: [
                      DropdownMenuItem(
                        child: RobText("BTC", style: TextStyle(color: Colors.black)),
                        value: "BTC",
                      ),
                      DropdownMenuItem(
                        child: RobText("ETH", style: TextStyle(color: Colors.black)),
                        value: "ETH",
                      ),
                      DropdownMenuItem(
                        child: RobText("TRX", style: TextStyle(color: Colors.black)),
                        value: "TRX",
                      )
                    ],
                    onChanged: (val){
                      print(val);
                      setState(() {
                        cryptoCust = val;
                      });
                    },
                  )
                ],
              ) : SizedBox(),
              SizedBox(height: 20.0,),
              FlatButton.icon(
                icon: Icon(isProcessed ? Icons.hourglass_top_rounded : Icons.upload_rounded),
                label: isProcessed ? SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(backgroundColor: Colors.amber,)
                ) : RobText("Deposit"),
                shape: Round(radii: 10.0),
                disabledColor: Colors.white60,
                color: Colors.blue[100],
                onPressed: isProcessed ? null : () async {
                  await deposit(amt:total, crypto: widget.asset['symbol']);
                },
              ),
              !isProcessed ? SizedBox() : RobText(
                "Status : " + status,
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.white
                )
              ),
              SizedBox(height: 30.0,),
              transCreated ?
                Image.network(imgAddr)
                :SizedBox(),
              transCreated ?
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child:RobText("Scan this image with your crypto wallet to deposit",
                  style: TextStyle(fontSize: 10.0, color:Colors.white70),))
              : SizedBox(),
              transCreated ?
                FlatButton.icon(
                  icon:Icon(Icons.open_in_new_rounded),
                  label: RobText("Open Gateway"),
                  shape: Round(),
                  onPressed: ()async{
                    await launch(statUrl);
                  },
                  color: Colors.blue[100],
                )
                : SizedBox(),
              isCustom ? RobText(
                "Note: Bitsbull Coins are coming soon. Grab the opportunity to buy Bitsbull Coins in the presale.",
                style: TextStyle(color: Colors.white70, fontSize: 12.0)
              ):SizedBox()
            ],
          ),
        )
      ),
    );
  }
}
