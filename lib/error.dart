import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            Text(AppLocalizations.of(context)!.error, style: TextStyle(fontSize: 25, color: ColorTheme.GetTextColor(context)),),
            Stack(
              alignment: Alignment.center,
              children: const [
                Icon (Icons.error_outline, color: Colors.red, size: 180)
              ],
            ),
            Column(children: [
              Text(error != '' ? error : AppLocalizations.of(context)!.errorUnknown),
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
    
    
    
