
Литературное программирование (literal programming)
***************************************************

Мысль простая: документация на программу должна порождаться из самой программы, тогда она (документация) будет обновляться...

Все нижеописанное навеялось вот этими ссылками 

  * https://en.wikipedia.org/wiki/Literate_programming
  * https://en.wikipedia.org/wiki/Noweb
  * http://www.cs.tufts.edu/~nr/noweb/

Ну и, как обычно, захотелось чтобы было "под себя"...

.. _chunks:

Как это видится
===============

Общая идея
----------

Файл с программой состоит из кусков - чанков (наверное, термин от старины Кнута). Чанки бывают двух категорий

- текст (документация)
- код (на языке программирования)

И есть "сборщик", который из этого чудесного сборища чанков формирует

- исходник (для компилятора)
- документацию (для системы сборки документации)

Общая мысль такова - автор пишет программу и тут же пишет свои мысли (почему он так делает, что он делает и т.п.).

Что здесь нового и интересного: комментарии (которые, по-сути, являются "чанком") никуда не идут. Сделан ряд попыток оформлять комментарии специальным образом
и тогда по этим специально оформленным комментариям производить документацию. В предлагаемом подходе комментарии - это комментарии (мелочи), а чанки с документацией -
это куски мыслей, бОльших, чем комментарии. Решил попробовать, посмотреть, что и как получится.

В итоге получается следующая картина: по набору "исходников" формируется

- набор документов (примеры см. в этой документации), как минимум
  
  - концептуальные описания (с этим пока не до конца понятно: скорее всего, они все же поддерживаются отдельно от программ. Пример - этот документ)
  - модель данных
  - интересные алгоритмы
    
- полный перечень исходников (оформленных более "красиво", нежели позволяет сделать исходный язык программирования)
- словарь (определний и терминов)
- ... куда еще фантазия занесет

Все это перевязано перекрестными ссылками, позволяющими "ходить" по этому кладезю знаний совершенно свободно.

.. glossary::

   Чанк : Ч
	  Кусок кода, выделенный особым образом.

.. _generators:

Генераторы
----------

Идея генераторов проста (см. Прагматик программер): код, который можно генерировать автоматом - нужно генерировать автоматом. Человечество до эпохи виндоус и планшетов благополучно
двигалось в направлении генерации программ целиком, но... отвлеклось на окошки и тач. Жалко.

Генераторы удачно вплетаются в концепцию чанков - "сборщик" фактически и является "генератором". Только изначально (в идее литерального программирования) он формирует исходный
код программы простым и единственным способом (фактически - копируя, максимум - макроподставляя), а в идее с генератором код может формироваться так, как это видит себе "генератор"
определенного типа.

Ну и дальше эту идею можно и нужно развивать

- под себя
- под конкретный язык программирования
- под конкретный framework
- под конкретную систему документирования

Здесь сделана попытка сделать инструмент

- для питона
- для django
- для sphinx

Полезности
----------

Можно дополнить это всяким мелкими полезностями

- генерацией списка TODO, которые также содержатся прямо в коде и иметь этот список в документации (см. :ref:`gen_inlines`)
- то же про "костыли"
- формирование "алгоритмов" (интересных кусков кода) в виде отдельных документов (чтобы не лазить за ними по исходникам) (см. :ref:`algorithms`)
- формирование "хинтов" для интерфейса (см. :ref:`gen_hints`)
- (пока на этом список полезностей остановился, но это точно не конец)

Чуть более подробно
===================

Чуть спустимся до конкретики и примеров.

Чанки
-----

Самый простой пример чанка (типа "простой код") - просто чанк :-)

::
   
   <<фрагмент кода>>=
   a = b
   return

Чанк кончаются там, где начинается следующий чанк. Файл начинается с документационного чанка, явно начать документационный
чанк можно вставив строку вида

::
   
  @

Например

