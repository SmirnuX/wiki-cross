//Страница, на которой отображается кроссворд

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:wiki_cross/error.dart';
import 'wiki.dart' as wiki;
import 'crossgen.dart';
import 'definition.dart';
import 'dart:math';


class CrosswordRoute extends StatefulWidget {
  CrosswordRoute({Key? key, required this.pageid, required this.size, required this.diff, required this.lang_rus}) : super(key: key);
  int pageid;
  bool lang_rus;
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

    pool = wiki.RequestPool(widget.pageid, pool_size, recursive_links, widget.lang_rus, max_length);
  }
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
          return ErrorRoute(error: snapshot.error.toString());
        }
        else if (snapshot.connectionState == ConnectionState.active)
        {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Text('Загрузка определений слов... ${snapshot.data!.length}/$pool_size'),
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
                children: const [
                  CircularProgressIndicator(),
                  Text('Получение ссылок...'),
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
  int helper_count = 0;
  late Gen_Crossword crossword;
  @override
  void initState()
  {
    super.initState();
    crossword = Gen_Crossword(widget.words, widget.size, widget.buf_inc);
    Words = crossword.GetWordList();
  }

  @override
  Widget build(BuildContext context) {
    var def = Definition(source: chosen == -1?Words[0]:Words[chosen], index: chosen_let, num: crossword.word_count);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(  //Подведение итогов
          onPressed: () {
            Navigator.pushNamed(context, '/final', arguments: [helper_count, Words]);
          },
          icon: const Icon(Icons.close),
        ),
        actions: [  //Подсказки
          IconButton(  //Вывод первого изображения из статьи
            onPressed: () {
              if (Words[chosen].picture_url != '' && !Words[chosen].pic_showed)
              {
                helper_count++;
              }
              HelperShowPic(context);
            },
            color: Words[chosen].picture_url == '' ? Colors.grey : (Words[chosen].pic_showed ? Colors.green[100] : Colors.white),
            icon: const Icon(Icons.photo),
          ),
          IconButton(  //Расширение описания
            onPressed: () {
              if (Words[chosen].ext_definition != '')
              {
                helper_count++;
              }
              HelperExtendDef();
            },
            color: Words[chosen].ext_definition != '' ? Colors.white : Colors.grey,
            icon: const Icon(Icons.text_snippet),
          ),
          IconButton(  //Раскраска кроссворда - неправильные буквы будут помечены красным, пока не будут изменены
            onPressed: () {
              HelperShowErrors();
            },
            icon: const Icon(Icons.color_lens),
          ),
          IconButton(  //Вставка правильной буквы в рандомную пустую клетку
            onPressed: () {
              HelperRandomLetters(3);
            },
            icon: const Icon(Icons.font_download),
          ),
        ],
      ),
      bottomSheet: def,
      body: Builder(
        builder: (BuildContext context) {
          return crossword.ToWidgetsHighlight(chosen, chosen_let, Words);
        }
      ),
    );
  }

  void HelperExtendDef()  //Расширение описания для выбранного слова
  {
    if (Words[chosen].ext_definition != '')
    {
      setState(() {
        Words[chosen].definition = Words[chosen].ext_definition;
        Words[chosen].ext_definition = '';
      });
    }
  }

  void HelperShowPic(BuildContext context)
  {
    if (Words[chosen].picture_url == '')
    {
      return;
    }
    Words[chosen].pic_showed = true;
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) { 
        return Image.network(
          Words[chosen].picture_url,
        );
      }
    );
  }

  void HelperShowErrors()
  {
    setState(() {
      for (int i = 0; i < Words[chosen].word.length; i++)
      {
        if (Words[chosen].word.substring(i, i+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")))
        {
          continue;
        }
        else if (Words[chosen].word.substring(i, i+1) == Words[chosen].in_word.substring(i, i+1) || Words[chosen].in_word.substring(i, i+1) == '_')
        {
          continue;
        }
        else
        {
          Words[chosen].mistakes.add(i);  //Добавляем ошибку
        }
      }
      for (var inter in Words[chosen].inters)
      {
        if (inter.source == chosen &&
            Words[chosen].word.substring(inter.source_index, inter.source_index+1) != ' ' &&
            !Words[chosen].word.substring(inter.source_index, inter.source_index+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")) &&
            Words[chosen].word.substring(inter.source_index, inter.source_index+1) != Words[chosen].in_word.substring(inter.source_index, inter.source_index+1))
        {
          Words[inter.word].mistakes.add(inter.word_index);
        }
        else if (Words[chosen].word.substring(inter.word_index, inter.word_index+1) != ' ' &&
                !Words[chosen].word.substring(inter.word_index, inter.word_index+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")) &&
                Words[chosen].word.substring(inter.word_index, inter.word_index+1) != Words[chosen].in_word.substring(inter.word_index, inter.word_index+1))
        {
          Words[inter.source].mistakes.add(inter.source_index);
        }
      }
    });
  }

  void HelperRandomLetters(int count) //Вставка count букв в случайные пустые либо неправильные места
  {
    setState(() {
      //Поиск пустых и неправильных мест
      List<int> empty = [];
      List<int> wrong = [];
      for (int i = 0; i < Words[chosen].word.length; i++)
      {
        if (Words[chosen].word.substring(i, i+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")))
        {
          continue;
        }
        else if (Words[chosen].word.substring(i, i+1) != Words[chosen].in_word.substring(i, i+1)) //Неправильная ячейка
        {
          wrong.add(i);
        }
        else if (Words[chosen].in_word.substring(i, i+1) == '_')  //Пустая ячейка
        {
          empty.add(i);
        }
      }
      Random rng = Random();
      for (int i = 0; i < count; i++)
      {
        int ind;
        if (empty.isNotEmpty)
        {
          ind = empty[rng.nextInt(empty.length)];
          empty.remove(ind);
        }
        else if (wrong.isNotEmpty)
        {
          ind = wrong[rng.nextInt(wrong.length)];
          wrong.remove(ind);
        }
        else
        {
          break;
        }
        //Непосредственно сама замена
        ChangeLetter(Words[chosen].word.substring(ind, ind+1), chosen, ind);
        for(var inter in Words[chosen].inters)
        {

          if (inter.source == chosen && inter.source_index == ind)
          {
            ChangeLetter(Words[chosen].word.substring(ind, ind+1), inter.word, inter.word_index);
          }
          else if (inter.word == chosen && inter.word_index == ind)
          {
            ChangeLetter(Words[chosen].word.substring(ind, ind+1), inter.source, inter.source_index);
          }


        }
      }
    });
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
      if (Words[word_ind].mistakes.contains(let_ind))
      {
        Words[word_ind].mistakes.remove(let_ind);
      }
      if (word_ind == chosen) //Переход к следующей букве
      {
        Words[word_ind].highlighted++;
      }
      if (Words[word_ind].highlighted > Words[word_ind].length)
      {
        Words[word_ind].highlighted = -1;
      }
      crossword.field_words.setAll(0, Words);
    }); 
    if (checkForWin() == Words.length)  //Победа
    {
      Navigator.pushNamed(context, '/final', arguments: [helper_count, Words]);
    }
  }

  void EraseWord(int word_ind)  //Заменить все буквы на пробелы
  {
    setState(() {
      for (int i = 0; i < Words[word_ind].length; i++)
      {
        if (Words[word_ind].in_word.substring(i, i+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")))  //Посторонние символы
        {
          continue;
        }
        else
        {
          ChangeLetter('', word_ind, i);
        }
      }
    });
  }

  int checkForWin()  //Проверка на выигрыш
  {
    int right = 0;
    for (var word in Words)
    {
      if (word.word == word.in_word)
      {
        right++;
      }
    }
    return right;
  }
}