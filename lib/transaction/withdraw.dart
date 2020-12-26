import 'dart:convert';

import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/producers/producers.dart';
import 'package:bitsbull_app/service/service.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:flutter/material.dart';
import 'package:bitsbull_app/service/service.dart';

class WithdrawRobin extends StatefulWidget {
  final Widget child;

  String coin;
  var value;
  var avail;

  WithdrawRobin({Key key, this.child,this.value, this.coin, this.avail}) : super(key: key);

  _WithdrawRobinState createState() => _WithdrawRobinState();
}

class _WithdrawRobinState extends State<WithdrawRobin> {

  String recv;
  String coinAmount;
  String address;
  String error;

  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: RobText('WITHDRAW', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body:Container(
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
        child: Column(
          children: <Widget>[
          Container(
            width: double.infinity,
            height: 55.0,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:20.0,right: 20.0,top: 19.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RobText(
                        "Available ("+widget.coin+")",
                        style: TextStyle(color: Colors.white70),),
                      RobText(
                        widget.avail != null ? widget.avail.toString() : "0",
                        style: TextStyle(color: Colors.white),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            // height:255.0,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor.withOpacity(.4),
                borderRadius: BorderRadius.all(Radius.circular(5.0))
            ),
            child: Padding(
              padding: const EdgeInsets.only(left:18.0,right: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 27.0,),
                  RobText(
                    "Withdrawal Address",
                    style: TextStyle(color: Colors.white),),
                  Padding(
                    padding: const EdgeInsets.only(right:5.0,bottom: 35.0),
                    child: Input(
                      hint: "Paste your deliver address",
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 15.0),
                      style: TextStyle(color:Colors.white),
                      onChanged: (val) {
                        setState(() {
                          if(val.trim() == ""){
                            address = null;
                          }
                          else{
                            address = val;
                          }
                        });
                      },
                    ),
                  ),

                  RobText(
                    "Quantity ( "+widget.coin+" )",
                    style:TextStyle(color: Colors.white),),
                  Input(
                    input: TextInputType.number,
                    hint: "0",
                    hintStyle: TextStyle(color: Colors.white70,fontSize: 15.0),
                    errorText: error,
                    style: TextStyle(color:Colors.white),
                    onChanged: (val){
                      setState(() {
                        if(val.trim() != ""){
                          var valM = double.parse(widget.value.toString());
                          var inp = double.parse(val);
                          var outp = valM * inp;
                          recv = outp.toStringAsFixed(2);
                          coinAmount = val;
                          if(inp > double.parse(widget.avail.toString())){
                            error = "Quantity cannot be greater than available balance";
                          }
                          else{
                            error = null;
                          }
                        }
                        else{
                          recv = "0.0";
                          error = null;
                          coinAmount = null;
                        }
                      });
                    },
                  ),
                  SizedBox(height: 5.0,),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text("24H Withdrawal",style: TextStyle(color: Theme.of(context).hintColor,fontFamily: "Popins",fontSize: 12.0),),
                  ),

                  SizedBox(height: 15.0,),
                  //         Text("Fee",style: TextStyle(color: Theme.of(context).hintColor.withOpacity(0.7),fontFamily: "Popins",),),
                  // TextField(
                  //         decoration: InputDecoration(
                  //           hintText: "0.001",
                  //           hintStyle: TextStyle(color: Theme.of(context).hintColor,fontFamily: "Popins",fontSize: 15.0)
                  //         ),
                  //       ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RobText(
                "Received Amount",
                style: TextStyle(color: Colors.white70),),
              RobText(
                recv != null ? recv : "0.0",
                style: TextStyle(color: Colors.white),)
            ],
          ),
          SizedBox(height: 35.0,),
          FlatButton.icon(
            color:Colors.blue[100],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)
            ),
            padding: EdgeInsets.only(right:40.0, left:40, top:10.0, bottom: 10.0),
            icon:Icon(isProcessing ? Icons.hourglass_top_rounded : Icons.arrow_circle_down_outlined),
            label: isProcessing ? SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(),
            ) : RobText("Withdraw"),
            disabledColor: Colors.white12,
            disabledTextColor: Colors.white70,
            onPressed: isProcessing || error != null || recv == null || address == null || coinAmount == null ? null : () async {
              setState(() {
                isProcessing = true;
              });
              var local = await getSaved(key:'bbull_user');
              var email = jsonDecode(local)['email'];
              toast("Sending request..");
              await postMe(data:{'data' : {'address' : address, 'amount': coinAmount, 'email': email, 'coin' : widget.coin}, 'withdraw':true});
              toast("Withdraw of "+coinAmount+" "+widget.coin+" request has been sent");
              setState(() {
                isProcessing = false;
              });
              cancel(context);
            },
          ),
          SizedBox(height: 20.0,)
        ],
        ),
      )
    ));
  }
}