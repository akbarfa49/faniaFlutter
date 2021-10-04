import 'dart:convert';

import 'package:fania/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget{
  @override
  _Home createState() => new _Home();
}


/*    Widget build(BuildContext context) =>  Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[Flexible(flex:9, fit: FlexFit.tight,
        child: 
        Container(padding: EdgeInsets.fromLTRB(10, 40, 0, 20), child: Question(),
        margin: EdgeInsets.only(bottom: 10),
        color: Color.fromRGBO(240, 240, 240, 1),
        )
        ), 
        Flexible(flex:9, fit: FlexFit.tight,
        child: Container(padding: EdgeInsets.fromLTRB(10, 20, 10, 20), child: Text('A. Bapak Kao'),)),
         Flexible(flex:2,
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[_buildBtn('Sebelumnya', -1),_buildBtn('Selanjutnya', 1)
        ]))]);
}*/

class Response{
  final String name;
  final int amount;
  final List<dynamic> transaction;
  final msg;
  Response({this.name, this.amount, this.transaction, this.msg});
  factory Response.fromJSON(Map<String, dynamic>json){
    return Response(
      name: json["data"]["name"],
      amount: json["data"]["amount"],
      transaction: json["data"]["transaction"],
      msg: json["meta"]["messages"],
    );
  }
}

class _Home extends State<Home>{
  int saldo = 0;
  final storage = new FlutterSecureStorage();
  String username="manusia";
  List<dynamic> transaction;

  @override
  void initState(){
    reqProfile();
    super.initState();
  }
  void reqProfile() async{
    var profurl = host()+'/user/profile';
    var key = await storage.read(key: 'auth');
    var expired = await storage.read(key: 'expires');
    var created = await storage.read(key: 'created');
    var current = new DateTime.now().millisecondsSinceEpoch;
    if (int.parse(created)+int.parse(expired)<=current){
      var res = await http.get(url)
    }else{
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
    try{
      var res = await http.get(profurl,headers: {"authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJ1bWluYSIsImRldmljZWlkIjoiZGFzaGpka2hhc2RqaGEiLCJleHAiOjE1ODM0OTcyMTF9.FE1wD309JaI8HtGukIJ6r-29XrtuXf4OavmuH53Njg4",});
      var response = Response.fromJSON(json.decode(res.body));
      if (response.msg=="OK"){
      setState(() {
         transaction = response.transaction;
        username = response.name;
        saldo = response.amount;
      });
      print(transaction);
      }
    }catch(error){
      print(error);
    }
  }
  @override
  Widget build(BuildContext context){
    return SafeArea(
      top: false,
      child: Scaffold(body: Flex(
      direction: Axis.vertical,
      children: <Widget>[
        //intro
        new Flexible(fit:FlexFit.tight,flex: 3,child: Container(padding: EdgeInsets.fromLTRB(20, 10, 20, 10),color: Color.fromRGBO(47, 254, 105, 1), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[Text("Hai, $username", style: TextStyle(color: Colors.black, fontSize: 26,decoration: TextDecoration.none),)],),)),

        //fania Menu
      new Flexible(fit:FlexFit.tight,flex: 4,child: new Container(padding: EdgeInsets.fromLTRB(20,10,20,20),decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter, colors: [Color.fromRGBO(47, 254, 105, 1), Color.fromRGBO(216, 216, 216, 1)], stops: [0.5,0.5],)),
      child: Faniabar(),
      )),
      new Flexible(fit:FlexFit.tight,flex: 2,child: new Container(padding: EdgeInsets.fromLTRB(20,0,20,20),child: _Saldo(saldo: saldo,),decoration: BoxDecoration(color: Color.fromRGBO(216, 216, 216, 1))),),
      new Flexible(flex: 1, child: new Container(decoration: BoxDecoration(color: Color.fromRGBO(216, 216, 216, 1)),padding: EdgeInsets.fromLTRB(20,0,20,0),child: Center(child:Row(children: [Text("Transaksi terakhir", style: TextStyle(fontSize:18, fontWeight: FontWeight.bold),)]),)),),
      new Flexible(fit: FlexFit.tight,flex:11, child: new Container(child: Transaction(transaction: transaction,),padding: EdgeInsets.fromLTRB(20,20,20,20), decoration: BoxDecoration(color: Color.fromRGBO(216, 216, 216, 1)),))
   ]
      ),));
  }
}

