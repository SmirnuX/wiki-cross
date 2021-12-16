import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'cells.dart';
import 'crossgen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proto WikiCross',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.tealAccent[100],
      ),
      home: const MyHomePage(title: 'Proto WikiCross'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    var Gen = Gen_Crossword(<String> [
        'Привет', 'Пока', 'Наследование', 'Кто-то', 'Какие-то', 'Санкт-Петербург', 'о\'ооо', 'город', 'солнце',
        'поезд', 'окружение', 'ПрИзнание', 'Песок', 'Кровля', 'Пельмени', 'Дровяные', 'Конструкции', 'Москва',
        'Flutter', 'Is', 'The', 'Best', 'Framework', 'const', 'var', 'main', 'O\'Reilly',
        'привествую', 'ну', 'че', 'как', 'что', 'устал', 'уже', 'очень', 'cisco',
    ]);
    var Widgets = Gen.ToWidgets();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Widgets,
      
      // InteractiveViewer(
      //   minScale: 0.001,
      //   maxScale: 8.0,
      //   boundaryMargin: const EdgeInsets.all(1520), //ax(w,h)
      //   constrained: false,
      //   //clipBehavior: Clip.none,
      //   child: SizedBox(
      //     width: 1520,
      //     height: 640,
      //     child: Stack(
      //       //clipBehavior: Clip.none,
      //       children: const <Widget>[
      //         Positioned(child: WordHor(length : 10), top: 80, left: 80),      
      //         Positioned(child: WordHor(length : 16), top: 240, left: 240), 
      //         Positioned(child: WordVer(length : 8), top: 0, left: 160),
      //       ]),
      //   ) 
      // ),
    );
  }
}