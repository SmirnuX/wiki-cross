// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'crossword.dart';
import 'search.dart';
import 'final.dart';
import 'cross_settings.dart';

void main() {
  runApp(MaterialApp(
    title: 'Wiki Crossword',
    theme: ThemeData(
      primaryColor: Colors.grey[350],
      scaffoldBackgroundColor: ColorTheme.BackgroundColor
    ),
    darkTheme: ThemeData(
      textTheme: Typography.material2014().white,
      scaffoldBackgroundColor: ColorTheme.dBackgroundColor,
      brightness: Brightness.dark,
    ),
    themeMode: ThemeMode.system,
    initialRoute: '/',
    
    routes: {
      '/': (context) => const SearchRoute(),  //Поиск статей в Википедии
    },
    onGenerateRoute: (settings) {
      switch (settings.name)
      {
        case '/crossword':
          final res = settings.arguments as GenSettings;
          return MaterialPageRoute(builder: (BuildContext context) {return CrosswordRoute(pageid: res.pageid, size: res.size, diff: res.difficulty, lang_rus: res.lang_rus,);}) ;
          break;
        case '/cross_settings':
          final selection = settings.arguments as List<dynamic>;
          return MaterialPageRoute(builder: (BuildContext context) {return GenRoute(pageid: selection[0], title: selection[1], lang_rus: selection[2],);}) ;
        case '/final':
          final result = settings.arguments as List<dynamic>;
          return MaterialPageRoute(builder: (BuildContext context) {return FinalRoute(hints:result[0], words: result[1]);}) ;
          break;
      }
    },
  ));
}

class ColorTheme
{
  //Светлая тема
  static const Color TextColor = Colors.black;  //Цвет текста
  static Color BackgroundColor = Colors.grey[50]!;  //Цвет фона
  static Color LoadingColor = Colors.grey[600]!; //Цвет индикаторов загрзуки
  static const Color AppBarColor = Colors.white;  //Цвет appbar'ов

  static const Color CellColor = Colors.white;  //Цвет ячейки
  static Color ReadOnlyColor = Colors.grey[200]!;  //Цвет ячейки с неизменяемым содержимым
  static Color FocusedCellColor = Colors.green[100]!; //Цвет выбранной ячейки
  static Color HighlightedColor = Colors.lightGreen[50]!; //Цвет подсвеченного слова

  static Color WrongCellColor = Colors.red[200]!;   //Цвет ошибочной ячейки (при использовании подсказки)
  static Color WrongCellHlColor = Colors.red[300]!;  //Цвет ошибочной выбранной ячейки

  static const Color AvailableHintColor = Colors.black; //Цвет иконки доступной подсказки
  static Color UnavailableHintColor = Colors.grey[200]!; //Цвет иконки недоступной подсказки
  static Color UsedColor = Colors.green[400]!;  //Цвет иконки для уже использованной подсказки

  //Темная тема
  static Color dTextColor = Colors.grey[100]!;  //Цвет текста
  static Color dBackgroundColor = Colors.black;  //Цвет фона
  static Color dLoadingColor = Colors.grey[100]!; //Цвет индикаторов загрзуки
  static Color dAppBarColor = Colors.grey[900]!;  //Цвет appbar'ов

  static Color dCellColor = Colors.grey[800]!;  //Цвет ячейки
  static Color dReadOnlyColor = Colors.grey[850]!;  //Цвет ячейки с неизменяемым содержимым
  static const Color dFocusedCellColor = Color(0xFF9CA59A); //Цвет выбранной ячейки 
  static const Color dHighlightedColor = Colors.grey; //Цвет подсвеченного слова

  static const Color dWrongCellColor = Color(0xFF775F5F);   //Цвет ошибочной ячейки (при использовании подсказки)
  static const Color dWrongCellHlColor = Color(0xFFBF7C7C);  //Цвет ошибочной выбранной ячейки

  static const Color dAvailableHintColor = Colors.white; //Цвет иконки доступной подсказки
  static Color dUnavailableHintColor = Colors.grey[800]!; //Цвет иконки недоступной подсказки
  static Color dUsedColor = Colors.green[200]!;  //Цвет иконки для уже использованной подсказки

  static Color GetTextColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dTextColor:TextColor; //Если тема темная
  }

  static Color GetBackColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dBackgroundColor:BackgroundColor; //Если тема темная
  }

  static Color GetLoadColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dLoadingColor:LoadingColor; //Если тема темная
  }

  static Color GetAppBarColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dAppBarColor:AppBarColor; //Если тема темная
  }

  static Color GetCellColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dCellColor:CellColor; //Если тема темная
  }

  static Color GetROCellColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dReadOnlyColor:ReadOnlyColor; //Если тема темная
  }

  static Color GetHLCellColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dFocusedCellColor:FocusedCellColor; //Если тема темная
  }

  static Color GetLightHLCellColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dHighlightedColor:HighlightedColor; //Если тема темная
  }

  static Color GetWrongCellColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dWrongCellColor:WrongCellColor; //Если тема темная
  }

  static Color GetHLWrongCellColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dWrongCellHlColor:WrongCellHlColor; //Если тема темная
  }

  static Color GetAvailHintColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dAvailableHintColor:AvailableHintColor; //Если тема темная
  }

  static Color GetUnavailHintColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dUnavailableHintColor:UnavailableHintColor; //Если тема темная
  }

  static Color GetUsedHintColor(BuildContext context)
  {
    final theme = Theme.of(context).brightness;
    return theme == Brightness.dark?dUsedColor:UsedColor; //Если тема темная
  } 
}
