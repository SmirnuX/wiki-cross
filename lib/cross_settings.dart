import 'package:flutter/material.dart';

class GenRoute extends StatefulWidget {
  GenRoute({ Key? key, required this.url, required this.title }) : super(key: key);
  String url, title;
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
              Text('Выбранная тема:'),
              Text(widget.title, style: const TextStyle(fontSize: 25), softWrap: true,),
            ],),        
            Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Text('Размер:'),
                Slider(
                  onChanged: (value) {
                    setState(() {
                      size = value.toInt();
                    });  
                  },
                  value: size.toDouble(),
                  divisions: 3,
                  label: '$size',
                  min: 5,
                  max: 20,

                )
              ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Text('Сложность:'),
                Slider(
                  onChanged: (value) {
                    setState(() {
                      difficulty = value.toInt();
                    });  
                  },
                  value: difficulty.toDouble(),
                  divisions: 2,
                  label: difficulty == 1? 'Низкая' : (difficulty == 2 ? 'Средняя' : 'Высокая'),
                  min: 1,
                  max: 3,
                )
              ],),
            ],),  
            Stack(
              alignment: Alignment.center, 
              children: [
                const Icon(Icons.circle, color: Colors.blue, size: 100),
                IconButton(
                  onPressed: () {Navigator.pushNamed(context, '/crossword', arguments: GenSettings(widget.url, size, difficulty));}, 
                  iconSize: 80,
                  padding: const EdgeInsets.all(0) ,
                  alignment: Alignment.center,
                  icon: const Icon (Icons.play_arrow, color: Colors.white)
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
  GenSettings(this.url, this.size, this.difficulty);
  String url;
  int size;
  int difficulty;
}

