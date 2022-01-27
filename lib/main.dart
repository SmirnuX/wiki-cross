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
          return MaterialPageRoute(builder: (BuildContext context) {return CrosswordRoute(url: res.url, size: res.size, diff: res.difficulty);}) ;
          break;
        case '/cross_settings':
          final selection = settings.arguments as List<String>;
          return MaterialPageRoute(builder: (BuildContext context) {return GenRoute(url: selection[0], title: selection[1]);}) ;
        case '/final':
          final result = settings.arguments as List<int>;
          return MaterialPageRoute(builder: (BuildContext context) {return FinalRoute(hints:result[0], right: result[1], all: result[2],);}) ;
          break;
      }
    },
  ));
}