class _Saldo extends StatelessWidget{
final saldo;
_Saldo({this.saldo});
final _text = Flexible(fit:FlexFit.tight,flex:7,child: Text('Saldo anda saat ini', style: TextStyle(fontSize: 22,fontWeight: FontWeight.w300,decoration: TextDecoration.none),));

Widget build(BuildContext context){
return new Container(
  decoration: BoxDecoration(color: Colors.white,boxShadow: [new BoxShadow(color: Colors.black,offset: new Offset(1,4),blurRadius: 10.0,)]),
  padding: EdgeInsets.symmetric(horizontal:20),
  
  child:Row(children: <Widget>[_text,Flexible(flex:3,child: Text('Rp. $saldo',style: TextStyle(fontSize:24,fontWeight: FontWeight.w100,decoration: TextDecoration.none),))],));
}
}

class Transaction extends StatelessWidget{
  //Transaction({this.transaction});
   final List<dynamic> transaction;
  Transaction({this.transaction});
  @override
  Widget build(BuildContext context){
    if(transaction==null){
          return Container();
        }
    return new Scaffold(backgroundColor: Colors.transparent,body: ListView.builder(itemCount: transaction.length >3?3:transaction.length,itemBuilder: (context,index){
        return Container(
        decoration: BoxDecoration(color: Colors.white,boxShadow: [new BoxShadow(color: Colors.black,offset: new Offset(1,4),blurRadius: 8.0,)]),
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.fromLTRB(20,10,20,10),
        height: 100,
        width: MediaQuery.of(context).size.width-40,
        child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[Icon(Icons.receipt, size: 60,),Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text(transaction[index]["title"])),),Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text(transaction[index]["date"])),)],),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text(transaction[index]["no"])),),Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text(transaction[index]["price"].toString()),))],)],
      ));
    /* Column(children: <Widget>[
      topmenu,  ListView.builder(itemCount: test.length,itemBuilder: (context,index){
        print(index);
        return ListTile(
          title: Text('${test[index]}'),
        );
      })
    ]); */
  }));}
}
/*
class ListBuilder extends StatelessWidget{
  Widget build(BuildContext context){
    return new Flexible(flex: 9,child: Row(children: [Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.fromLTRB(20,10,20,10),
        color: Colors.white,
        height: 150,
        width: MediaQuery.of(context).size.width-40,
        child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Column(
          mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text('title')),),Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text('date')),)],),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text('title')),),Flexible(flex: 1, fit: FlexFit.tight, child: Center(child:Text('date'),))],)],
      ))]));
      }
}
*/
class Faniabar extends StatelessWidget{
Widget build(BuildContext context){

final buy = new Flexible(fit: FlexFit.tight,flex:1, child:Container(
  decoration: BoxDecoration(border: Border(right: BorderSide(width: 0.5, color: Colors.grey))),
  child: MaterialButton(
    elevation: 100,
    onPressed: (){
      Navigator.of(context).pushNamed('/pulsareg');
    },
    splashColor: Colors.greenAccent,
    child:Column(mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[Icon(Icons.shopping_cart,
  color: Color.fromRGBO(47, 200, 105, 1),
  size: 64,
  ),Text('Pulsa Regular', style: TextStyle(fontSize: 18,fontWeight: FontWeight.w200))],))));
  final buytrf = new Flexible(fit: FlexFit.tight,flex:1, child:Container(
  decoration: BoxDecoration(border: Border(right: BorderSide(width: 0.5, color: Colors.grey))),
  child: MaterialButton(
    elevation: 100,
    onPressed: (){
    },
    splashColor: Colors.greenAccent,
    child:Column(mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[Icon(Icons.phone_android,
  color: Color.fromRGBO(47, 200, 105, 1),
  size: 64,
  ),Text('Pulsa Transfer', style: TextStyle(fontSize: 18,fontWeight: FontWeight.w200))],))));
final trx =  new Flexible(fit: FlexFit.tight,flex:1, child:Container(
  child: MaterialButton(
    elevation: 100,
    onPressed: (){},
    splashColor: Colors.greenAccent,
    child:Column(mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[Icon(Icons.list,
  color: Color.fromRGBO(47, 200, 105, 1),
  size: 64,
  ),Text('Transaksi', style: TextStyle(fontSize: 18,fontWeight: FontWeight.w200),)],))));

  return new Container(
    decoration: BoxDecoration(color: Colors.white,boxShadow: [new BoxShadow(color: Colors.black,offset: new Offset(1,4),blurRadius: 10.0,)]),
    padding: EdgeInsets.fromLTRB(15, 30, 30, 15),
  child: new Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[buy,buytrf, trx],
  ),
  );
}
}