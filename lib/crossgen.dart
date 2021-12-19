/* Генерация непосредственно кроссвордов


*/
import 'cells.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class Math {
  static bool interserct(int a, int b, int c, int d)
  {
    if (max(a, b) <= min (c, d))
    {
      return true;
    }
    else
    {
      return false;
    }
  }
}

class Intersection {
  Intersection({required this.index, required this.source, required this.source_index});
  int source_index; //Точка пересечения на оригинальной ячейке
  int source; //Номер слова, содержащего оригинальную ячейку
  int index;  //Точка пересечения на покрывающей ячейке
}

class Gen_Crossword {
  var field_words = <Field_Word>[]; //Непосредственно слова, расставленные по полю
  int width = 0, height = 0;  //Ширина и высота поля

  Gen_Crossword(List <String> words) {
    //Подсчет вхождений каждой буквы
    String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ';
    var let_count = List<int>.filled(59, 0);
    int all_count = 0;
    for (int i = 0; i < words.length; i++)
    {
      words[i] = words[i].toUpperCase();
    }
    for(var word in words)
    {
      //var symbols = Runes(word);
      for (int i = 0; i < word.length; i++)
      {
        var ind = letters.indexOf(word.substring(i,i+1));
        if (ind > -1 && ind < 60)
        {
          let_count[ind]++;
          all_count++;
        }
      }
    }
    //Создание списка
    var gen_words = <Gen_Word>[];
    for(var word in words)
    {
      double weight = 0;
      for (int i = 0; i < word.length; i++)
      {
        var ind = letters.indexOf(word.substring(i,i+1));
        if (ind != -1)
        {
          weight += let_count[ind].toDouble() / all_count.toDouble();
        }
      }
      var new_gen_word = Gen_Word(word: word, weight: weight);
      gen_words.add(new_gen_word);
    }
    //Сортиров очка
    gen_words.sort((a,b) => b.weight.compareTo(a.weight));
    //1. Выбираем случайно одно из первого буфера слов
    Random rng = Random();
    int buffer = 5;
    int ind = rng.nextInt(buffer);
    bool first_hor = rng.nextBool();
    field_words.add(Field_Word(hor: first_hor, word: gen_words[ind].word, x: 0, y: 0, ));
    int min_x = 0, min_y = 0, max_x = first_hor?gen_words[ind].word.length:1, max_y = !first_hor?gen_words[ind].word.length:1;
    gen_words.removeAt(ind);
    //2. Постепенный выбор новых слов и попытка их вставить в кроссворд
    bool dead_end = false;
    int target_words = 10;
    while (!dead_end && field_words.length < target_words)
    {
      buffer = buffer < gen_words.length ? buffer + 1 : gen_words.length; 
      //Выбор нового слова
      ind = rng.nextInt(buffer);
      //Попытка это слово вставить
      bool word_added = false;
      for (var fword in field_words)
      {
        //Поиск пересечений
        for (int i = 0; i < gen_words[ind].word.length; i++)
        {
          int lastFound = 0;
          lastFound = fword.word.indexOf(gen_words[ind].word.substring(i, i+1), lastFound);
          if (lastFound == -1)
          {
            continue;
          }
          else
          {
            if (CheckPlacement(gen_words[ind].word, //Проверка, можно ли расположить строку здесь
              fword.hor? fword.x + lastFound : fword.x - i, 
              fword.hor? fword.y - i : fword.y + lastFound, !fword.hor))
            {
              field_words.add(Field_Word(
                hor: !fword.hor, 
                word: gen_words[ind].word, 
                x: fword.hor? fword.x + lastFound : fword.x - i, 
                y: fword.hor? fword.y - i : fword.y + lastFound,));
              //!Добавление пересечений
              GetIntersections(field_words.length-1);
              if (fword.hor)
              {
                min_y = min(min_y, field_words.last.y);
                max_y = max(max_y, field_words.last.y + field_words.last.length);
              }
              else
              {
                min_x = min(min_x, field_words.last.x);
                max_x = max(max_x, field_words.last.x + field_words.last.length);
              }
              gen_words.removeAt(ind);
              word_added = true;
              break;
            }
          }  
        }
        if (word_added)
        {
          break;
        }
      }
      if (!word_added)
      {
        dead_end = true;
      }
    }

    //Перемещение левого верхнего угла поля в начало координат
    for (int i = 0; i < field_words.length; i++)
    {
      field_words[i].x -= min_x;
      field_words[i].y -= min_y;
    }
    //Вычисление размеров поля
    width = (max_x - min_x) * 80;
    height = (max_y - min_y) * 80;
  }
  
