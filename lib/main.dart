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

class SearchRoute extends StatelessWidget //Страница поиска
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: const Text('🎲 Cлучайная статья 🇷🇺'),
              onPressed: () 
              {
                Navigator.pushNamed(context, '/crossword', arguments: 'https://ru.wikipedia.org/wiki/Special:Random');
              }
            ),
            ElevatedButton(
              child: const Text('🎲 Cлучайная статья 🇺🇸'),
              onPressed: () 
              {
                Navigator.pushNamed(context, '/crossword', arguments: 'https://en.wikipedia.org/wiki/Special:Random');
              }
            ),
            ElevatedButton(
              child: const Text('🔍 Поиск'),
              onPressed: () 
              {
                Navigator.pushNamed(context, '/crossword', arguments: 'https://ru.wikipedia.org/wiki/Flutter');
              }
            ),
            ElevatedButton(
              child: const Text('🐻 Тема "Животные"'),
              onPressed: () 
              {
                Navigator.pushNamed(context, '/crossword', arguments: 'https://ru.wikipedia.org/wiki/%D0%96%D0%B8%D0%B2%D0%BE%D1%82%D0%BD%D1%8B%D0%B5'); 
              }
            ),
          ]
        )
      )
    );
  }
}
