import 'package:test/test.dart';
import 'package:wiki_cross/parser.dart';

void main() {
  test('Проверка удаления специальных символов', () {
    String input = 'Привет &#12123;мир';
    List<dynamic> output = [0, 'Привет мир'];

    expect(CleanText(input, ''), output);
  });

  test('Проверка удаления специальных символов в конце строки [1]', () {
    String input = 'Привет мир &';
    List<dynamic> output = [0, 'Привет мир'];

    expect(CleanText(input, ''), output);
  });

  test('Проверка удаления специальных символов в конце строки [2]', () {
    String input = 'Привет мир &#';
    List<dynamic> output = [0, 'Привет мир'];

    expect(CleanText(input, ''), output);
  });

  test('Проверка удаления специальных символов в конце строки [3]', () {
    String input = 'Привет мир &#;';
    List<dynamic> output = [0, 'Привет мир'];

    expect(CleanText(input, ''), output);
  });

  test('Проверка замены специальных символов', () {
    String input = 'Привет мир &amp; &#167;';
    List<dynamic> output = [0, 'Привет мир & §'];

    expect(CleanText(input, ''), output);
  });

  test('Проверка убирания html тегов', () {
    String input = 'Привет <a href="https://google.com">мир</a> ';
    List<dynamic> output = [0, 'Привет мир'];

    expect(CleanText(input, ''), output);
  });

  test('Проверка замены дефисов и удаления ударений', () {
    String input = 'Привет ми́р — самый прекрасный из доступных!';
    List<dynamic> output = [0, 'Привет мир - самый прекрасный из доступных!'];

    expect(CleanText(input, ''), output);
  });

  test('Проверка замены слова', () {
    String input = ' Мир мир мир!';
    List<dynamic> output = [3, '___ ___ ___!'];
    
    expect(CleanText(input, 'МИР'), output);
  });

  test('Проверка замены слова [1]', () {
    String input = ' Волокола́мский райо́н — упразднённая административно-территориальная единица (район) и муниципальное образование (муниципальный район) на западе Московской области России.';
    List<dynamic> output = [1, '_____________ район - упразднённая административно-территориальная единица и муниципальное образование на западе Московской области России.'];

    expect(CleanText(input, 'ВОЛОКОЛАМСКИЙ'), output);
  });

  test('Проверка удаления сносок', () {
    String input = 'Google Base - база данных, созданная компанией Google в ноябре 2005 года[1][2].';
    List<dynamic> output = [1, 'Google ____ - база данных, созданная компанией Google в ноябре 2005 года.'];

    expect(CleanText(input, 'BASE'), output);
  });

  test('Проверка удаления сносок с другим кодированием', () {
    String input = 'Google Base - база данных, созданная компанией Google в ноябре 2005 &#91;1&#93; года &#91;2&#93;.';
    List<dynamic> output = [1, 'Google ____ - база данных, созданная компанией Google в ноябре 2005 года.'];

    expect(CleanText(input, 'BASE'), output);
  });

  test('Проверка форматирования статей с Википедии [0]', () {
    String input = '<p><b>Чарльз Теннант</b> (<a href="/wiki/%D0%90%D0%BD%D0%B3%D0%BB%D0%B8%D0%B9%D1%81%D0%BA%D0%B8%D0%B9_%D1%8F%D0%B7%D1%8B%D0%BA" title="Английский язык" wotsearchprocessed="true">англ.</a>&nbsp;<span lang="en" style="font-style:italic;">Charles Tennant</span>; <span class="nowrap"><span data-wikidata-property-id="P569" class="no-wikidata"><a href="/wiki/3_%D0%BC%D0%B0%D1%8F" title="3 мая" wotsearchprocessed="true">3&nbsp;мая</a> <a href="/wiki/1768_%D0%B3%D0%BE%D0%B4" title="1768 год" wotsearchprocessed="true">1768</a></span><span class="noprint" style="display:none"> (<span class="bday">1768-05-03</span>)</span></span>&nbsp;— <span data-wikidata-property-id="P570" class="no-wikidata"><a href="/wiki/1_%D0%BE%D0%BA%D1%82%D1%8F%D0%B1%D1%80%D1%8F" title="1 октября" wotsearchprocessed="true">1 октября</a> <a href="/wiki/1838_%D0%B3%D0%BE%D0%B4" title="1838 год" wotsearchprocessed="true">1838</a></span>)&nbsp;— британский химик и предприниматель.</p>';
    List<dynamic> output = [1, 'Чарльз _______ - британский химик и предприниматель.'];
    expect(CleanText(input, 'ТЕННАНТ'), output);
  });

  test('Проверка форматирования статей с Википедии [1]', () {
    String input = '<b>Хи́мик</b>&nbsp;— <a href="/wiki/%D0%A3%D1%87%D1%91%D0%BD%D1%8B%D0%B9" title="Учёный" wotsearchprocessed="true">учёный</a>';
    List<dynamic> output = [1, '_____ - учёный'];

    expect(CleanText(input, 'ХИМИК'), output);
  });

  test('Проверка форматирования статей с Википедии [2]', () {
    String input = '<p><b>Соединённые Шта́ты Аме́рики</b> (<a href="/wiki/%D0%90%D0%BD%D0%B3%D0%BB%D0%B8%D0%B9%D1%81%D0%BA%D0%B8%D0%B9_%D1%8F%D0%B7%D1%8B%D0%BA" title="Английский язык" wotsearchprocessed="true">англ.</a>&nbsp;<span lang="en" style="font-style:italic;">The United States of America</span> [<span class="IPA"><a href="/wiki/%D0%97%D0%B2%D0%BE%D0%BD%D0%BA%D0%B8%D0%B9_%D0%B7%D1%83%D0%B1%D0%BD%D0%BE%D0%B9_%D1%89%D0%B5%D0%BB%D0%B5%D0%B2%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Звонкий зубной щелевой согласный" wotsearchprocessed="true">ð</a><a href="/wiki/%D0%9D%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Неогублённый гласный переднего ряда верхнего подъёма" wotsearchprocessed="true">i</a>&nbsp;<a href="/wiki/%D0%9F%D0%B0%D0%BB%D0%B0%D1%82%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%B0%D0%BF%D0%BF%D1%80%D0%BE%D0%BA%D1%81%D0%B8%D0%BC%D0%B0%D0%BD%D1%82" title="Палатальный аппроксимант" wotsearchprocessed="true">j</a><a href="/wiki/%D0%9E%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%B7%D0%B0%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Огублённый гласный заднего ряда верхнего подъёма" wotsearchprocessed="true">u</a><a href="/wiki/%D0%97%D0%BD%D0%B0%D0%BA_%D0%B4%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%BE%D0%B3%D0%BE_%D1%83%D0%B4%D0%B0%D1%80%D0%B5%D0%BD%D0%B8%D1%8F" title="Знак дополнительного ударения" wotsearchprocessed="true">ˌ</a><a href="/wiki/%D0%9F%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D1%8F%D0%B7%D1%8B%D1%87%D0%BD%D1%8B%D0%B9_%D0%BD%D0%BE%D1%81%D0%BE%D0%B2%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Переднеязычный носовой согласный" wotsearchprocessed="true">n</a><a href="/wiki/%D0%9D%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D0%BD%D0%B8%D0%B6%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Неогублённый гласный переднего ряда нижнего подъёма" wotsearchprocessed="true">a</a><a href="/wiki/%D0%9D%D0%B5%D0%BD%D0%B0%D0%BF%D1%80%D1%8F%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Ненапряжённый неогублённый гласный переднего ряда верхнего подъёма" wotsearchprocessed="true">ɪ</a><a href="/wiki/%D0%93%D0%BB%D1%83%D1%85%D0%BE%D0%B9_%D0%B0%D0%BB%D1%8C%D0%B2%D0%B5%D0%BE%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B9_%D0%B2%D0%B7%D1%80%D1%8B%D0%B2%D0%BD%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Глухой альвеолярный взрывной согласный" wotsearchprocessed="true">t</a><a href="/wiki/%D0%9D%D0%B5%D0%BD%D0%B0%D0%BF%D1%80%D1%8F%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Ненапряжённый неогублённый гласный переднего ряда верхнего подъёма" wotsearchprocessed="true">ɪ</a><a href="/wiki/%D0%97%D0%B2%D0%BE%D0%BD%D0%BA%D0%B8%D0%B9_%D0%B0%D0%BB%D1%8C%D0%B2%D0%B5%D0%BE%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B9_%D0%B2%D0%B7%D1%80%D1%8B%D0%B2%D0%BD%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Звонкий альвеолярный взрывной согласный" wotsearchprocessed="true">d</a>&nbsp;<a href="/wiki/%D0%97%D0%BD%D0%B0%D0%BA_%D0%B4%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%BE%D0%B3%D0%BE_%D1%83%D0%B4%D0%B0%D1%80%D0%B5%D0%BD%D0%B8%D1%8F" title="Знак дополнительного ударения" wotsearchprocessed="true">ˌ</a><a href="/wiki/%D0%93%D0%BB%D1%83%D1%85%D0%BE%D0%B9_%D0%B0%D0%BB%D1%8C%D0%B2%D0%B5%D0%BE%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B9_%D1%81%D0%B8%D0%B1%D0%B8%D0%BB%D1%8F%D0%BD%D1%82" title="Глухой альвеолярный сибилянт" wotsearchprocessed="true">s</a><a href="/wiki/%D0%93%D0%BB%D1%83%D1%85%D0%BE%D0%B9_%D0%B0%D0%BB%D1%8C%D0%B2%D0%B5%D0%BE%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B9_%D0%B2%D0%B7%D1%80%D1%8B%D0%B2%D0%BD%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Глухой альвеолярный взрывной согласный" wotsearchprocessed="true">t</a><a href="/wiki/%D0%9D%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D1%81%D1%80%D0%B5%D0%B4%D0%BD%D0%B5-%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Неогублённый гласный переднего ряда средне-верхнего подъёма" wotsearchprocessed="true">e</a><a href="/wiki/%D0%9D%D0%B5%D0%BD%D0%B0%D0%BF%D1%80%D1%8F%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Ненапряжённый неогублённый гласный переднего ряда верхнего подъёма" wotsearchprocessed="true">ɪ</a><a href="/wiki/%D0%93%D0%BB%D1%83%D1%85%D0%BE%D0%B9_%D0%B0%D0%BB%D1%8C%D0%B2%D0%B5%D0%BE%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B9_%D0%B2%D0%B7%D1%80%D1%8B%D0%B2%D0%BD%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Глухой альвеолярный взрывной согласный" wotsearchprocessed="true">t</a><a href="/wiki/%D0%93%D0%BB%D1%83%D1%85%D0%BE%D0%B9_%D0%B0%D0%BB%D1%8C%D0%B2%D0%B5%D0%BE%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B9_%D1%81%D0%B8%D0%B1%D0%B8%D0%BB%D1%8F%D0%BD%D1%82" title="Глухой альвеолярный сибилянт" wotsearchprocessed="true">s</a>&nbsp;<a href="/wiki/%D0%A8%D0%B2%D0%B0" title="Шва" wotsearchprocessed="true">ə</a><a href="/wiki/%D0%97%D0%B2%D0%BE%D0%BD%D0%BA%D0%B8%D0%B9_%D0%B3%D1%83%D0%B1%D0%BD%D0%BE-%D0%B7%D1%83%D0%B1%D0%BD%D0%BE%D0%B9_%D1%81%D0%BF%D0%B8%D1%80%D0%B0%D0%BD%D1%82" title="Звонкий губно-зубной спирант" wotsearchprocessed="true">v</a>&nbsp;<a href="/wiki/%D0%A8%D0%B2%D0%B0" title="Шва" wotsearchprocessed="true">ə</a><a href="/wiki/%D0%97%D0%BD%D0%B0%D0%BA_%D1%83%D0%B4%D0%B0%D1%80%D0%B5%D0%BD%D0%B8%D1%8F_(%D1%81%D0%B8%D0%BC%D0%B2%D0%BE%D0%BB_%D0%9C%D0%A4%D0%90)" title="Знак ударения (символ МФА)" wotsearchprocessed="true">ˈ</a><a href="/wiki/%D0%93%D1%83%D0%B1%D0%BD%D0%BE-%D0%B3%D1%83%D0%B1%D0%BD%D0%BE%D0%B9_%D0%BD%D0%BE%D1%81%D0%BE%D0%B2%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Губно-губной носовой согласный" wotsearchprocessed="true">m</a><a href="/wiki/%D0%9D%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D1%81%D1%80%D0%B5%D0%B4%D0%BD%D0%B5-%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Неогублённый гласный переднего ряда средне-верхнего подъёма" wotsearchprocessed="true">e</a><a href="/wiki/%D0%90%D0%BB%D1%8C%D0%B2%D0%B5%D0%BE%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B5_%D0%B4%D1%80%D0%BE%D0%B6%D0%B0%D1%89%D0%B8%D0%B5_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B5" title="Альвеолярные дрожащие согласные" wotsearchprocessed="true">r</a><a href="/wiki/%D0%9D%D0%B5%D0%BD%D0%B0%D0%BF%D1%80%D1%8F%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%BD%D0%B5%D0%BE%D0%B3%D1%83%D0%B1%D0%BB%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B4%D0%BD%D0%B5%D0%B3%D0%BE_%D1%80%D1%8F%D0%B4%D0%B0_%D0%B2%D0%B5%D1%80%D1%85%D0%BD%D0%B5%D0%B3%D0%BE_%D0%BF%D0%BE%D0%B4%D1%8A%D1%91%D0%BC%D0%B0" title="Ненапряжённый неогублённый гласный переднего ряда верхнего подъёма" wotsearchprocessed="true">ɪ</a><a href="/wiki/%D0%93%D0%BB%D1%83%D1%85%D0%BE%D0%B9_%D0%B2%D0%B5%D0%BB%D1%8F%D1%80%D0%BD%D1%8B%D0%B9_%D0%B2%D0%B7%D1%80%D1%8B%D0%B2%D0%BD%D0%BE%D0%B9_%D1%81%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BD%D1%8B%D0%B9" title="Глухой велярный взрывной согласный" wotsearchprocessed="true">k</a><a href="/wiki/%D0%A8%D0%B2%D0%B0" title="Шва" wotsearchprocessed="true">ə</a></span>]), сокращённо <b>США</b> (<a href="/wiki/%D0%90%D0%BD%D0%B3%D0%BB%D0%B8%D0%B9%D1%81%D0%BA%D0%B8%D0%B9_%D1%8F%D0%B7%D1%8B%D0%BA" title="Английский язык" wotsearchprocessed="true">англ.</a>&nbsp;<span lang="en" style="font-style:italic;">USA</span>), или <b>Соединённые Шта́ты</b> (<a href="/wiki/%D0%90%D0%BD%D0%B3%D0%BB%D0%B8%D0%B9%D1%81%D0%BA%D0%B8%D0%B9_%D1%8F%D0%B7%D1%8B%D0%BA" title="Английский язык" wotsearchprocessed="true">англ.</a>&nbsp;<span lang="en" style="font-style:italic;">United States, U.S.</span>, в просторечии&nbsp;— <b>Аме́рика</b>)&nbsp;— <a href="/wiki/%D0%93%D0%BE%D1%81%D1%83%D0%B4%D0%B0%D1%80%D1%81%D1%82%D0%B2%D0%BE" title="Государство" wotsearchprocessed="true">государство';
    List<dynamic> output = [2, '___________ Штаты Америки, сокращённо США, или ___________ Штаты - государство'];
    expect(CleanText(input, 'СОЕДИНЁННЫЕ'), output);
  });

  test('Проверка форматирования статей с Википедии [3]', () {
    String input = 'Тьеррас-Альтас - район в Испании, входит в провинцию Сория в составе автономного сообщества Кастилия и Леон.';
    List<dynamic> output = [1, '______________ - район в Испании, входит в провинцию Сория в составе автономного сообщества Кастилия и Леон.'];
    expect(CleanText(input, 'Тьеррас-Альтас'), output);
  });

}