  bool CheckPlacement(String word, int x, int y, bool hor)
  {
    for (var ex_word in field_words)
    {
      if (ex_word.hor == hor) //Если слова параллельны
      {
        if (hor)
        {
         if (y == ex_word.y)  //На одной линии
         {
           if (Math.interserct(x, ex_word.x - 1, x + word.length, ex_word.x + 1 + ex_word.length))  //Если пересекаются или стыкуются
           {
             return false;
           }
         }
         else if (y == ex_word.y-1 || y == ex_word.y+1) //Если на соседних линиях
         {
           if (Math.interserct(x, ex_word.x, x + word.length, ex_word.x + ex_word.length))  //Если пересекаются
           {
             return false;
           }
         }
        }
        else  //Если слова вертикальные
        {
         if (x == ex_word.x)  //На одной линии
         {
           if (Math.interserct(y, ex_word.y - 1, y + word.length, ex_word.y + 1 + ex_word.length))  //Если пересекаются или стыкуются
           {
             return false;
           }
         }
         else if (x == ex_word.x-1 || x == ex_word.x+1) //Если на соседних линиях
         {
           if (Math.interserct(x, ex_word.x, x + word.length, ex_word.x + ex_word.length))  //Если пересекаются
           {
             return false;
           }
         }
        }
      }
      else  //Если слова перпендикулярны
      {
        if (hor)  //Для горизонтальных
        {
          if (ex_word.y <= y && y < ex_word.y+ex_word.length) //Если слова могут столкнуться
          {
            if (x <= ex_word.x && ex_word.x < x + word.length)  //Если слова пересекаются
            {
              if (ex_word.word.substring(y - ex_word.y, y - ex_word.y + 1) != //Если в пересечении не совпадает буква/символ
                          word.substring(ex_word.x - x, ex_word.x - x + 1))
              {
                return false;
              }
            }
            else if (x == ex_word.x + 1 || x + word.length == ex_word.x)  //Если слова касаются
            {
              return false;
            }  
          }
          else if (y == ex_word.y - 1 || y == ex_word.y + ex_word.length) //Если слова не могут пересекаться, но могут касаться
          {
            if (x <= ex_word.x && ex_word.x < ex_word.x + ex_word.length)
            {
              return false;
            }
          }
        }
        else  //Для вертикальных слов
        {
          if (ex_word.x <= x && x < ex_word.x+ex_word.length) //Если слова в принципе могут пересечься
          {
            if (y <= ex_word.y && ex_word.y < y + word.length)  //Если слова пересекаются
            {
              if (ex_word.word.substring(x - ex_word.x, x - ex_word.x + 1) != //Если в пересечении не совпадает буква/символ
                          word.substring(ex_word.y - y, ex_word.y - y + 1))
              {
                return false;
              }
            }
            else if (y == ex_word.y + 1 || y + word.length == ex_word.y)  //Если слова касаются
            {
              return false;
            }           
          }
          else if (x == ex_word.x - 1 || x == ex_word.x + ex_word.length) //Если слова не могут пересекаться, но могут касаться
          {
            if (y <= ex_word.y && ex_word.y < ex_word.y + ex_word.length)
            {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  void GetIntersections(int index)
  {
    for (int i = 0; i < field_words.length; i++)
    {
      if (index == i)
      {
        continue; //Не ищем пересечений с самим собой
      }
      if (field_words[i].hor == field_words[index].hor) 
      {
        continue; //Параллельные также не пересекаются
      }
      if (field_words[index].hor) //Горизонтальное слово
      {
        if (field_words[i].y <= field_words[index].y && field_words[index].y < field_words[i].y + field_words[i].length && 
            field_words[index].x <= field_words[i].x && field_words[i].x < field_words[index].x + field_words[index].length)
        {
          field_words[index].intersec.add(Intersection(
            source_index: field_words[index].y - field_words[i].y,
            source: i,
            index: field_words[i].x - field_words[index].x,
          ));
        }
      }
      else
      {
        if (field_words[i].x <= field_words[index].x && field_words[index].x < field_words[i].x + field_words[i].length && 
            field_words[index].y <= field_words[i].y && field_words[i].y < field_words[index].y + field_words[index].length)
        {
          field_words[index].intersec.add(Intersection(
            source_index: field_words[index].x - field_words[i].x,
            source: i,
            index: field_words[i].y - field_words[index].y,
          ));
        }
      }
    }
  }

  Widget ToWidgets()  //Неопсредственно сборка кроссворда
  {
    var word_inputs = <Words>[];
    var positioned_words = <Positioned>[];
    for (var Field in field_words)
    {
      word_inputs.add(CreateWord(Field, word_inputs));
      positioned_words.add(Positioned(
        child: word_inputs.last,
        top: Field.y.toDouble() * 80,
        left: Field.x.toDouble() * 80,
      ));
    }
    return InteractiveViewer(
        minScale: 0.001,
        maxScale: 8.0,
        boundaryMargin: EdgeInsets.all(max(width.toDouble(), height.toDouble())), //ax(w,h)
        constrained: false,
        child: SizedBox(
          width: width.toDouble(),
          height: height.toDouble(),
          child: Stack(
            //clipBehavior: Clip.none,
            children: positioned_words
            ),
        ) 
      );
  }

  Words CreateWord(Field_Word field, List<Words> other)
  {
    Widget Word_container;
    //Наполнение слова
    var Cells = <Widget>[]; //Ячейки слова
    for (int i = 0; i < field.length; i++)
    {
      //1. Проверка на пересечение
      bool is_created = false;
      for (var inters in field.intersec)
      {
        if (i == inters.index)
        {
          Cells.add(TransparentCell(
            last: i == field.length-1?true:false, 
            clone: other[inters.source],
            source: inters.source_index,
            letter: field.word.substring(i, i+1),
          ));
          is_created = true;
        }
      }
      if (!is_created)
      {
        if (field.word.substring(i, i+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")))  //Посторонние символы
        {
          Cells.add(ReadOnlyCell(
            last: i == field.length-1?true:false,
            letter: field.word.substring(i, i+1),)
          );
        }
        else
        {
          Cells.add(CellCross(
            last: i == field.length-1?true:false,
            letter: field.word.substring(i, i+1),)
          );
        }
      }
    }
    return Words (
      hor: field.hor,
      children: Cells,
    );
  }
}

class Gen_Word {  //Структура для хранения слов, используемых в генерации кроссворда
  Gen_Word ({required this.word, required this.weight});
  double weight = 0;  //Вес слова
  String word;
}

class Field_Word {  //Слово на поле
  Field_Word({required this.word, required this.hor, required this.x, required this.y})
  {
    length = word.length;
    intersec = <Intersection>[];
  }
  String word;  //Непосредственно слово
  int x, y;   //Координаты начала слова
  late int length; //Длина слова
  bool hor; //Горизонтально ли расположено слово
  late List <Intersection> intersec; //Массив, указывающий, какие ячейки являются пересечениями
}

