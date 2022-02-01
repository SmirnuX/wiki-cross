import 'package:flutter/material.dart';

class ErrorRoute extends StatelessWidget {
  ErrorRoute({ Key? key, required this.error }) : super(key: key);
  String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Ошибка', style: const TextStyle(fontSize: 25),),
            Stack(
              alignment: Alignment.center,
              children: const [
                Icon (Icons.error_outline, color: Colors.red, size: 180)
              ],
            ),
            Column(children: [
              Text(error != '' ? error : 'Произошла неизвестная ошибка.'),
            ],),  
            Stack(
              alignment: Alignment.center, 
              children: [
                Icon(Icons.circle, color: Colors.blue[200], size: 100),
                IconButton(
                  onPressed: () {Navigator.pushNamed(context, '/');}, 
                  iconSize: 60,
                  padding: const EdgeInsets.all(0) ,
                  alignment: Alignment.center,
                  icon: const Icon (Icons.home, color: Colors.white)
                )   
              ],
            )  

          ]
        ),
      ),
    );
  }
}    
    
    
    
