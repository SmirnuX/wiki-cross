// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:wiki_cross/crossgen.dart';
import 'crossgen.dart';
import 'main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FinalRoute extends StatelessWidget {
  FinalRoute({ Key? key, this.hints = 0, required this.words}) : super(key: key)
  {
    TextStyle wrong_st = TextStyle(fontSize: 20, color: Colors.red[400]);
    TextStyle right_st = TextStyle(fontSize: 20, color: Colors.green[400]);
    all = words.length;
    right = 0;
    List<Widget> wrong_words = [];
    List<Widget> right_words = [];
    for (var a in words)
    {
      List <TextSpan> wrong_word = [];
      List <TextSpan> right_word = [];
      if (a.word != a.in_word)
      {
        for (int i = 0; i < a.word.length; i++)
        {
          if (a.word.substring(i, i+1) != a.in_word.substring(i, i+1))
          {
            wrong_word.add(TextSpan(text: a.in_word.substring(i, i+1), style: wrong_st));
            right_word.add(TextSpan(text: a.word.substring(i, i+1), style: wrong_st));
          }
          else
          {
            wrong_word.add(TextSpan(text: a.in_word.substring(i, i+1), style: right_st));
            right_word.add(TextSpan(text: a.word.substring(i, i+1), style: right_st));
          }
        }
        wrong_words.add(RichText(text: TextSpan(children: wrong_word),));
        right_words.add(RichText(text: TextSpan(children: right_word),));
      }
      else
      {
        right++;
      }
    }
    if (wrong_words.isNotEmpty)
    {
      for (int i = 0; i < wrong_words.length; i++)
      {
        words_list.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.max,children: [wrong_words[i], right_words[i]],));
      }
    }
  }
  final int hints;
  late int right;
  late int all;
  List<Widget> words_list = [];
  final List<Field_Word> words;

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(right == all ? AppLocalizations.of(context)!.crossSolved : AppLocalizations.of(context)!.crossNotSolved, 
                                style: TextStyle(fontSize: 25, color: ColorTheme.GetTextColor(context)),),
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.circle, color: right == all? Colors.green[200] : Colors.red[200], size: 240),
                Icon (right == all? Icons.done : Icons.close, color: Colors.white, size: 180)
              ],
            ),
            Column(children: [
              Text('${AppLocalizations.of(context)!.hintsUsed} $hints'),
              Text(right == all ? ' ' : '${AppLocalizations.of(context)!.rightWords} $right/$all') 
            ],),  
            words_list.isEmpty?const SizedBox.shrink() :ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(ColorTheme.GetCellColor(context)),
              ),
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return DraggableScrollableSheet(
                    expand: false,
                    minChildSize: 0.5,
                    maxChildSize: 0.8,
                    initialChildSize: 0.5,
                    builder: (BuildContext context, ScrollController scrollController) {
                      return Dialog(
                        backgroundColor: ColorTheme.GetBackColor(context),
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: all-right,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(child: ListTile(title: words_list[index]));
                          },
                        )
                      );
                    }
                  );
                });
              }, 
              child: Text(AppLocalizations.of(context)!.showWrongWords, style: TextStyle(color: ColorTheme.GetTextColor(context)),)),
            Stack(  //Кнопка возврата на главный экран
              alignment: Alignment.center, 
              children: [
                Icon(Icons.circle, color: ColorTheme.GetROCellColor(context), size: 100),
                IconButton(
                  onPressed: () {Navigator.popAndPushNamed(context, '/');}, 
                  iconSize: 60,
                  padding: const EdgeInsets.all(0) ,
                  alignment: Alignment.center,
                  icon: Icon (Icons.home, color: ColorTheme.GetTextColor(context))
                )   
              ],
            ),
          ]
        ),
      ),  
    );
  }
}

