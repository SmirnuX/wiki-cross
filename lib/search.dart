// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flag/flag.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'main.dart';

class SearchRoute extends StatefulWidget //Страница поиска
{
  const SearchRoute({ Key? key}) : super(key: key);

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
          indicatorColor: ColorTheme.GetTextColor(context),
          controller: tab_controller,
          tabs: [
            Tab(
              icon: Icon(Icons.search, color: ColorTheme.GetTextColor(context)),
            ),
            Tab(
              icon: Icon(Icons.photo_size_select_actual_rounded, color: ColorTheme.GetTextColor(context)),
            ),
          ],
        ),
        backgroundColor: ColorTheme.GetAppBarColor(context), 
      ),
      body: TabBarView(
        controller: tab_controller,
        children:const [
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
  late bool language_rus;
  String query = '';
  @override
  void initState()
  {
    super.initState();
    language_rus = true;
    search = null; 
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
              result = (
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const Icon(Icons.cancel, color: Colors.red,),
                      Text(AppLocalizations.of(context)!.searchNoResults)
                    ] 
                  )
                )
              );
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
            result = Padding(
              padding: const EdgeInsets.all(8),
              child: Center(child: Text(AppLocalizations.of(context)==null?'':AppLocalizations.of(context)!.searchEnterQuery),));
          }
          else if (snapshot.hasError)
          {
            result = Center(child: Text('${AppLocalizations.of(context)!.searchError}: ${snapshot.error}'),);
          }
          else
          {
            result = const SizedBox.shrink();
          }
          return Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                heightFactor: 1,
                child: Card(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  child:Row(
                    children: [
                      Padding(  //Выбор языка
                        padding: const EdgeInsets.fromLTRB(16, 8, 2, 8),
                        child: IconButton(
                          splashRadius: 28,
                          icon: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              alignment: Alignment.center,
                              width: kIsWeb? 32 : (Platform.isAndroid ? 20 : 32),  //Подстраивание под размер MaterialIcon (16/20 -> 32/40 -> 28/36 (с вычетом обводки))
                              height: kIsWeb? 32 : (Platform.isAndroid ? 20 : 32),
                              child: Flag.fromCode(language_rus?FlagsCode.RU:FlagsCode.GB, borderRadius: 3.0, flagSize: FlagSize.size_1x1,),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: ColorTheme.GetTextColor(context),
                                  width: 2,
                                ),
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
                        padding: const EdgeInsets.fromLTRB(2, 8, 8, 8),
                        child: IconButton(
                          splashRadius: 28,
                          icon: Icon(Icons.casino_outlined, color: ColorTheme.GetTextColor(context)),  
                          onPressed: () {
                            setState(() {
                              search = SearchRandom(language_rus);
                            });
                          },
                        )
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                          child:TextField(
                            cursorColor: ColorTheme.GetTextColor(context),
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
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                        child: snapshot.connectionState == ConnectionState.done || snapshot.connectionState == ConnectionState.none ? 
                        IconButton(
                          splashRadius: 28,
                          icon: Icon(Icons.search, color: ColorTheme.GetTextColor(context)),
                          onPressed: () {
                            setState(() {
                              if (query != '')
                              {
                                search = SearchWiki(query, language_rus);
                              }
                            });
                          },
                        ) :
                        CircularProgressIndicator(color: ColorTheme.GetLoadColor(context))
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
                      ?'https://ru.wikipedia.org/w/api.php?action=query&list=search&srsearch=$query&srlimit=10&srnamespace=0&format=json&origin=*'
                      :'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$query&srlimit=10&srnamespace=0&format=json&origin=*');
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
                      ?'https://ru.wikipedia.org/w/api.php?action=query&list=random&rnlimit=10&rnnamespace=0&format=json&origin=*'
                      :'https://en.wikipedia.org/w/api.php?action=query&list=random&rnlimit=10&rnnamespace=0&format=json&origin=*');
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