//Запрос и парсинг информации с Википедии

// ignore_for_file: non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'package:wiki_cross/crossgen.dart';
import 'dart:convert' as convert;

class WikiPage  //Страница с Википедии
{
  WikiPage({required this.title, required this.content, required this.links});
  // String url;
  String title;
  String content;
  // String trimmed_content;
  // String picture;
  List <String> links;
}

//Поиск по Википедии: https://en.wikipedia.org/wiki/Special:Search?search=
Future<List <Gen_Word>> RequestPage(String url) async  //Запрос страницы с википедии
{
  http.Client client = http.Client(); //Создание клиента для удобства нескольких запросов
  Uri uri = Uri.parse(url);
  var response = http.get(uri);
  http.Response got_response = await response;
  //Проверить на код 200 - ОК
  var original_page = ParseRequest(got_response);

  client.close();
  return [];
}

WikiPage ParseRequest(http.Response response) //Обработать страницу с Википедии
{
  String? header_w_tag = RegExp('<h1.*?id *= *?"firstHeading".*?class *?= *?"firstHeading mw-first-heading">.*?<\\/h1>').stringMatch(response.body); //Название вместе с тегом
  int header_index = header_w_tag!.indexOf('>');  //Поиск конца тега
  int header_end_index = header_w_tag.indexOf('</h1>', header_index+1);  //Поиск конца названия
  String header = header_w_tag.substring(header_index+1, header_end_index);  //Строка, начинающаяся с тега названия
  header = RemoveTags(header, '');
  print(header);

  //Поиск определения
  String? content_w_tag = RegExp('<div *id *= *"mw-content-text".*<p>.*<\\/p>', dotAll: true).stringMatch(response.body); //Текст вместе с тегом
  int content_start = content_w_tag!.indexOf('<p>');  //Поиск начального тега
  content_start += 3; //Пропуск тега
  int content_end = content_w_tag.indexOf('</p>', content_start); 
  String content = content_w_tag.substring(content_start, content_end);  //Строка, начинающаяся с тега названия
  content = RemoveTags(content, header);
  print(content);

  //Поиск ссылок на другие страницы Википедии
  List <String> links = GetWikiLinks(response.body, response.request!.url.toString());
  print(links.length);
  return WikiPage(title: header, content: content, links: links);
}

List <String> GetWikiLinks(String source, String link_body)
{
  List <String> result = [];
  List <String> excluded_pages = [  //Исключаемые страницы
    '/wiki/Main_Page',
    '/wiki/%D0%97%D0%B0%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F_%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0' //Заглавная страница на русском
  ];
  bool russian = link_body.startsWith('https://ru.wikipedia.org');
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
    for (var a in excluded_pages)
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
    link = link.replaceFirst('<a href="', russian?'https://ru.wikipedia.org':'https://en.wikipedia.org');
    link = link.replaceAll('"', ''); //Удаление последих кавычек
    result.add(link);
  }
  return result;
}


String RemoveTags (String source, String title) //Удаление HTML-тегов, сносок и прочего
{
  List <RegExp> excluded = [
    RegExp('<.*?>'),  //HTML-теги
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
    String firstLetter = title.substring(0, 1).toLowerCase();
    while ((result.contains(firstLetter, start_index) || result.contains(firstLetter.toUpperCase(), start_index)) && result.length > start_index + 1)
    {
      if (result.contains(title.substring(1), start_index + 1))
      {
        start_index = result.indexOf(title.substring(1), start_index + 1);
        start_index--;
        result = result.replaceRange(start_index, start_index+title.length, '________');
      }
      else
      {
        break;
      }
      start_index+=title.length;
    }
  }

  result = result.replaceAll(RegExp('\\s\\s+'), ' '); //Удаление двойных пробелов
  result = result.trim();
  return result;
}