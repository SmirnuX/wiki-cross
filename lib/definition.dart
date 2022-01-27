// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'crossword.dart';
import 'crossgen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'cells.dart';

class Definition extends StatefulWidget {
  Definition({ Key? key, this.source, required this.index, required this.num}) : super(key: key);
  Field_Word? source;
  int index;
  int num;
  final TextStyle Header_style = const TextStyle(
    fontSize: 30,
    fontFamily: 'Arial'
  );
  final TextStyle Header_const_style = TextStyle(
    fontSize: 30,
    fontFamily: 'TimesNewRoman',
    color: Colors.grey[400],
  );
  final TextStyle Header_focus_style = TextStyle(
    fontSize: 30,
    fontFamily: 'TimesNewRoman',
    backgroundColor: Colors.lightGreen[300],
  );

  final TextStyle Definit_style = const TextStyle(
    fontSize: 20
  );
  final Counter_style = const TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

  @override
  _DefinitionState createState() => _DefinitionState();
}

class _DefinitionState extends State<Definition> {

  @override
  Widget build(BuildContext context) {
    List<DefCross> res = [];  //Непосредственно слово
    if (widget.source != null)
    {
      for (int i = 0; i < widget.source!.length; i++)
      {
        if (widget.source!.word.substring(i, i+1).contains(RegExp(r"[^a-zA-Zа-яА-ЯёЁ]")))  //Посторонние символы
        {
          res.add( 
            DefCross(
              letter:widget.source!.word.substring(i, i+1),
              last: i == widget.source!.length - 1,
              let_ind: i,
              word_ind: widget.source!.num,
              is_const: true,
              focused: false,
              clone_ind: -1,
              clone_let_ind: -1,
            )
          );
        }
        else
        {
          String letter = widget.source!.in_word.substring(i, i+1);
          int _clone_ind = -1;
          int _clone_let_ind = -1;
          for (var inters in widget.source!.inters)
          {
            if (inters.source_index == i)
            {
              _clone_ind = inters.word;
              _clone_let_ind = inters.word_index;
              break;
            }
          }
          res.add( 
            DefCross(
              letter:widget.source!.in_word.substring(i, i+1),
              last: i == widget.source!.length - 1,
              let_ind: i,
              word_ind: widget.source!.num,
              is_const: false,
              focused: i == widget.index,
              clone_ind: _clone_ind,
              clone_let_ind: _clone_let_ind,
            )
          );
        }
        // result += ' ';
      }
    }
    return Card(
      shadowColor: Colors.white,
      margin: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(  //Номер слова
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Chip( 
              label:Text(
                (widget.source==null)?'':'${widget.source!.num+1}/${widget.num}',
                style: widget.Counter_style,
              )
            )
          ),
          Container(  //Само слово
            margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
            height: 50,
            alignment: Alignment.centerLeft,
            child:FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              child: FocusTraversalGroup(
                child: Row (
                  children: res,
                )
              ),   
            ),
          ),
          const Divider(
          ),
          Container(  //Определение слова
            child:AutoSizeText(
              (widget.source==null)?'':widget.source!.definition,
              style: widget.Definit_style,
              maxLines: 5, 
            ),
            margin: const EdgeInsets.all(10),
          ),
        ]
      )  
    );
  }
}

class DefCross extends StatelessWidget {  //Ячейка в определении слова
  DefCross({ Key? key, required this.let_ind, required this.word_ind, required this.last, required this.letter,
            required this.is_const, required this.focused, required this.clone_ind, required this.clone_let_ind}) : super(key: key); //Ячейка в определении слова

  FocusNode myFocusNode = FocusNode();
  final int let_ind;  //Индекс буквы
  final int word_ind; //Индекс слова
  final bool last;  //Является ли данная буква последней
  final bool focused;

  final int clone_ind;  //Индекс слова перекрывающей/перекрытой ячейки [-1]
  final int clone_let_ind;  //Индекс непосредственно ячейки [-1]

  bool is_const;
  
  String letter;  //Буква на этом месте

  var txt_controller = TextEditingController();
  ValueNotifier <bool> notifier = ValueNotifier(false);

  final TextStyle Header_style = const TextStyle(
    fontSize: 30,
    fontFamily: 'Arial'
  );
  final TextStyle Header_const_style = TextStyle(
    fontSize: 30,
    fontFamily: 'TimesNewRoman',
    color: Colors.grey[400],
  );

  final for_color = Colors.white; //Цвет фона ячейки
  final sel_color = Colors.green[100]; //Цвет выбранной ячейки
  late CellFormatter txt_format = CellFormatter(node:myFocusNode, is_last:last);

  @override
  Widget build(BuildContext context) {
    var chosen_style = (is_const?Header_const_style:Header_style);
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.centerLeft,
      child: Card(
        shadowColor: Colors.white,  //Убираем тень
        elevation: 0,
        color: (focused)?sel_color:for_color, 
        child: InkWell(
          focusNode: myFocusNode,
          onFocusChange: (bool f) {            
            if (is_const)
            {
              last?myFocusNode.unfocus():myFocusNode.nextFocus();
              return;
            }
            var parent = CrosswordPage.of(context);
            if (parent != null)
            {
              if (f) 
              {     
                parent.ChooseWord(word_ind, let_ind);
              }
              parent.ChangeFocus(f, word_ind, let_ind);
              if (clone_ind != -1)
              {
                parent.ChangeFocus(f, clone_ind, clone_let_ind); //Изменение буквы в пересечении
              }
            }
          },
          child: Center(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Text(
                  letter,
                  style: chosen_style,
                  textAlign: TextAlign.center,
                ), 
                TextField(
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  cursorColor: (focused)?sel_color:for_color,
                  showCursor: false,
                  textInputAction: TextInputAction.next,
                  controller: txt_controller,
                  decoration: null,
                  style: chosen_style,
                  textAlign: TextAlign.center,
                  maxLength: 2, //Extra character for next symbol
                  onChanged: (String value) {
                    var parent = CrosswordPage.of(context);
                    if (parent != null)
                    {
                      parent.ChangeLetter(value, word_ind, let_ind);

                      if (clone_ind != -1)
                      {
                        parent.ChangeLetter(value, clone_ind, clone_let_ind); //Изменение буквы в пересечении
                      }
                    }
                  },
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