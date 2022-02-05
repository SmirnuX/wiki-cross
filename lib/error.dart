import 'package:flutter/material.dart';
import 'main.dart';

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
            const Text('Ошибка', style: TextStyle(fontSize: 25, color: ColorTheme.TextColor),),
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
                Icon(Icons.circle, color: ColorTheme.GetROCellColor(context), size: 100),
                IconButton(
                  onPressed: () {Navigator.popAndPushNamed(context, '/');}, 
                  iconSize: 60,
                  padding: const EdgeInsets.all(0) ,
                  alignment: Alignment.center,
                  icon: Icon (Icons.home, color: ColorTheme.GetTextColor(context))
                )   
                 
              ],
            )  

          ]
        ),
      ),
    );
  }
}    
    
    
    
