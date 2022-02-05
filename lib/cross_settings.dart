// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:wiki_cross/main.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GenRoute extends StatefulWidget {
  const GenRoute({ Key? key, required this.pageid, required this.title, required this.lang_rus }) : super(key: key);
  final String title;
  final int pageid;
  final bool lang_rus;
  @override
  _GenRouteState createState() => _GenRouteState();
}

class _GenRouteState extends State<GenRoute> {
  int difficulty = 1; //1 - 3
  int size = 5; //1 - 3

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(children: [
              Text(AppLocalizations.of(context)!.chosenTheme),
              Text(widget.title, style: const TextStyle(fontSize: 25), softWrap: true, textAlign: TextAlign.center,),
            ],),        
            Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Text(AppLocalizations.of(context)!.size),
                Slider(
                  onChanged: (value) {
                    setState(() {
                      size = value.toInt();
                    });  
                  },
                  value: size.toDouble(),
                  divisions: 2,
                  label: '$size',
                  min: 5,
                  max: 15,
                  activeColor: ColorTheme.GetLoadColor(context),
                  inactiveColor: ColorTheme.GetUnavailHintColor(context)
                )
              ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Text(AppLocalizations.of(context)!.difficulty),
                Slider(
                  onChanged: (value) {
                    setState(() {
                      difficulty = value.toInt();
                    });  
                  },
                  value: difficulty.toDouble(),
                  divisions: 2,
                  label: difficulty == 1? AppLocalizations.of(context)!.diffLow : (difficulty == 2 ? AppLocalizations.of(context)!.diffMedium : AppLocalizations.of(context)!.diffHard),
                  min: 1,
                  max: 3,
                  activeColor: ColorTheme.GetLoadColor(context),
                  inactiveColor: ColorTheme.GetUnavailHintColor(context)
                )
              ],),
            ],),  
            Stack(
              alignment: Alignment.center, 
              children: [
                Icon(Icons.circle, color: ColorTheme.GetROCellColor(context), size: 100),
                IconButton(
                  onPressed: () {Navigator.popAndPushNamed(context, '/crossword', arguments: GenSettings(widget.pageid, size, difficulty, widget.lang_rus));}, 
                  iconSize: 80,
                  padding: const EdgeInsets.all(0) ,
                  alignment: Alignment.center,
                  icon: Icon (Icons.play_arrow, color: ColorTheme.GetTextColor(context))
                )   
              ],
            )               
          ]
        ),
      ),
    );
  }
}

class GenSettings
{
  GenSettings(this.pageid, this.size, this.difficulty, this.lang_rus);
  int pageid;
  bool lang_rus;
  int size;
  int difficulty;
}

