/* Включает в себя следующие классы:
WordHor - горизонтальное слово
WordVer - вертикальное слово
CellCross - ячейка кроссворда
_CellFormatter - контроллер ввода для ячеек
*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class WordHor extends StatelessWidget {
  const WordHor ({ Key? key, this.length: 8 }) : super(key: key);
  final length;
  @override
  Widget build(BuildContext context) {
    //Сбор слова
    var Cells = <CellCross>[];
    for (int i = 0; i < length; i++)
    {
      Cells.add(CellCross(last: i == length-1?true:false));
    }
    return Container(
      child: FocusTraversalGroup(
        child: Row(
          children: Cells,
        ),
      ),
    );
  }
}

class WordVer extends StatelessWidget {
  const WordVer({ Key? key, this.length: 8 }) : super(key: key);
  final length;
  @override
  Widget build(BuildContext context) {
    //Сбор слова
    var Cells = <CellCross>[];
    for (int i = 0; i < length; i++)
    {
      Cells.add(CellCross(last: i == length-1?true:false));
    }
    return Container(
      child: FocusTraversalGroup(
        child: Column(
          children: Cells,
        ),
      ),
    );
  }
}

class CellCross extends StatefulWidget { //Ячейка кроссворда
  CellCross({ Key? key, required this.last, this.letter:'A'}) : super(key: key);
  final bool last; //Является ли данная ячейка последней?
  final String letter;  //Буква на этом месте
  @override
  __CellCrossState createState() => __CellCrossState();
}

class __CellCrossState extends State<CellCross> {
  final for_color = Colors.white;
  final sel_color = Colors.green[50];
  final _biggerFont = TextStyle(fontSize: 40);
  final _transparentFont = TextStyle(fontSize: 40, color: Colors.grey[100]);


  bool _focused = false;
  FocusNode myFocusNode = FocusNode();
  late _CellFormatter txt_format = _CellFormatter(node:myFocusNode, is_last:widget.last);
  //var txt = TextEditingController();
  @override
  void initState()
  {
    myFocusNode.addListener(() { 
      setState(() {
        if (myFocusNode.hasFocus != _focused) {
          setState(() {
            _focused = myFocusNode.hasFocus;
          });
        }
      });
    });
  }

  @override
  void dispose()
  {
    myFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Card(
        color: _focused?sel_color:for_color,  
        // color: for_color,
        child: InkWell(
          // onTap: () {
          //   myFocusNode.requestFocus();
          // },
          onFocusChange: (bool f) {
            if (f) {
              myFocusNode.requestFocus();
            }
          },
          child: Center(
            child: Stack(
              children: [
                Text(
                  widget.letter,
                  style: _transparentFont,
                  textAlign: TextAlign.center,

                ),
                TextField(
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  onTap: () { 
                    //myFocusNode.requestFocus();
                  },
                  cursorColor: _focused?sel_color:for_color,
                  showCursor: false,
                  focusNode: myFocusNode,
                  textInputAction: TextInputAction.next,
                  //controller: txt,
                  decoration: null,
                  style: _biggerFont,
                  textAlign: TextAlign.center,
                  maxLength: 2, //Extra character for next symbol
                  // onChanged: (String value) {
                  //   myFocusNode.nextFocus();
                  // },
                  inputFormatters: [
                    txt_format,
                  ],
                ),
              ],
            ) 
            
            
          ) 
        )
        
      )
    );
  }
}

class _CellFormatter extends TextInputFormatter {  //Форматирование текста в ячейках
  _CellFormatter ({ required this.node, required this.is_last});
  FocusNode node;
  final bool is_last;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
        print('Prev: \"$oldValue\", Next: \"$newValue\"');
        if (newValue.text.contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]"))) //Посторонние символы
        {
          return TextEditingValue();  //Сброс ячейки
        }
        if (newValue.text.length <= 1)
        {
          if (newValue.composing != TextRange.empty || Platform.isWindows)
          {
            if (!is_last)
            {
              node.nextFocus();
            }
            else
            {
              node.unfocus();
            }
          }
          return TextEditingValue(text:newValue.text.toUpperCase());
        }
        if (newValue.text.substring(1) == oldValue.text)  //Если новая буква вначале
        {
          if (!is_last)
            {
              node.nextFocus();
            }
            else
            {
              node.unfocus();
            }
          return TextEditingValue(text:newValue.text.substring(0,1).toUpperCase()); //Возвращаем первую букву
        }
        else
        {
          if (!is_last)
            {
              node.nextFocus();
            }
            else
            {
              node.unfocus();
            }
          return TextEditingValue(text:newValue.text.substring(1).toUpperCase());
        }
      }
}