
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fania/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'package:device_id/device_id.dart';


class Register extends StatefulWidget{
  static String tag = 'register-page';
  @override
  _RegisterPageState createState() => new _RegisterPageState();
}
class _Icon extends StatelessWidget{
  Widget build(BuildContext context) =>Hero(
      tag: 'Hero',
      child:  Image.asset('assets/main.png', height: 150,),
      );
}

class Response{
  final String messages;
  final String token;
  final int createAt;
  final int expiresIn;
  final int httpStatus;
  Response({this.messages, this.httpStatus,this.token, this.createAt,this.expiresIn});
  factory Response.fromJSON(Map <String, dynamic> json){
    return Response(
      token: json["data"]["access_token"],
      createAt: json["data"]["created_at"],
      expiresIn: json["data"]["expires_in"],
      messages: json["meta"]["messages"],
      httpStatus: json["meta"]["http_status"],
    );
  }
}

class _RegisterPageState extends State<Register> with SingleTickerProviderStateMixin{ 
  Animation<Color> animation;
  AnimationController controller;
  String _deviceID,_username,_name,_pass,_email;
  bool _userfield,_namefield,_passfield,_emailfield = false;
  bool _av = false;
  RegExp regmail = new RegExp("[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}", caseSensitive: false, multiLine: false);
  RegExp defreg = new RegExp("[0-z_]", caseSensitive: false);
  final storage = new FlutterSecureStorage();
  Response response;
  getid() async{
    String deviceid;
    deviceid = await DeviceId.getID;
    setState(() {
      _deviceID = deviceid;
    });
  }
  Future<void> _onloading() async{
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: new SizedBox(height: 100, width: 100,
        child:Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new CircularProgressIndicator(strokeWidth: 3,),
            new SizedBox(width: 25),
            new Text("Loading"),
          ],
        ),
      ));
    },
  );
  }
  Future<void> _onDone(String message) async{
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: new SizedBox(height: 200, width: 200,
        child:Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new Text(message),
            new SizedBox(height: 20),
            new ButtonBar(buttonHeight: 40.0, buttonMinWidth: 100.0, children: <Widget>[MaterialButton(
            color: Colors.blueAccent,
            animationDuration: Duration(seconds: 3),
            splashColor: Color.fromRGBO(200, 200, 255, 1),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            child: Text('OK', style: TextStyle(color: Colors.white,)),
            onPressed: (){
              Navigator.of(context).pushReplacementNamed('/regist');
            })])
          ],
        ),
      ));
    });
  }
  void _register() async{
    _onloading();
    String url = host()+"/regist";
    try{
    var res = await http.post(url,body:{'username': _username, 'name': _name,'pass':_pass,'deviceid': _deviceID, 'email':_email}).timeout(Duration(seconds: 5));
    response = Response.fromJSON(json.decode(res.body));
    if (response.httpStatus != 200 && response.messages != "OK"){_onDone(response.messages);}
    else{
    await storage.write(key: "auth", value: response.token);
    await storage.write(key: "expires", value: response.expiresIn.toString());
    await storage.write(key: "created", value: response.createAt.toString());
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route)=> false); 
    }
    }
    catch(error){
     _onDone("gagal terhubung ke server");
    }
  }
  @override
  void initState() {
    super.initState();
    getid();
    }
  @override
  Widget build(BuildContext context){
    final namapenggunafield = TextFormField(
      maxLength: 16,
      cursorColor: Colors.white,
autovalidate: _av,
      validator: (value) {
        if (value.isEmpty) {
        _userfield = false;
        return 'masukkan nama pengguna';
        }else if(value.length <3){
          _userfield = false;
          return 'masukkan nama pengguna';
        }else if(!defreg.hasMatch(value)){
          return 'nama pengguna hanya boleh menggunakan Huruf, Nomor, dan _ (underscore)';
        }
        _userfield = true;
        return null;
      },
      onChanged: (text){
        setState(() {
          _username = text;
        });
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        icon: Icon(Icons.person),
        labelText: 'Nama Pengguna',
        hintText: 'Nama Pengguna',
      )
    );
    final namafield = TextFormField(
      maxLength: 20,
      cursorColor: Colors.white,
      autovalidate: _av,
      validator: (value) {
       if (value.isEmpty) {
         _namefield = false;
        return 'masukkan nama lengkap';
        }else if(value.length <3){
          _namefield = false;
         return 'masukkan nama lengkap';
        }
        _namefield = true;
        return null;
      },
      onChanged: (text){
        setState(() {
          _name = text;
        });
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        icon: Icon(Icons.person),
        labelText: 'Nama Lengkap',
        hintText: 'Nama Lengkap',
      )
    );
    final emailfield = new TextFormField(
      keyboardType: TextInputType.emailAddress,
      maxLength: 20,
      autovalidate: _av,
      cursorColor: Colors.white,
      validator: (value) {
        if (value.isEmpty) {
          _emailfield = false;
        return 'masukkan email yang valid';
        }else if(!regmail.hasMatch(value)){
          _emailfield = false;
          return 'masukkan email yang valid';
        }
        _emailfield = true;
        return null;
      },
      onChanged: (text){
        setState(() {
          _email = text;
        });
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        icon: Icon(Icons.email),
        labelText: 'Email',
        hintText: 'Email',
      )
    );
    final katasandifield = TextFormField(
      obscureText: true,
      autovalidate: _av,
      maxLength: 16,
      onChanged: (text){
        setState(() {
          _pass = text;
        });
        },
      validator: (value) {
        if (value.isEmpty) {
        _passfield = false;
        return 'katasandi minimal 8 huruf';
        }else if(value.length <8){
          _passfield = false;
          return 'katasandi minimal 8 huruf';
        }
        _passfield = true;
        return null;
      },
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        labelText: 'Kata Sandi',
        hintText: '********',
      )
    );
    final registerButton = ButtonBar(buttonHeight: 40.0, buttonMinWidth: 100.0, children: <Widget>[MaterialButton(
    color: Colors.blueAccent,
    animationDuration: Duration(seconds: 3),
    splashColor: Color.fromRGBO(200, 200, 255, 1),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    onPressed: (){
      
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _av = true;
      });
      if (_userfield && _namefield && _passfield && _userfield && _emailfield){
       _register(); 
        return;
      }
    }, child: Text('Daftar', style: TextStyle(color: Colors.white,)),),],);
    return Scaffold(
      backgroundColor: Colors.white,
      body: 
      Stack(children: <Widget>[Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
           Center(
              child: _Icon(),),
            SizedBox(height: 90.0),
            namafield,
            SizedBox(height: 8.0,),
            namapenggunafield,
            SizedBox(height: 8.0,),
            emailfield,
            SizedBox(height: 8.0,),
            katasandifield,
            SizedBox(width: 20,child: Row(mainAxisAlignment: MainAxisAlignment.end ,children: <Widget>[registerButton],),),
          ],
        ),
      ),
      ])
    );
  }

  
}