import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
      bottomSheet: Definition(),
      body: Widgets,
    );
  }
}

class Definition extends StatelessWidget {
  Definition({ Key? key }) : super(key: key);
  final TextStyle Header_style = TextStyle(
    fontSize: 30,
    fontFamily: 'Arial'
  );
  final TextStyle Definit_style = TextStyle(
    fontSize: 20
  );
  final Counter_style = TextStyle(
    color: Colors.grey[400],
    fontSize: 18,
  );


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Chip( 
              label:Text(
                '1/12',
                style: Counter_style,
              )
            )
          ),
          Container(
            child: AutoSizeText (
              'П _ _ Ь М _ _ И',
              maxFontSize: 30,
              maxLines: 1,
              wrapWords: false,
              textAlign: TextAlign.left,
              style: Header_style,
            ),
            margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
          ),
          Divider(
          ),
          Container(
            child:Text(
              'традиционное блюдо русской кухни в виде термически обработанных изделий из пресного теста с начинкой из рубленого мяса или рыбы, ведущее своё происхождение с Урала и Сибири.',
              style: Definit_style,
            ),
            margin:EdgeInsets.all(10),
          ),
        ]
      )  
    );
  }
}