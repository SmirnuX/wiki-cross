// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'dart:io' show Platform;
import 'cells.dart';

import 'crossgen.dart';
import 'crossword.dart';
import 'definition.dart';
import 'wiki.dart' as wiki;
import 'search.dart';
import 'final.dart';
import 'cross_settings.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    title: 'Wiki Crossword',
    theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.tealAccent[100],
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
          return MaterialPageRoute(builder: (BuildContext context) {return CrosswordRoute(title: res.title, size: res.size, diff: res.difficulty, lang_rus: res.lang_rus,);}) ;
          break;
        case '/cross_settings':
          final selection = settings.arguments as List<dynamic>;
          return MaterialPageRoute(builder: (BuildContext context) {return GenRoute(url: selection[0], title: selection[1], lang_rus: selection[2],);}) ;
        case '/final':
          final result = settings.arguments as List<int>;
          return MaterialPageRoute(builder: (BuildContext context) {return FinalRoute(hints:result[0], right: result[1], all: result[2],);}) ;
          break;
      }
    },
  ));
}

