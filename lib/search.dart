// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flag/flag.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchRoute extends StatefulWidget //Страница поиска
{
  final TextStyle _bigger = const TextStyle(
    fontSize: 20,
  );

  @override
  State<SearchRoute> createState() => _SearchRouteState();
}

class _SearchRouteState extends State<SearchRoute> with SingleTickerProviderStateMixin
{
  late TabController tab_controller;

  @override
  void initState() {
    super.initState();
    tab_controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar  //Вкладки
        (
          controller: tab_controller,
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
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
          SearchTab(),
          Text('Темы')  //Темы
        ]
      ) 
    );
  }
}

class SearchTab extends StatefulWidget {  //Вкладка поиска
  const SearchTab({ Key? key }) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late Future<Map<String, int>>? search; //Результаты поиска
  TextStyle header_style = const TextStyle(fontSize: 25);
  bool language_rus = true;
  String query = '';
  @override
  void initState()
  {
    search = null; 
    // search = Future.value(<String, int>{});  //Пустой список
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: search,
        initialData: const <String, int> {},
        builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
          Widget result;
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null)
          {
            if (snapshot.data!.isEmpty) //Если запрос не дал результата
            {
              result = (Column(
               children: const [
                 Icon(Icons.cancel, color: Colors.red,),
                 Text('По вашему запросу ничего не найдено.')
               ] 
              ));
            }
            else  //Выдача списка
            {
              List<Widget> result_list = [];
              for(var a in snapshot.data!.entries)
              {
                result_list.add(
                  IntrinsicWidth(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/cross_settings', arguments: [a.value, a.key, language_rus]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),child: Text(
                            a.key,
                            style: header_style
                          ),
                        )
                      ))
                  )
                );
              }
              result = Expanded(
                child: ListView(children: result_list,)
              );
              
            }
          }
          else if(snapshot.connectionState == ConnectionState.none)
          {
            result = Center(child: Text('Введите название статьи из Википедии, по которой вы хотели бы начать кроссворд'),);
          }
          else if (snapshot.hasError)
          {
            result = Center(child: Text('Ошибка запроса: ${snapshot.error}'),);
          }
          else
          {
            result = CircularProgressIndicator();
          }
          return Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                heightFactor: 1,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  child:Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 2, 8),
                        child: IconButton(
                          splashRadius: 28,
                          icon: Container(
                            // alignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(0.7, 0.7, 0.7) + Matrix4.translationValues(1.6, 1.6, 1.6),
                            child: Flag.fromCode(language_rus?FlagsCode.RU:FlagsCode.GB, borderRadius: 0.0, flagSize: FlagSize.size_1x1,),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),     
                          onPressed: () {
                            setState(() {
                              language_rus = !language_rus;
                            });
                          },
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(2, 8, 8, 8),
                        child: IconButton(
                          splashRadius: 28,
                          icon: Icon(Icons.casino_outlined),  
                          onPressed: () {
                            setState(() {
                              search = SearchRandom(language_rus);
                            });
                          },
                        )
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                          child:TextField(
                            decoration: null,
                            onChanged: (str) {
                              query = str;
                            },
                            onEditingComplete: () {
                              setState(() {
                                if (query != '')
                                {
                                  search = SearchWiki(query, language_rus);
                                }    
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 16, 8),
                        child: snapshot.connectionState == ConnectionState.done || snapshot.connectionState == ConnectionState.none ? 
                        IconButton(
                          splashRadius: 28,
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              if (query != '')
                              {
                                search = SearchWiki(query, language_rus);
                              }
                            });
                          },
                        ) :
                        CircularProgressIndicator()
                      ),
                    ]
                  ) 
                ),
              ),
              result,
            ]
          );
        }
      )
    );
  }
}

Future <Map<String, int>> SearchWiki(String query, bool is_rus) async
{
  Uri url = Uri.parse(is_rus
                      ?'https://ru.wikipedia.org/w/api.php?action=query&list=search&srsearch=${query}&srlimit=10&srnamespace=0&format=json'
                      :'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=${query}&srlimit=10&srnamespace=0&format=json');
  http.Response response = await http.get(url);
  if (response.statusCode != 200)
  {
    throw(Error());
  }
  var json_result = jsonDecode(response.body);
  if (json_result['query'] == null)
  {
    throw Error();
  }
  List<dynamic> results = json_result['query']['search'] as List<dynamic>;
  if (results.isEmpty)
  {
    return <String,int>{};
  }
  Map<String,int> final_res = {};
  for (int i = 0; i < results.length; i++)
  {
    final_res.putIfAbsent(results[i]['title'], () => results[i]['pageid']);
  }
  return final_res;
}

Future <Map<String, int>> SearchRandom(bool is_rus) async
{
  Uri url = Uri.parse(is_rus
                      ?'https://ru.wikipedia.org/w/api.php?action=query&list=random&rnlimit=10&rnnamespace=0&format=json'
                      :'https://en.wikipedia.org/w/api.php?action=query&list=random&rnlimit=10&rnnamespace=0&format=json');
  http.Response response = await http.get(url);
  if (response.statusCode != 200)
  {
    throw(Error());
  }
  var json_result = jsonDecode(response.body);
  if (json_result['query'] == null)
  {
    throw Error();
  }
  List<dynamic> results = json_result['query']['random'] as List<dynamic>;
  if (results.isEmpty)
  {
    return <String,int>{};
  }
  Map<String,int> final_res = {};
  for (int i = 0; i < results.length; i++)
  {
    final_res.putIfAbsent(results[i]['title'], () => results[i]['id']);
  }
  return final_res;
}