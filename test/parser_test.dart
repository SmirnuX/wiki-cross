import 'package:test/test.dart';
import 'package:wiki_cross/parser.dart';

void main() {
  test('Проверка удаления специальных символов', () {
    String input = 'Привет &#12123;мир';
    String output = 'Привет мир';

    expect(ClearText(input, ''), output);
  });

  test('Проверка удаления специальных символов в конце строки [1]', () {
    String input = 'Привет мир &';
    String output = 'Привет мир';

    expect(ClearText(input, ''), output);
  });

  test('Проверка удаления специальных символов в конце строки [2]', () {
    String input = 'Привет мир &#';
    String output = 'Привет мир';

    expect(ClearText(input, ''), output);
  });

  test('Проверка удаления специальных символов в конце строки [3]', () {
    String input = 'Привет мир &#;';
    String output = 'Привет мир';

    expect(ClearText(input, ''), output);
  });

  test('Проверка замены специальных символов', () {
    String input = 'Привет мир &amp; &#167;';
    String output = 'Привет мир & §';

    expect(ClearText(input, ''), output);
  });

  test('Проверка убирания html тегов', () {
    String input = 'Привет <a href="https://google.com">мир</a> ';
    String output = 'Привет мир';

    expect(ClearText(input, ''), output);
  });

  test('Проверка замены дефисов и удаления ударений', () {
    String input = 'Привет ми́р — самый прекрасный из доступных!';
    String output = 'Привет мир - самый прекрасный из доступных!';

    expect(ClearText(input, ''), output);
  });

  test('Проверка замены слова', () {
    String input = ' Мир мир мир!';
    String output = '___ ___ ___!';

    expect(ClearText(input, 'МИР'), output);
  });
}