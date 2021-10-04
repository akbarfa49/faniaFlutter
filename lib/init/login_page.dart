import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'package:device_id/device_id.dart';


class LoginPage extends StatefulWidget{
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  Animation<double> animation;
  AnimationController controller;
  String deviceID;
  String username;
  String pass;
  bool _av=false;
  bool _userfield, _passfield=false;
  RegExp defreg = new RegExp("[0-z_]", caseSensitive: false);
  final storage = new FlutterSecureStorage();


  //function
  void getid() async{
    String deviceid;
    deviceid = await DeviceId.getID;
    setState(() {
      deviceID = deviceid;
    });
  }
  void _login() async{
    _onloading();
    var url = host()+'/login';
    Map body = {"username":username,"deviceid":deviceID,"pass":pass};
    try{
    var res = await http.post(url,body: body).timeout(Duration(seconds: 5));
    Response response = Response.fromJSON(json.decode(res.body));
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
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route)=>false);
            })])
          ],
        ),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(seconds: 3));
    animation = Tween<double>(begin: 0,end: 1).animate(controller);
    controller.forward();  
    getid();
    }
  @override
  Widget build(BuildContext context){
    final namaSiswa = TextFormField(
      maxLength: 20,
      cursorColor: Colors.white,
      autovalidate: _av,
      validator:  (value) {
        if (value.isEmpty) {
        _userfield = false;
        return 'masukkan nama pengguna';
        }else if(value.length <3){
          _userfield = false;
          return 'masukkan nama pengguna';
        }else if(!defreg.hasMatch(value)){
          return 'nama pengguna hanya boleh menggunakan Huruf, Nomor, dan _ (underscore)';
        }
        _userfield= true;
        return null;
        },
      onChanged: (text){
        setState(() {
          username = text;
        });
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        icon: Icon(Icons.person),
        labelText: 'Nama Pengguna',
        hintText: 'Nama Pengguna',
      )
    );
    final katasandi = TextFormField(
      maxLength: 16,
      obscureText: true,
      autovalidate: _av,
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
      onChanged: (value){
        setState(() {
          pass = value;
        });
      },
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        labelText: 'Kata Sandi',
        hintText: '********',
      )
    );
    final loginButton = ButtonBar(buttonHeight: 40.0, buttonMinWidth: 100.0, children: <Widget>[MaterialButton(
    color: Colors.blueAccent,
    onPressed: (){
      setState(() {
        _av = true;
      });
      if (_userfield && _passfield){
        _login();
      }
    }
    , child: Text('Masuk'),),],);
    final registerButton = ButtonBar(buttonHeight: 40.0, buttonMinWidth: 100.0, children: <Widget>[MaterialButton(
    color: Colors.blueAccent,
    onPressed: ()
    {Navigator.pushNamed(context, '/regist');}, child: Text('Daftar'),),],);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
           FadeAnimatedTransition(
              child: _Icon(),
              animation: animation
            ),
            SizedBox(height: 100.0),
            namaSiswa,
            SizedBox(height: 8.0,),
            katasandi,
            SizedBox(height: 8.0,),
            SizedBox(width: 20,child: Row(mainAxisAlignment: MainAxisAlignment.end ,children: <Widget>[registerButton, loginButton],),),
          ],
        ),
      ),
    );
  }

  
}

class FadeAnimatedTransition extends StatelessWidget{
    FadeAnimatedTransition({this.child, this.animation});
    final Widget child;
    final Animation<double> animation;
    Widget build(BuildContext context) => Center(child: AnimatedBuilder(animation: animation, builder: (context, child)=>Opacity(opacity: animation.value, child: child,), child: child,));
}