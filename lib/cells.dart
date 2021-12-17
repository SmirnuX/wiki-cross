/* Включает в себя следующие классы:
CellCross - ячейка кроссворда
TransparentCell - прозрачная ячейка кроссворда, для случаев пересечения
ReadOnlyCell - ячейка с неизменяемым содержимым, для случаев посторонних символов
_CellFormatter - контроллер ввода для ячеек
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Words extends StatelessWidget {
  Words ({ Key? key, required this.hor, required this.children}) : super(key: key);
  var children = <Widget>[];
  bool hor;
  @override
  Widget build(BuildContext context) {
    Widget WordContainer;
    if (hor)
    {
      WordContainer = Row(children: children,);
    }
    else
    {
      WordContainer = Column(children: children,);
    }
    return FocusTraversalGroup(
      child: WordContainer,
    );
  }

  void ChangeLetter(String let, int index)
  {
    dynamic child = children[index];
    if (child.runtimeType == CellCross)
    {
      try
      {
      child.setText(let);
      }
      on NoSuchMethodError 
      {
        print('setText not found');
        return;
      }
    }
  }
  
  void ChangeFocus(bool value, int index)
  {
    dynamic child = children[index];
    if (child.runtimeType == CellCross)
    {
      try
      {
      child.setHighlighted(value);
      }
      on NoSuchMethodError 
      {
        print('setHighlighted not found');
        return;
      }
    }
  }
}

class CellCross extends StatefulWidget { //Ячейка кроссворда
  CellCross({ Key? key, required this.last, this.letter:'A', this.pseudo_focused:false}) : super(key: key);
  final bool last; //Является ли данная ячейка последней?
  String letter;  //Буква на этом месте
  @override
  __CellCrossState createState() => __CellCrossState();
  var txt_controller = TextEditingController();
  bool pseudo_focused;
  ValueNotifier <bool> notifier = ValueNotifier(false);

  void setText(String let)
  {
    txt_controller.text = let;
  }

  void setHighlighted(bool value)
  {
    pseudo_focused = value;
    notifier.value = value;
  }

}

class __CellCrossState extends State<CellCross> {
  final for_color = Colors.white;
  final sel_color = Colors.green[50];
  final _biggerFont = TextStyle(fontSize: 40);
  final _transparentFont = TextStyle(fontSize: 40, color: Colors.grey[600]);
  bool _focused = false;
  FocusNode myFocusNode = FocusNode();
  late _CellFormatter txt_format = _CellFormatter(node:myFocusNode, is_last:widget.last);
  late TextField txt;
  
 
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
    txt = TextField(
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      onTap: () { 
        //myFocusNode.requestFocus();
      },
      cursorColor: (_focused || widget.pseudo_focused)?sel_color:for_color,
      showCursor: false,
      focusNode: myFocusNode,
      textInputAction: TextInputAction.next,
      controller: widget.txt_controller,
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
    );
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
      child: ValueListenableBuilder(
        valueListenable: widget.notifier,
        builder: (BuildContext context, bool smth, Widget? child) {
          return Card(
            color: (_focused || widget.pseudo_focused)?sel_color:for_color, 
            child: InkWell(
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
                    txt,
                  ],
                )   
              ) 
            )     
          );
        },
      )   
    );
  }
}

//TransparentCell - прозрачная ячейка кроссворда, для случаев пересечения
class TransparentCell extends StatefulWidget { //Ячейка кроссворда
  TransparentCell({ Key? key, required this.last, this.letter:'A', required this.clone, required this.source}) : super(key: key);
  final bool last; //Является ли данная ячейка последней?
  final String letter;  //Буква на этом месте
  final Words clone;
  final int source;
  @override
  __TransparentCellState createState() => __TransparentCellState();
}

class __TransparentCellState extends State<TransparentCell> {
  bool _focused = false;
  FocusNode myFocusNode = FocusNode();
  late _CellFormatter txt_format = _CellFormatter(node:myFocusNode, is_last:widget.last);
  late TextField txt;

  @override
  void initState()
  {
    myFocusNode.addListener(() { 
      setState(() {
        if (myFocusNode.hasFocus != _focused) {
          setState(() {
            _focused = myFocusNode.hasFocus;
            widget.clone.ChangeFocus(_focused, widget.source);
          });
        }
      });
    });
    txt = TextField(
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      onTap: () { 
        //myFocusNode.requestFocus();
      },
      showCursor: false,
      focusNode: myFocusNode,
      textInputAction: TextInputAction.next,
      //controller: txt,
      decoration: null,
      textAlign: TextAlign.center,
      maxLength: 2, //Extra character for next symbol
      onChanged: (String value) {
        widget.clone.ChangeLetter(value, widget.source);
      },
      inputFormatters: [
        txt_format,
      ],
    );
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
      child: Opacity(
        opacity: 0.0,
        child: InkWell(
          onFocusChange: (bool f) {
            if (f) {
              myFocusNode.requestFocus();
            }
            widget.clone.ChangeFocus(f, widget.source);
          },
          child: txt,
        )       
      )
    );
  }
}

// ReadOnlyCell - ячейка с неизменяемым содержимым, для случаев посторонних символов
class ReadOnlyCell extends StatefulWidget { //Ячейка кроссворда
  ReadOnlyCell({ Key? key, required this.last, this.letter:'A'}) : super(key: key);
  final bool last; //Является ли данная ячейка последней?
  final String letter;  //Буква на этом месте
  @override
  __ReadOnlyCellState createState() => __ReadOnlyCellState();
}

class __ReadOnlyCellState extends State<ReadOnlyCell> {
  final for_color = Colors.grey[200];
  final _biggerFont = TextStyle(fontSize: 40);
  bool _focused = false;
  FocusNode myFocusNode = FocusNode();

  @override
  void initState()
  {
    myFocusNode.addListener(() { 
      setState(() {
        if (myFocusNode.hasFocus != _focused) {
          setState(() {
            if (widget.last)
            {
              myFocusNode.unfocus();
            }
            else
            {
              myFocusNode.nextFocus();
            }
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
        color: for_color, 
        child: InkWell(
          onFocusChange: (bool f) {
            if (f) {
              if (widget.last)
              {
                myFocusNode.unfocus();
              }
              else
              {
                myFocusNode.nextFocus();
              }
            }
          },
          child: Center(
            child: Text(
              widget.letter,
              style: _biggerFont,
            ),
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