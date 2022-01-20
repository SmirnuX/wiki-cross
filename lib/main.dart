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

class SearchRoute extends StatefulWidget //Страница поиска
{
  final TextStyle _bigger = const TextStyle(
    fontSize: 20,

  );
  State<SearchRoute> createState() => _SearchRouteState();
}

class _SearchRouteState extends State<SearchRoute> with SingleTickerProviderStateMixin
{
  late TabController tab_controller;

  @override
  void initState() {
    super.initState();
    tab_controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar
        (
          controller: tab_controller,
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
            ),
            Tab(
              icon: Icon(Icons.casino_outlined),
            ),
            Tab(
              icon: Icon(Icons.photo_size_select_actual_rounded),
            ),
          ],
        ) 
      ),
      body: TabBarView(
        controller: tab_controller,
        children:[
          Center( //Поиск
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //https://ru.wikipedia.org/w/api.php?action=opensearch&search=lego&limit=1&namespace=0&format=json
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
          ),
          Center( //Случайная статья  
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.all(6), 
                      child: Text('🎲 Cлучайная статья 🇷🇺', style: widget._bigger,),
                    ),
                    onPressed: () 
                    {
                      Navigator.pushNamed(context, '/crossword', arguments: 'https://ru.wikipedia.org/wiki/Special:Random');
                    }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.all(6), 
                      child: Text('🎲 Cлучайная статья 🇺🇸', style: widget._bigger,),
                    ),
                    onPressed: () 
                    {
                      Navigator.pushNamed(context, '/crossword', arguments: 'https://en.wikipedia.org/wiki/Special:Random');
                    }
                  ),
                ),
              ],
            ),
          ),
          Text('Темы')  //Темы
        ]
      ) 
    );
  }
}
