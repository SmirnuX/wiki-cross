import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _WordHor(
        ),
      ),
    );
  }
}

class _WordHor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <_CellCross>[
        _CellCross(),
        _CellCross(),
        _CellCross(),
        _CellCross(),
        _CellCross(),
      ]
    );
  }
}

class _CellCross extends StatefulWidget { //Ячейка кроссворда
  _CellCross({ Key? key}) : super(key: key);
  @override
  __CellCrossState createState() => __CellCrossState();
}

class __CellCrossState extends State<_CellCross> {
  final for_color = Colors.white;
  final sel_color = Colors.green[50];
  final _biggerFont = TextStyle(fontSize: 40);
  bool _focused = false;
  late FocusNode myFocusNode;
  var txt = TextEditingController();
  @override
  void initState()
  {
    myFocusNode = FocusNode();
    myFocusNode.addListener(() { 
      setState(() {
        if (myFocusNode.hasFocus != _focused) {
          setState(() {
            _focused = myFocusNode.hasFocus;
          });
        }
      });
    });
    txt.addListener(() {
      txt.value = txt.value.copyWith(
        selection:
            TextSelection(baseOffset: txt.value.text.length, extentOffset: txt.value.text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose()
  {
    myFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Card(
        color: _focused?sel_color:for_color,
        child: Center(
          child: TextField(
            cursorColor: _focused?sel_color:for_color,
            showCursor: false,
            focusNode: myFocusNode,
            textInputAction: TextInputAction.next,
            controller: txt,
            decoration: null,
            style: _biggerFont,
            textAlign: TextAlign.center,
            maxLength: 2, //Extra character for next symbol
            onChanged: (String value) {
              value = value.toUpperCase();
              if (!value.contains(RegExp(r"^[A-ZА-ЯЁ]+$"))) {
                txt.text = '';
              } else if (value.length == 2) {
                txt.text = value.substring(1);
              } else {
                txt.text = value;
              }
              myFocusNode.nextFocus();
            }
          ),
        ) 
      )
    );
  }
}