// import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:async';

// String bitsUrl = 'http://192.168.43.122/bitsbull/api.php';
String bitsUrl = 'https://bitsbull.club/bitsbull/api.php';
String baseUrl = 'https://bitsbull.club/bitsbull/';
String bitsMain = 'https://bitsbull.club/';

var error = {'error' : 'Server Error Encountered'};
Response resp;

Future<dynamic> postMe({var data, var url}) async {
  try {
    if (url != null) {
      resp = await Dio().post(baseUrl + url, data: data);
    }
    else {
      resp = await Dio().post(bitsUrl, data: data);
    }
    return resp;
  }catch(e){
    return error;
  }
}

Future<dynamic> getConf() async {
  resp = await Dio().get(bitsUrl+'?getConf=1');
  print(resp);
  return resp.data;
}

Future<bool> getImage(img) async {
  try{
    print(img);
    await Dio().get(img);
    return true;
  }catch(err){
    print(err);
    return false;
  }
}

Future<dynamic> getLogin(var dta) async {
  try{
    resp = await postMe(data:{'data' : dta, 'login': true});
    var js = resp.data;
    return js;
  }
  catch(err){
    print(err);
    return error;
  }
}

Future<dynamic> doRegister({var data}) async {
  try{
    resp = await postMe(data: {'data': data, 'register':true});
    return resp.data;
  }
  catch(err){
    print(err);
    return error;
  }
}

Future<dynamic> registerMain({var data}) async {
  try{
    resp = await postMe(data: {'data': data, 'registerfin':true});
    return resp.data;
  }
  catch(err){
    print(err);
    return error;
  }
}


String codeUrl = 'https://gist.githubusercontent.com/Goles/3196253/raw/9ca4e7e62ea5ad935bb3580dc0a07d9df033b451/CountryCodes.json';
