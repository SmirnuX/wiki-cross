// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
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

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => SearchRoute(),  //Поиск статей в Википедии
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/crossword') {
        final url = settings.arguments as String;
        return MaterialPageRoute(builder: (BuildContext context) {return CrosswordRoute(url: url);}) ;
      }
      else
      {
        return null;
      }
    },
  ));
}