::
   
   <<фрагмент кода>>=
   a = b
   return

   @
   В этом фрагменте кода а получает значение b

   <<еще фрагмент кода>>=
   с = b
   @
   а до сюда никогда никто не дойдет - раньше был return
   

Более осмысленные примеры чанков можно найти в примерах этой документации.

Технически

- имя чанка "уходит" в заголовок (видна в оглавлении исходника)
- чанк может иметь описание (до символов <--->): оно визуально выделяется в документации
  
Чанки второго уровня
--------------------

Чанки первого уровня (или просто чанки) позволяют просто формировать документацию и исходный код программы.

Чанки второго уровня - аналог макроподстановки (по имени чанка второго уровня).

Пример

::
   
   <<doWork - функция>>=
   Функция, которая все и делает.
   <--->

       <<GEN_HINTS: Разбор командной строки>>
    
       a = b
       
И далее где-то в этом же (пока) файле встречается такой конструкт

::
   
   <<GEN_HINTS: Разбор командной строки>>==
   Параметры запуска утилиты
   <--->
   parser = argparse.ArgumentParser(description='Формирует ассоциативный массив (объект) с хинтами для JS')
   parser.add_argument('-o','--ofile', default='hints_data.js', help='имя файла результата')
   parser.add_argument('files', metavar='file', nargs='+', help='файл с глоссарием')
   args = parser.parse_args()

Зачем это:

- борьба со сложностью (код получается чуть более читаемым)
- поддержка разработки "сверху-вниз" (не запариваясь формулировками в виде функций, которые требуют определенного размышления)
- возможность сборки программы из кусков (которые не получается оформить в виде функций)

Пока возмоность не очень востребована, впрочем...

Типизированные чанки
--------------------

А еще чанк может иметь тип, тогда в дело вступает "генератор":

::
   
   <<cvtRef|type=function>>=
   < ttxt: строка с определением из словаря
   < ld: словарь с именами меток
   > строка: HTML для вставки
   Пребразует :ref: в ссылку, используя имя метки и словарь
   
   Предполагаем, что в определении не может быть более одной ссылки
   <--->
   
       if ttxt.find(":ref:`")<=0:	# нет ссылок - ничего не делаем
       ...

В этом случае чанк будет обрабатываться генератором типа "функция" (который сформирует текст определения функции и красивый заголовок в документации, см. примеры в исходниках).

Пока придумалось не так много генераторов (более подробно - см. :ref:`syntax`):

- модели (django)
- функции (питона)
- словарные статьи

Но... это только начало.

.. _algorithms:

Алгоритмы
---------

Полезно иметь возможность выделять "алгоритмы" - то, что может быть интересно внешнему потребителю, не только автору.

Для этого фрагмент программного кода обрамляется специальными префиксами, весь такой фрагмент попадает в выделенный файл (см. алгоритмы и синтаксис этого раздела докуменатции).

Пример алгоритма

::
   
   @
   #<algorithms.hints
   
   <<GEN_HINTS: Разбор командной строки>>==
   Параметры запуска утилиты
   <--->
   parser = argparse.ArgumentParser(description='Формирует ассоциативный массив (объект) с хинтами для JS')
   parser.add_argument('-o','--ofile', default='hints_data.js', help='имя файла результата')
   parser.add_argument('files', metavar='file', nargs='+', help='файл с глоссарием')
   args = parser.parse_args()
   
   @
   #>algorithms.hints

Референс
--------

Как минимум референс - т.е. возможность посмотреть на то, чем можно пользоваться

  * функции
  * ??? а что еще

**То, что ниже - не реализовано..**
    
Кросс-референс: определения - использования
-------------------------------------------

Если я что-то изменяю - на что это повлияет

Генератор Makefile
------------------

#TODO: сделать генератор Makefile

Этот файл можно порождать автоматом

- по файлам, которые есть в текущей директории, он уже поймет часть задачи
- будет задавать вопросы (типа заголовок алгоритмов) и давать умолчания (тем самым сгенерит все файлы, которые приходится подкладывать)
- будет создавать джанговскую часть
  

  
