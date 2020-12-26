import 'dart:async';
import 'dart:convert';

import 'package:bitsbull_app/elements/cards.dart';
import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/main.dart';
import 'package:bitsbull_app/producers/producers.dart';
import 'package:bitsbull_app/service/service.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bitsbull_app/elements/animation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SettingsBull extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsBull> {

  var user;
  String password = "********";

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async{
    var usr = await getSaved(key:'bbull_user');
    setState(() {
      user = jsonDecode(usr);
    });
    var pass = user['password'];
    var lenPass = pass.length;
    var strPas = '';
    for(var i = 0; i < lenPass; i++){
      strPas +='*';
    }
    setState(() {
      password = strPas;
    });
  }

  displayChange({var title, var value, var col}) async {
    await showCupertinoModalPopup(
      context:context,
      builder: (context) => DisplayChanges(title: title,value: value, col: col,)
    );
    await init();
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      // extendBodyBehindAppBar: true,
        appBar: AppBar(
          title:RobText("BitsBull - Setttings"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Column(
          children:[
            Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: RobinCard(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset('assets/image/Template_3/deals_layout/cardMenu.png', width: screen.width/2,),
                      SizedBox(height: 10.0,),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.account_circle_rounded, size: 34.0,),
                        title: RobText("Name"),
                        subtitle: RobText(
                          user['name'] != null ? user['name'] : "..."
                        ),
                        trailing: Icon(Icons.edit),
                        onTap: (){
                          displayChange(title: "Name", value: user['name'], col:'name');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.email_rounded, size: 34.0,),
                        title: RobText("Email"),
                        subtitle: RobText(
                          user['email'] != null ? user['email'] : "..."
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone, size: 34.0,),
                        title: RobText("Phone"),
                        subtitle: RobText(
                            user['phone'] != null ? user['phone'] : "..."
                        ),
                        trailing: Icon(Icons.edit),
                        onTap: (){
                          displayChange(title: "Phone", value: user['phone'], col:'phone');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.lock_rounded, size: 34.0,),
                        title: RobText("Password"),
                        subtitle: RobText(
                            password
                        ),
                        trailing: Icon(Icons.edit),
                        onTap: (){
                          displayChange(title: "Password", value: user['password'], col:'password');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.upload_file, size: 34.0,),
                        title: RobText("Pending Verification"),
                        subtitle: RobText(
                            "KYC Documents for Verification"
                        ),
                        trailing: Icon(Icons.pending_actions_rounded),
                      ),
                      SizedBox(height: 10.0,),
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: RobText("Logout from bitsbull"),
                          onPressed: () async {
                            await clear();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => Bitsbull()
                              )
                            );
                          },
                          color:Colors.red[200]
                      )
                    ],
                  )
                )
              ),
            )),
          ]
        )
    );
  }
}


class DisplayChanges extends StatelessWidget {
  DisplayChanges({this.title, this.value, this.col});
  String title;
  String col;
  String value;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    controller.text = value;
    return Dialog(
      shape: Round(),
      child: Container(
          decoration: Box(shape:BorderRadius.circular(15.0)),
          alignment: Alignment.center,
          height: screen.height/3,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RobText(
                  "Update "+title,
                  style: TextStyle(color:Colors.white, fontSize: 20.0)
              ),
              SizedBox(height: 20.0,),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: value,
                  labelText: title,
                  hintStyle: Common(
                    style: TextStyle(color: Colors.white70)
                  ),
                  labelStyle: Common(
                    style: TextStyle(color: Colors.white)
                  )
                ),
                style: Common(
                  style: TextStyle(color: Colors.white)
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              FlatButton(
                color: Colors.blue[100],
                shape: Round(radii: 10.0),
                child: RobText(
                  "Update"
                ),
                onPressed: () async {
                  var js = await getSaved(key:'bbull_user');
                  var user = jsonDecode(js);
                  toast("Updating...");
                  var res = await postMe(data:{'data': {'id': user['id'], 'update' : {'col' : col, 'value' : controller.text}}, 'update' : true});
                  try{
                    await saveLog(data:res.data);
                    toast("Updated", color: Colors.green[100]);
                  }
                  catch(err){
                    print(err);
                    toast("Error occured : "+err);
                  }
                  cancel(context);
                },
              )
            ],
          )
      ),
    );
  }
}
