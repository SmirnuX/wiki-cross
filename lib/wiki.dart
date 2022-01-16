//Запрос и парсинг информации с Википедии

// ignore_for_file: non_constant_identifier_names

/*
  List <Gen_Words> GetWords;  //Получить список слов и их определений

*/

import 'package:http/http.dart' as http;
import 'package:wiki_cross/crossgen.dart';
import 'dart:convert' as convert;


//Поиск по Википедии: https://en.wikipedia.org/wiki/Special:Search?search=
Future<List <Gen_Word>> RequestPage(String url) async  //Запрос страницы с википедии
{
  http.Client client = http.Client(); //Создание клиента для удобства нескольких запросов
  Uri uri = Uri.parse(url);
  var response = http.get(uri);
  http.Response got_response = await response;
  //Проверить на код 200 - ОК
  ParseRequest(got_response);

  client.close();
  return [];
}

void ParseRequest(http.Response response) //Обработать страницу с Википедии
{
  String? header_w_tag = RegExp('<h1.*?id *= *?"firstHeading".*?class *?= *?"firstHeading mw-first-heading">.*?<\\/h1>').stringMatch(response.body); //Название вместе с тегом
  int header_index = header_w_tag!.indexOf('>');  //Поиск конца тега
  if (header_w_tag.contains('<i>'))  //Если название написано курсивом 
  {
    header_index = header_w_tag.indexOf('<i>')+2; //TODO - убирать все теги из названия
  }
  int header_end_index = header_w_tag.indexOf('<', header_index+1);  //Поиск конца названия
  String header = header_w_tag.substring(header_index+1, header_end_index);  //Строка, начинающаяся с тега названия
  print(header);

  //Поиск определения
  String? content_w_tag = RegExp('<div *id *= *"mw-content-text".*<p>.*<\\/p>', dotAll: true).stringMatch(response.body); //Текст вместе с тегом
  int content_start = content_w_tag!.indexOf('<p>');  //Поиск начального тега
  content_start += 3; //Пропуск тега
  int content_end = content_w_tag.indexOf('</p>', content_start); 
  String content = content_w_tag.substring(content_start, content_end);  //Строка, начинающаяся с тега названия
  print(content);
}


class WikiPage  //Страница с Википедии
{
  // String url;
  String title;
  String content;
  // String trimmed_content;
  // String picture;
  List <String> links;
}