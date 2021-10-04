import 'package:flutter/material.dart';
import 'package:fania/home/home.dart';
import 'package:fania/init/launcher_view.dart';
import 'package:fania/init/login_page.dart';
import 'package:fania/init/register_page.dart';
 host(){
  var hosts = 'http://192.168.49.194:8080';
  return hosts;
}
void main() => runApp(new MyApp());
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fania',
      initialRoute: '/',
      routes: {'/': (context) => LauncherPage(),
              '/regist': (context) => Register(),
              '/login': (context) => LoginPage(),
              '/home': (context) => Home(),
      },
    );
  }
}/*
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

void main() => runApp(LogoApp());

// #docregion LogoWidget
class LogoWidget extends StatelessWidget {
  // Leave out the height and width so it fills the animating parent
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: FlutterLogo(),
      );
}
// #enddocregion LogoWidget

// #docregion GrowTransition
class GrowTransition extends StatelessWidget {
  GrowTransition({this.child, this.animation});

  final Widget child;
  final Animation<double> animation;

  Widget build(BuildContext context) => Center(
        child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) => Container(
                  height: animation.value,
                  width: animation.value,
                  child: child,
                ),
            child: child),
      );
}
// #enddocregion GrowTransition

class LogoApp extends StatefulWidget {
  _LogoAppState createState() => _LogoAppState();
}

// #docregion print-state
class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 0, end: 300).animate(controller);
    controller.forward();
  }
  // #enddocregion print-state

  @override
  Widget build(BuildContext context) => GrowTransition(
        child: LogoWidget(),
        animation: animation,
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  // #docregion print-state
}
*/