import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LauncherPage extends StatefulWidget{
  @override
  _LauncherPage createState() => new _LauncherPage();
}

class LogoWidget extends StatelessWidget{
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    child: Image.asset('assets/launch.png')
  );
}

class _LauncherPage extends State<LauncherPage> with SingleTickerProviderStateMixin{
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState(){
    super.initState();
    startLaunching();
    controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 0, end: 300).animate(controller);
    controller.forward();
  }
 
 startLaunching() async{
   var duration = Duration(seconds: 2);
   String navi = '/home';
   String auth = await FlutterSecureStorage().read(key: 'auth');
   if (auth != ""){
     setState(() {
     navi = '/home';
     });
   }
   return new Timer(duration, (){
      Navigator.of(context).pushReplacementNamed(navi);
      });
}

 @override
 Widget build(BuildContext context) => GrowTransition(
    child: LogoWidget(),
    animation: animation
  );

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

}

class GrowTransition extends StatelessWidget{
  GrowTransition({this.child, this.animation});
  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedBuilder(animation: animation,
    builder: (context, child) => Container(
      height: animation.value,
      width: animation.value,
      child: child,
    ),
    child: child)
  );
}