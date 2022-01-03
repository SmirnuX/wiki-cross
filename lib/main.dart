// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io' show Platform;
import 'cells.dart';
import 'crossgen.dart';
import 'test_words.dart';

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
      home: MyHomePage(title: 'Proto WikiCross'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  int chosen = -1;  //Выбранное слово
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List <Field_Word> Words = [];
  late Gen_Crossword crossword;
  @override
  void initState()
  {
    crossword = Gen_Crossword(test_words_set.Get(), 10);
    Words = crossword.GetWordList();
  }

  @override
  Widget build(BuildContext context) {
    for (var word in Words)
    {
      word.parent = widget;
    }
    var Widgets = crossword.ToWidgets();
    var def = Definition(source: widget.chosen == -1?null:Words[widget.chosen]);
    return Scaffold(
      bottomSheet: def,
      body: Widgets,
    );
  }
}

class Definition extends StatefulWidget {
  Definition({ Key? key, this.source}) : super(key: key);
  Field_Word? source;
  final TextStyle Header_style = const TextStyle(
    fontSize: 30,
    fontFamily: 'Arial'
  );
  final TextStyle Definit_style = const TextStyle(
    fontSize: 20
  );
  final Counter_style = const TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

  @override
  _DefinitionState createState() => _DefinitionState();
}

class _DefinitionState extends State<Definition> {

  @override
  Widget build(BuildContext context) {
    String result = '';
    if (widget.source != null)
    {
      for (int i = 0; i < widget.source!.length; i++)
      {
        if (widget.source!.word.substring(i, i+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")))  //Посторонние символы
        {
          result += widget.source!.word.substring(i, i+1);
        }
        else
        {
          String letter = widget.source!.in_word.substring(i, i+1);
          result += letter==' '?'_':letter;
        }
        result += ' ';
      }
    }
    return Card(
      margin: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Chip( 
              label:Text(
                (widget.source==null)?'':'${widget.source!.num+1}/10',
                style: widget.Counter_style,
              )
            )
          ),
          Container(
            child: AutoSizeText (
              result,
              maxFontSize: 30,
              maxLines: 1,
              wrapWords: false,
              textAlign: TextAlign.left,
              style: widget.Header_style,
            ),
            margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          ),
          const Divider(
          ),
          Container(
            child:Text(
              (widget.source==null)?'':widget.source!.definition,
              style: widget.Definit_style,
            ),
            margin: const EdgeInsets.all(10),
          ),
        ]
      )  
    );
  }
}
