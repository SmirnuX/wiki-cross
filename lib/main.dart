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
          final url = settings.arguments as String;
          return MaterialPageRoute(builder: (BuildContext context) {return CrosswordRoute(url: url);}) ;
          break;
        case '/final':
          final result = settings.arguments as List<int>;
          return MaterialPageRoute(builder: (BuildContext context) {return FinalRoute(hints:result[0], right: result[1], all: result[2],);}) ;
          break;
      }
    },
  ));
}

