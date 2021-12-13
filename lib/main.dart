import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: InteractiveViewer(
        minScale: 0.001,
        maxScale: 8.0,
        boundaryMargin: const EdgeInsets.all(1520), //ax(w,h)
        constrained: false,
        //clipBehavior: Clip.none,
        child: Container(
          width: 1520,
          height: 640,
          child: Stack(
            //clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(child: _WordHor(length : 10), top: 80, left: 80),      
              Positioned(child: _WordHor(length : 16), top: 240, left: 240), 
              Positioned(child: _WordVer(length : 8), top: 0, left: 160),
            ]),
        ) 
      ),
    );
  }
}

class _WordHor extends StatelessWidget {
  const _WordHor ({ Key? key, this.length: 8 }) : super(key: key);
  final length;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FocusTraversalGroup(
        child: Row(
          children: List <_CellCross>.filled(length, _CellCross()),
        ),
      ),
    );
  }
}

class _WordVer extends StatelessWidget {
  const _WordVer({ Key? key, this.length: 8 }) : super(key: key);
  final length;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FocusTraversalGroup(
        child: Column(
          children: List <_CellCross>.filled(length, _CellCross()),
        ),
      ),
    );
  }
}

class _CellFormatter extends TextInputFormatter {  //Форматирование текста в ячейках
  _CellFormatter ({ required this.node});
  FocusNode node;
  int prev = 0;
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
        print('Prev: \"$oldValue\", Next: \"$newValue\"');
        if (newValue.text.contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]"))) //Посторонние символы
        {
          return TextEditingValue();  //Сброс ячейки
        }
        if (newValue.text.length <= 1)
        {
          if (newValue.composing != TextRange.empty || Platform.isWindows)
          {
            node.nextFocus();
          }
          return TextEditingValue(text:newValue.text.toUpperCase());
        }
        if (newValue.text.substring(1) == oldValue.text)  //Если новая буква вначале
        {
          node.nextFocus();
          return TextEditingValue(text:newValue.text.substring(0,1).toUpperCase()); //Возвращаем первую букву
        }
        else
        {
          node.nextFocus();
          return TextEditingValue(text:newValue.text.substring(1).toUpperCase());
        }
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
  FocusNode myFocusNode = FocusNode();
  late _CellFormatter txt_format = _CellFormatter(node:myFocusNode);
  var txt = TextEditingController();
  @override
  void initState()
  {
    myFocusNode.addListener(() { 
      setState(() {
        if (myFocusNode.hasFocus != _focused) {
          setState(() {
            _focused = myFocusNode.hasFocus;
          });
        }
      });
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
        // color: for_color,
        child: InkWell(
          // onTap: () {
          //   myFocusNode.requestFocus();
          // },
          onFocusChange: (bool f) {
            if (f) {
              myFocusNode.requestFocus();
            }
          },
          child: Center(
            child: TextField(
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              onTap: () {
                //myFocusNode.requestFocus();
              },
              cursorColor: _focused?sel_color:for_color,
              showCursor: false,
              focusNode: myFocusNode,
              textInputAction: TextInputAction.next,
              controller: txt,
              decoration: null,
              style: _biggerFont,
              textAlign: TextAlign.center,
              maxLength: 2, //Extra character for next symbol
              // onChanged: (String value) {
              //   myFocusNode.nextFocus();
              // },
              inputFormatters: [
                txt_format,
              ],
            ),
          ) 
        )
        
      )
    );
  }
}