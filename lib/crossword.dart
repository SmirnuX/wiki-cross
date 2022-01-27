//Страница, на которой отображается кроссворд

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'wiki.dart' as wiki;
import 'crossgen.dart';
import 'definition.dart';


class CrosswordRoute extends StatefulWidget {
  CrosswordRoute({Key? key, required this.url, required this.size, required this.diff}) : super(key: key);
  String url;
  int size;
  int diff;
  State<CrosswordRoute> createState() => CrosswordRouteState();
}

class CrosswordRouteState extends State<CrosswordRoute>
{
  late Stream<List<Gen_Word>> pool;
  late int pool_size;
  late int recursive_links;
  late int max_length;
  late int buffer_inc;  //Увеличение буфера с каждым шагом
  @override
  void initState()
  {
    switch (widget.diff)
    {
      case 1: //Низкий уровень сложности
        pool_size = 4 * widget.size;
        recursive_links = 1;
        max_length = 12;
        buffer_inc = 1;
        break;
      case 2: //Средний
        pool_size = 3 * widget.size;
        recursive_links = 3;
        max_length = 16;
        buffer_inc = 2;
        break;
      case 3: //Высокий
        pool_size = 2 * widget.size;
        recursive_links = 5;
        max_length = 20;
        buffer_inc = 5;
        break;
    }

    pool = wiki.RequestPool(widget.url, pool_size, recursive_links, max_length);
  }
  //Поиск по Википедии: https://en.wikipedia.org/wiki/Special:Search?search=
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(  //TODO - добавить анимации
      stream: pool,
      builder:(BuildContext context, AsyncSnapshot<List<Gen_Word>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) //Если поток завершен
        {
          return CrosswordPage(words: snapshot.data!, size: widget.size, buf_inc: buffer_inc );
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
                  Text('Загрузка... ${snapshot.data!.length}/$pool_size'),
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
                  Text('Загрузка... 0/$pool_size'),
                ],
              )
            ),
          ); 
        }
      }
    );
  }
}

class CrosswordPage extends StatefulWidget {
  CrosswordPage({UniqueKey? key, required this.words, required this.size, required this.buf_inc}) : super(key: key);
  List <Gen_Word> words;
  int size, buf_inc;
  @override
  State<CrosswordPage> createState() => CrosswordPageState();

  static CrosswordPageState? of (BuildContext context)
  {
    var res = context.findAncestorStateOfType<CrosswordPageState>();
    return res;
  }
}

class CrosswordPageState extends State<CrosswordPage> {
  List <Field_Word> Words = [];
  int chosen = 0;  //Выбранное слово
  int chosen_let = -1;  //Выбранная буква
  late Gen_Crossword crossword;
  @override
  void initState()
  {
    crossword = Gen_Crossword(widget.words, widget.size, widget.buf_inc);
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
      Navigator.pushNamed(context, '/final', arguments: [0, Words.length, Words.length]);
    } 
    return win;
  }
}