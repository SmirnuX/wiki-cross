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
        bottom: TabBar  //Вкладки
        (
          controller: tab_controller,
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
            ),
            Tab(
              icon: Icon(Icons.casino_rounded),
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
                      Navigator.pushNamed(context, '/cross_settings', arguments: ['https://ru.wikipedia.org/wiki/Special:Random', 'Случайная']);
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
                      Navigator.pushNamed(context, '/cross_settings', arguments: ['https://en.wikipedia.org/wiki/Special:Random', 'Случайная']);
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

class SearchTab extends StatefulWidget {  //Вкладка поиска
  const SearchTab({ Key? key }) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late Future<Map<String, String>>? search; //Результаты поиска
  TextStyle header_style = const TextStyle(fontSize: 25);
  bool language_rus = true;
  String query = '';
  @override
  void initState()
  {
    search = null; Future.value(<String, String>{});  //Пустой список
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: search,
        initialData: <String, String> {},
        builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
          Widget result;
          if (snapshot.connectionState == ConnectionState.done)
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
                          Navigator.pushNamed(context, '/cross_settings', arguments: [a.value, a.key]);
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
                        padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                        child: IconButton(
                          icon: Container(
                            child: Flag.fromCode(language_rus?FlagsCode.RU:FlagsCode.GB, borderRadius: 15.0, flagSize: FlagSize.size_1x1,),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
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
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              search = SearchWiki(query, language_rus);
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

Future <Map<String, String>> SearchWiki(String query, bool is_rus) async
{
  Uri url = Uri.parse(is_rus?
                      'https://ru.wikipedia.org/w/api.php?action=opensearch&search=${query}&limit=10&namespace=0&format=json':
                      'https://en.wikipedia.org/w/api.php?action=opensearch&search=${query}&limit=10&namespace=0&format=json');
  http.Response response = await http.get(url);
  if (response.statusCode != 200)
  {
    throw(Error());
  }
  var json_result = jsonDecode(response.body);
  if (json_result[1] == null || json_result[3] == null)
  {
    throw Error();
  }
  List<String> results = (json_result[1] as List<dynamic>).cast<String>();
  List<String> urls = (json_result[3] as List<dynamic>).cast<String>();
  if (results.isEmpty)
  {
    return <String,String>{};
  }
  Map<String,String> final_res = Map.fromIterables(results, urls);
  for (int i = 0; i < final_res.length; i++)
  {
    print('${final_res.keys.elementAt(i)}:${final_res.values.elementAt(i)}');
  }
  return final_res;
  //https://ru.wikipedia.org/w/api.php?action=opensearch&search=lego&limit=1&namespace=0&format=json
}