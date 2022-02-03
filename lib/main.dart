// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'crossword.dart';
import 'search.dart';
import 'final.dart';
import 'cross_settings.dart';

void main() {
  runApp(MaterialApp(
    title: 'Wiki Crossword',
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      primaryColor: Colors.amber[100]
    ),
    initialRoute: '/',
    
    routes: {
      '/': (context) => SearchRoute(),  //Поиск статей в Википедии
    },
    onGenerateRoute: (settings) {
      switch (settings.name)
      {
        case '/crossword':
          final res = settings.arguments as GenSettings;
          return MaterialPageRoute(builder: (BuildContext context) {return CrosswordRoute(pageid: res.pageid, size: res.size, diff: res.difficulty, lang_rus: res.lang_rus,);}) ;
          break;
        case '/cross_settings':
          final selection = settings.arguments as List<dynamic>;
          return MaterialPageRoute(builder: (BuildContext context) {return GenRoute(pageid: selection[0], title: selection[1], lang_rus: selection[2],);}) ;
        case '/final':
          final result = settings.arguments as List<dynamic>;
          return MaterialPageRoute(builder: (BuildContext context) {return FinalRoute(hints:result[0], words: result[1]);}) ;
          break;
      }
    },
  ));
}

