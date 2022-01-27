import 'package:flutter/material.dart';

class FinalRoute extends StatelessWidget {
  FinalRoute({ Key? key, this.hints : 0, this.right : 0, this.all : 0 }) : super(key: key);
  int hints, right, all;

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(right == all ? 'Кроссворд решен' : 'Кроссворд не решен', style: const TextStyle(fontSize: 25),),
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.circle, color: right == all? Colors.green[200] : Colors.red[200], size: 240),
                Icon (right == all? Icons.done : Icons.close, color: Colors.white, size: 180)
              ],
            ),
            Column(children: [
              Text('Подсказок использовано: $hints'),
              Text(right == all ? ' ' : 'Правильных слов: $right/$all') 
            ],),  
            Stack(
              alignment: Alignment.center, 
              children: [
                Icon(Icons.circle, color: Colors.blue[200], size: 100),
                IconButton(
                  onPressed: () {Navigator.pushNamed(context, '/');}, 
                  iconSize: 80,
                  padding: const EdgeInsets.all(0) ,
                  alignment: Alignment.center,
                  icon: Icon (Icons.home, color: Colors.white)
                )   
              ],
            )  

          ]
        ),
      ),
    );
  }
}

