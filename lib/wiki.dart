//Запрос и парсинг информации с Википедии

// ignore_for_file: non_constant_identifier_names

import 'package:characters/characters.dart';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:wiki_cross/crossgen.dart';
import 'dart:convert' as convert;

import 'package:wiki_cross/parser.dart';

class WikiPage  //Страница с Википедии
{
  WikiPage({required this.title, required this.content, required this.links, required this.priority});
  // String url;
  String title;
  String content;
  // String trimmed_content;
  // String picture;
  List <String> links;
  bool priority;  //Приоритет слова - если низкий, то слово не будет включаться само по себе, а будут использоваться только для рекурсивного поиска
}

Future<List <Gen_Word>> RequestPool(String url, int target, int recursive_target) async  //Запрос страницы с википедии, где target - размер пула, recursive_target - количество статей, с которых берутся ссылки
{
  List <Gen_Word> result = [];
  http.Client client = http.Client(); //Создание клиента для удобства нескольких запросов
  Uri uri = Uri.parse(url); //Парсинг URL
  var response = http.get(uri);
  http.Response got_response = await response;  //Ожидание ответа
  if (got_response.statusCode != 200) //Проверка кода HTTP
  {
    throw Error('Something went wrong ;( (HTTP code: ${got_response.statusCode}');
  }
  var original_page = ParseRequest(got_response, true); //Парсинг статьи
  List <String> pool = [];  //Пул ссылок на статьи, из которых будет выбираться целевое количество слов
  print(original_page.links.length);
  pool.addAll(original_page.links);
  pool.shuffle();
  //1. Выбираем случайные статьи, ссылки с которых также добавятся в пул
  for (int i = 0; i < recursive_target && i < pool.length; i++)
  {
    var uri = Uri.parse(pool[i]);
    var response = http.get(uri);
    if ((await response).statusCode != 200)
    {
      throw Error('Something went wrong ;( (HTTP code: ${(await response).statusCode}');
    }
    var new_page = ParseRequest(await response, true);
    print(new_page.links.length);
    pool.addAll(new_page.links);
  }
  pool.shuffle();
  print('TOTAL - ${pool.length}');
  //2. Выбираем из пула окончательный пул
  List <String> final_pool = [];  //Окончательный пул
  final_pool.add(url);  //Добавляем оригинальную страницу, чтобы он не вошел в итоговый кроссворд
  for (int i = 0; i < target && i < pool.length; i++)
  {
    //Проверка на повторы
    if (final_pool.contains(pool[i]))
    {
      pool.removeAt(i);
      i--;
      continue;
    }
    var uri = Uri.parse(pool[i]);
    var response = http.get(uri);
    if ((await response).statusCode != 200)
    {
      throw Error('Something went wrong ;( (HTTP code: ${(await response).statusCode}');
    }
    var new_page = ParseRequest(await response, false); 
    bool add = true;
    for (var p in result)
    {
      if (p.word == new_page.title)
      {
        add = false;
      }
    }
    if (new_page.priority && add)  //Если новая страница подходит для включения в кроссворд
    {
      var new_word = Gen_Word(word: new_page.title, weight: 0, definition: new_page.content);
      result.add(new_word);
      final_pool.add(pool[i]);
    }
    else
    {
      pool.removeAt(i);
      i--;
      continue;
    }
  }
  if (pool.length < target)
  {
    throw Error('Something went wrong ;( (Couldn\'t get words from this article).');
  }
  client.close();
  return result;
}

WikiPage ParseRequest(http.Response response, bool search_links) //Обработать страницу с Википедии
{
  //Поиск названия
  String? header_w_tag = RegExp('<h1.*?id *= *?"firstHeading".*?class *?= *?"firstHeading mw-first-heading">.*?<\\/h1>').stringMatch(response.body);
  int header_index = header_w_tag!.indexOf('>');  //Поиск конца тега
  int header_end_index = header_w_tag.indexOf('</h1>', header_index+1);  //Поиск конца названия
  String header = header_w_tag.substring(header_index+1, header_end_index);  //Строка, начинающаяся с тега названия
  header = RemoveTags(header, '');  //Убираем HTML-теги из заголовка

  //Проверка слова - оно не должно начинаться с цифр и не быть слишком длинным/коротким
  bool priority = true;
  if (header.startsWith(RegExp('[0-9]'))) //Если начинается с цифр - убираем слово (скорее всего, это дата)
  {
    priority = false;
  }
  if (header.contains(' ')) //Разделение предложения на слова
  {
    var split_header = header.split(' ');
    split_header.shuffle();
    bool found = false;
    for (var word in split_header)
    {
      if (word.length < 20 && word.length > 1)
      {
        header = word;
        found = true;
        break;
      }
    }
    if (!found)
    {
      priority = false;
    }
  }
  int st_index = header.indexOf(RegExp(r"[a-zA-Zа-яА-ЯёЁ]"));
  int end_index = header.lastIndexOf(RegExp(r"[a-zA-Zа-яА-ЯёЁ]"));
  if (st_index == -1 || end_index == st_index)
  {
    priority = false;
  }
  else
  {
    header = header.substring(st_index, end_index+1);
    if (header.length >= 20 || header.length <= 2)
    {
      priority = false;
    }
  }

  if (priority)
  {
    header = header.toUpperCase();
    print(header);
  }
  int str_limit = 500;
  String? content;
  if (priority)
  {
    //Поиск определения
    int tag_start = response.body.indexOf(RegExp('<div *id *= *"mw-content-text".*<p>.*<\\/p>', dotAll: true)); //Индекс начала тега
    String temp_source = response.body.substring(tag_start, max(response.body.length, tag_start+str_limit));  //Содержимое страницы
    String content_w_tag = temp_source.replaceAll(RegExp('<table.*?<\\/table>', dotAll: true), '');  //Удаление таблиц
    content_w_tag = content_w_tag.replaceAll(RegExp('<td.*?<\\/td>', dotAll: true), '');  //Доудаление таблиц
    int content_start = content_w_tag.indexOf('<p>');  //Поиск начального тега
    content_start += 3; //Пропуск тега
    int content_end = content_w_tag.indexOf('</p>', content_start); 
    content = content_w_tag.substring(content_start, content_end);  //Строка, начинающаяся с тега названия
    content = CleanText(content, header);
    //Оптимальная длина составляет около 200 символов.
    content = TrimContent(content, 300);
    print(content);
  }

  //Поиск ссылок на другие страницы Википедии
  List <String> links;
  if (search_links)
  {
    links = GetWikiLinks(response.body, response.request!.url.toString());
  }
  else
  {
    links = [];
  }
  return WikiPage(title: header, content: priority?content!:'', links: links, priority: priority);
}

