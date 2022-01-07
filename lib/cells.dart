// Ячейки, слова из ячеек и их форматирование
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:wiki_cross/crossgen.dart';
import 'main.dart';

class Word extends StatelessWidget {
  const Word ({ Key? key, required this.hor, required this.children, required this.parent, required this.index}) : super(key: key);
  final List<Widget> children;
  final Field_Word parent;
  final int index;
  final bool hor;
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

  void ChangeLetter(String let, int index)  //Изменить букву под номером index на let
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
        // print('setText not found');
        return;
      }
    }
    parent.in_word.replaceRange(index, index+1, let);
  }
  
  void ChangeFocus(bool value, int index) //Подсветить ячейку под номером index
  {
    dynamic child = children[index];
    if (child.runtimeType == CellCross)
    {
      try
      {
        child.setHighlighted(value);
        // print('Highlight');
      }
      on NoSuchMethodError 
      {
        print('setHighlighted not found');
        return;
      }
    }
    // parent.highlighted = value?index:-1;
  }
}

class CellCross extends StatefulWidget { //Ячейка кроссворда
  CellCross({ Key? key, required this.last, this.letter:'A', this.pseudo_focused:false, required this.let_ind, required this.word_ind}) : super(key: key);
  final bool last; //Является ли данная ячейка последней?
  final int let_ind;
  final int word_ind;
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
  final _biggerFont = const TextStyle(fontSize: 40);
  final _transparentFont = TextStyle(fontSize: 40, color: Colors.grey[200]);
  String in_letter = '';
  bool _focused = false;
  FocusNode myFocusNode = FocusNode();
  late _CellFormatter txt_format = _CellFormatter(node:myFocusNode, is_last:widget.last);
  
  @override
  void initState()
  {
    super.initState();
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
    super.dispose();
  }

  void SetLetter(String value)
  {
    in_letter = value;
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
                  var parent = MyHomePage.of(context);
                  if (parent != null)
                  {
                    parent.ChooseWord(widget.word_ind, widget.let_ind);
                  }
                  myFocusNode.requestFocus();
                }
              },
              child: Center(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Text(
                      widget.letter,
                      style: _biggerFont,
                      textAlign: TextAlign.center,
                    ),
                    TextField(
                      autocorrect: false,
                      enableSuggestions: false,
                      enableIMEPersonalizedLearning: false,
                      cursorColor: (_focused || widget.pseudo_focused)?sel_color:for_color,
                      showCursor: false,
                      focusNode: myFocusNode,
                      textInputAction: TextInputAction.next,
                      controller: widget.txt_controller,
                      decoration: null,
                      style: _biggerFont,
                      textAlign: TextAlign.center,
                      maxLength: 2, //Extra character for next symbol
                      onChanged: (String value) {
                        var parent = MyHomePage.of(context);
                        if (parent != null)
                        {
                          parent.ChangeLetter(value, widget.word_ind, widget.let_ind);
                        }
                        in_letter = value;
                      },
                      inputFormatters: [
                        txt_format,
                      ],
                    ),
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
  TransparentCell({ Key? key, required this.last, this.letter:'A', required this.clone_ind, required this.source, required this.let_ind, required this.word_ind}) : super(key: key);
  final bool last; //Является ли данная ячейка последней?
  final String letter;  //Буква на этом месте
  final int clone_ind; //Оригинальное слово, на букву которого наслаивается данная ячейка
  final int source; //Индекс пересечения в оригинальном слове
  final int let_ind;
  final int word_ind;
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
    super.initState();
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
    super.dispose();
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
            var parent = MyHomePage.of(context);
            if (f) {     
              if (parent != null)
              {
                parent.ChooseWord(widget.word_ind, widget.let_ind);
              }
              myFocusNode.requestFocus();
            }
            if (parent != null)
            {
              parent.ChangeFocus(f, widget.clone_ind, widget.source);
            }
          },
          child: TextField(
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
              var parent = MyHomePage.of(context);   
              if (parent != null)
              {
                parent.ChangeLetter(value, widget.clone_ind, widget.source);
                parent.ChangeLetter(value, widget.word_ind, widget.let_ind);
              }
            },
            inputFormatters: [
              txt_format,
            ],
          ),
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