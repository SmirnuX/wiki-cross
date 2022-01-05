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
  MyHomePage({UniqueKey? key, required this.title}) : super(key: key);
  final String title;
  
  @override
  State<MyHomePage> createState() => MyHomePageState();

  static MyHomePageState? of (BuildContext context)
  {
    var res = context.findAncestorStateOfType<MyHomePageState>();
    return res;
  }
}

class MyHomePageState extends State<MyHomePage> {
  List <Field_Word> Words = [];
  int chosen = 0;  //Выбранное слово
  int chosen_let = -1;  //Выбранная буква
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
    var def = Definition(source: chosen == -1?null:Words[chosen], index: chosen_let);
    return Scaffold(
      bottomSheet: def,
      body: Builder(
        builder: (BuildContext context) {
          return Widgets;
        }
      ),
    );
  }

  void ChooseWord(int value, int second)
  { 
    setState(() {
      chosen = value;
      chosen_let = second;
    });
  }

}

class Definition extends StatefulWidget {
  Definition({ Key? key, this.source, required this.index}) : super(key: key);
  Field_Word? source;
  int index;
  final TextStyle Header_style = const TextStyle(
    fontSize: 30,
    fontFamily: 'Arial'
  );
  final TextStyle Header_const_style = TextStyle(
    fontSize: 30,
    fontFamily: 'Arial',
    backgroundColor: Colors.grey[200],
  );
  final TextStyle Header_focus_style = TextStyle(
    fontSize: 30,
    fontFamily: 'Arial',
    backgroundColor: Colors.lightGreen[300],
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
    List<AutoSizeText> res = [];  //Непосредственно слово
    //String result = '';
    if (widget.source != null)
    {
      for (int i = 0; i < widget.source!.length; i++)
      {
        if (widget.source!.word.substring(i, i+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")))  //Посторонние символы
        {
          res.add(AutoSizeText
          (widget.source!.word.substring(i, i+1),
            style: widget.Header_const_style,
            maxFontSize: 30,
            maxLines: 1,
            wrapWords: false,
            textAlign: TextAlign.left,
          ));

        }
        else
        {
          String letter = widget.source!.in_word.substring(i, i+1);
          res.add(AutoSizeText
          (letter==' '?'_':letter,
            style: i==widget.index?widget.Header_focus_style:widget.Header_style,
            maxFontSize: 30,
            maxLines: 1,
            wrapWords: false,
            textAlign: TextAlign.left,
          ));
          
          // result += letter==' '?'_':letter;
        }
        // result += ' ';
      }
    }
    return Card(
      margin: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(  //Номер слова
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Chip( 
              label:Text(
                (widget.source==null)?'':'${widget.source!.num+1}/10',
                style: widget.Counter_style,
              )
            )
          ),
          Container(  //Само слово
            child: Row (
              children: res,
            ),
            margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          ),
          const Divider(
          ),
          Container(  //Определение слова
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
