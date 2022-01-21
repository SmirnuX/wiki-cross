//Страница, на которой отображается кроссворд

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'wiki.dart' as wiki;
import 'crossgen.dart';
import 'definition.dart';


class CrosswordRoute extends StatefulWidget {
  CrosswordRoute({Key? key, required this.url}) : super(key: key);
  int pool_size = 30;
  String url;
  State<CrosswordRoute> createState() => CrosswordRouteState();
}

class CrosswordRouteState extends State<CrosswordRoute>
{
  late Stream<List<Gen_Word>> pool;

  @override
  void initState()
  {
    pool = wiki.RequestPool(widget.url, widget.pool_size, 3);
  }
  //Поиск по Википедии: https://en.wikipedia.org/wiki/Special:Search?search=
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wiki Crossword',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.tealAccent[100],
      ),
      home: StreamBuilder(  //TODO - добавить анимации
        stream: pool,
        builder:(BuildContext context, AsyncSnapshot<List<Gen_Word>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) //Если поток завершен
          {
            return MyHomePage(title: 'Alpha WikiCross', words: snapshot.data);
          }
          else if (snapshot.hasError)
          {
            return Text('Error!');  //TODO - нормальное окно ошибки
          }
          else if (snapshot.connectionState == ConnectionState.active)
          {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Text('Загрузка... ${snapshot.data!.length}/${widget.pool_size}'),
                  ],
                )
              ),
            );     
          }
          else
          {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Text('Загрузка... 0/${widget.pool_size}'),
                  ],
                )
              ),
            ); 
          }
        }
    )
    ); 
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({UniqueKey? key, required this.title, required this.words}) : super(key: key);
  final String title;
  List <Gen_Word>? words;
  
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
    crossword = Gen_Crossword(widget.words!, 10);
    Words = crossword.GetWordList();
  }

  @override
  Widget build(BuildContext context) {
    var def = Definition(source: chosen == -1?Words[0]:Words[chosen], index: chosen_let, num: crossword.word_count);
    return Scaffold(
      bottomSheet: def,
      body: Builder(
        builder: (BuildContext context) {
          return crossword.ToWidgetsHighlight(chosen, chosen_let, Words);
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

  void ChangeFocus(bool value, int word_ind, int let_ind) //Подсветка ячейки
  {
    if (!value && Words[word_ind].highlighted != let_ind)
    {
      return;
    }
    Words[word_ind].highlighted = value?let_ind:-1;
  }

  void ChangeTrueFocus(int word_ind, int let_ind)  //Запрос фокуса для ячейки
  {
    ChooseWord(word_ind, let_ind);
  }

  void ChangeLetter(String value, int word_ind, int let_ind)
  {
    setState(() {
      if (value != '')
      {
        Words[word_ind].in_word = Words[word_ind].in_word.replaceRange(let_ind, let_ind + 1, value);
      }
      else
      {
        Words[word_ind].in_word = Words[word_ind].in_word.replaceRange(let_ind, let_ind + 1, '_');
      }
      if (word_ind == chosen)
      {
        Words[word_ind].highlighted++;
      }
      if (Words[word_ind].highlighted > Words[word_ind].length)
      {
        Words[word_ind].highlighted = -1;
      }
      crossword.field_words.setAll(0, Words);
    }); 
    checkForWin(); 
  }

  bool checkForWin()  //Проверка на выигрыш
  {
    bool win = true;
    for (var word in Words)
    {
      if (word.word != word.in_word)
      {
        win = false;
        break;
      }
    }
    if (win)
    {
      print('=======ПОБЕДА========');
    } 
    return win;
  }
}