List <String> GetWikiLinks(String source, String link_body) //Получить все ссылки со страницы
{
  //TODO - ресурсозатратно, увеличивает время загрузки страницы
  List <String> result = [];
  List <String> excluded_pages = [  //Исключаемые страницы
    '/wiki/Main_Page',
    '/wiki/%D0%97%D0%B0%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F_%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0' //Заглавная страница на русском
  ];
  bool russian = link_body.startsWith('https://ru.wikipedia.org');  //Какая википедия выбрана
  int index = 0;
  while (source.contains(RegExp('<a href="\\/wiki\\/.*?"'), index))  //Поиск локальных ссылок
  {
    index = source.indexOf(RegExp('<a href="\\/wiki\\/.*?"'), index); 
    String? link = RegExp('<a href="\\/wiki\\/.*?"').stringMatch(source.substring(index));
    //Проверка на ненужные страницы
    if (link == null)
    {
      break;
    }
    index++;
    if (link.contains(':')) //Исключение страниц типа /wiki/File: и прочих
    {
      continue;
    }
    bool to_add = true;
    for (var a in excluded_pages) //Проверка, есть ли она в списке исключенных страниц
    {
      if (link.contains(a))
      {
        to_add = false;
        break;
      }
    }
    if (!to_add)
    {
      continue;
    }
    link = link.replaceFirst('<a href="', russian?'https://ru.wikipedia.org':'https://en.wikipedia.org'); //Замена тега на url сайта
    link = link.replaceAll('"', ''); //Удаление последих кавычек
    result.add(link);
  }
  return result;
}


String RemoveTags (String source, String title) //Удаление HTML-тегов, сносок и прочего
{
  List <RegExp> excluded = [
    RegExp('<.*?>'),  //HTML-теги
    RegExp('\\[.*?\\]'), //Квадратные скобки
    RegExp('\\(.*?\\)'), //Все в скобках (в основном этим убираются переводы)
    RegExp('&#91;.*?&#93;'), //Выноски (наподобие [1] и т.д.),
    RegExp('&#.*?;'),  //Все остальные не отображающиеся символы
    RegExp('\u0301'),  //Ударение
  ];
  String result = source;
  for (var regex in excluded)
  {
    result = result.replaceAll(regex, '');  //Удаление всех символов
  }
  result = result.replaceAll("&amp;", '&');
  if (title != '')  //Удаление искомого слова из определения
  {
    int start_index = 0;
    String firstLetter = title.substring(0, 1); //Первая буква слова
    while ((result.contains(firstLetter, start_index) || result.contains(firstLetter.toLowerCase(), start_index)) )
    {
      if (result.contains(title.toLowerCase().substring(1), start_index + 1))
      {
        start_index = result.indexOf(title.toLowerCase().substring(1), start_index + 1);
        start_index--;
        result = result.replaceRange(start_index, start_index+title.length, '________');
      }
      else
      {
        break;
      }
      start_index+=title.length;
      if (result.length > start_index + 1)
      {
        break;
      }
    } 
  }
  else  //Если это само слово, а не его определение
  { 
    int start_index = 0;  //Убираем символы, окруженные пробелами (&,- и т.д.)
    while ((result.contains(RegExp(' [^a-zA-Zа-яА-ЯёЁ] '), start_index)))
    {
      start_index = result.indexOf(RegExp(' [^a-zA-Zа-яА-ЯёЁ] '), start_index);
      result = result.replaceRange(start_index, start_index+2, result.substring(start_index+1, start_index+2));
    } 
  }
  result = result.replaceAll(RegExp('\\s\\s+'), ' '); //Удаление двойных пробелов
  result = result.trim();
  return result;
}

String TrimContent(String str, int target)  //Обрезать определение
{
  if (str.length < target)
  {
    return str;
  }
  int ind = str.indexOf('.');
  if (ind < target)
  {
    return str.substring(0, ind+1);
  }
  var res = str.substring(0, target);
  var end = res.lastIndexOf(' ');
  res = res.replaceRange(end, null, '...');
  return res;
}

class Error { //Ошибка
  Error(this.cause);
  String cause;
}