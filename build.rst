
Документация - набор RST файлов
*********************************************

Документация - это набор RST файлов.

Типичный набор документации по проекту состоит из:

* описание общей идеи проекта (как правило, вручную поддерживаемый RST файл)
* модели данных (порождается из Django model)
* описания алгоритмов и интересных мест (возможно, состоит более чем из одного описания, см. :ref:`algorithms`)
* референс (список кратких описаний функций, порождается генератором frunction, см. :ref:`functions`)
* список TODO (см. :ref:`gen_inlines`)
* список "костылей (см. :ref:`gen_inlines`)
* исходники (отдельный раздел, который содержит документацию по каждому из исходников проекта)
  
Файлы порождаются

* явно из каждого DPY файла (документация по исходникам)
* много файлов с алгоритмами вида name.part.rstp (из таких файлов должен родиться один name.rst как конкатенация)
* индекса index.rst
* описательных файлов (как этот)

Куда собирать
=============

Документация собирается в общую директорию, которая (линком или явным копированием) вставляется в дерево документации. 
Документация при этом собирается стандартными методами sphinx-а.

Кто должен собирать
===================

Сборка всего (не только документации) производится посредством старого доброго MAKE. Для управления сборкой
используются два файла

* стандартный, включаемый в каждый проект Makefile (включается include-ом в Makefile)
* уникальный для конкретного проекта файл, он определяет состав файлов и набор "фич"
* локальный файл с локальными настройками (как правило, пути к нужным директориям на локальной машине)

Предполагается, что в первые два файла хранятся в системе управления версиями, последний файл уникален для каждой конкретной машины.

В процессе сборки происходит, в том числе, копирование файлов в нужные "места":

* цель install: исходники копируются в нужные (Django) директории,
* цель copy: RST файлы копируются в дерево документации.

После копирования нужно не забыть пересобрать sphinx проект.

Стандартный, включаемый в каждый проект Makefile (см. пример реального файла с включенным этим ниже)

::

   #
   # Стандартный файл сборки DJANGO файлов из DPY (позже - из других типов тоже) при помощи генераторов
   # он включается после файла настройки, см. документацию по литеральному программированию, куда включен
   # эталон этого файла и краткое описание и пример файла с настройками проекта
   #
   
   .SUFFIXES: .dpy .py .html .rst .rstp .js .css
   
   # Исполнимые команды
   MKPYDOC=python3 $(PYTH_PATH)/mkpydoc.py	# собственно генератор исходников и документации
   MKHINTS=python3  $(PYTH_PATH)/gen_hints.py	# генератор хинтов для JS
   MKMETA=python3  $(PYTH_PATH)/gen_inlines.py	# генератор мета информации (todo и костылей)
   MKFTMAP=python3  $(PYTH_PATH)/gen_feat_map.py # генератор фиче мапа
   
   # Наши целевые файлы
   # Исходники на питоне и других языках (нужны для зависимостей)
   SRC_FILES=$(DPY_FILES:.dpy=.py)
   SRC_DPY_FILES = $(DPY_FILES)
   ifdef LIB_FILES
   SRC_FILES += $(LIB_FILES:.dpy=.py)
   SRC_DPY_FILES += $(LIB_FILES)
   endif
   ifdef CONF_FILES
   SRC_FILES += $(CONF_FILES:.dpy=.py)
   SRC_DPY_FILES += $(CONF_FILES)
   endif
   
   # Документация - RST файлы
   T_RST_FILES = $(DPY_FILES:.dpy=.rst) $(RST_SRC_FILES) glossary.rst sources.rst todos.rst crutches.rst
   ifdef LIB_FILES
   T_RST_FILES += $(LIB_FILES:.dpy=.rst)
   endif
   ifdef CONF_FILES
   T_RST_FILES += $(CONF_FILES:.dpy=.rst)
   endif
   ifdef FEAT_SRC_FILES
   T_RST_FILES += feat_map.rst
   endif
   RST_FILES = $(sort $(T_RST_FILES) )

   # Алгоритмы и интересные места
   ALG_FILES=algorithms.rst
   
   # Исходники, которые хотим документировать
   T_SRC_DOC_FILES = $(DPY_FILES:.dpy=)
   ifdef LIB_FILES
   T_SRC_DOC_FILES += $(LIB_FILES:.dpy=)
   endif
   SRC_DOC_FILES=$(filter-out models,$(sort $(T_SRC_DOC_FILES)) )
   
   # Файлы, которые мы копируем в разные места
   TO_GUI=$(DPY_FILES:.dpy=.py)
   ifdef LIB_FILES
   TO_LIB=$(LIB_FILES:.dpy=.py)
   endif
   ifdef CONF_FILES
   TO_CONF=$(CONF_FILES:.dpy=.py)
   endif
   ifdef JS_FILES
   TO_JS=$(JS_FILES) hints_data.js
   endif
   
   # TARGETS
   
   all: copy install
   
   sources: $(SRC_FILES)	# сгенерить исходники
   
   # ГЛАВНОЕ НАСТРАИВАЕМОЕ ПРАВИЛО для исполняемого кода =============================
   install: sources 	# копируем исполняемые файлы в разные папки
   	@cp $(TO_GUI) $(PROJ_SRC_DIR);		echo Копируем исходники в gui
   ifdef LIB_FILES
   	@cp $(TO_LIB) $(PROJ_LIB_DIR);		echo Копируем библиотеки в папку с библиотеками
   endif
   ifdef CONF_FILES
   	@cp $(TO_CONF) $(PROJ_CONF_DIR);	echo Копируем конфигурацию в конфигурационную директорию
   endif
   ifdef HTML_FILES
   	@cp $(HTML_FILES) $(PROJ_TEMPLATES_DIR);echo Копируем шаблоны в templates
   endif
   ifdef HTML_ADMIN_FILES
   	@cp $(HTML_ADMIN_FILES)  $(PROJ_ADMIN_TEMPLATES_DIR);	echo Копируем ADMIN шаблоны в templates/admin
   endif
   ifdef JS_FILES
   	@cp $(TO_JS) $(PROJ_TEMPLATES_DIR);	echo Копируем JS в templates
   endif
   ifdef PROJ_CSS_FILES
   	@cp $(PROJ_CSS_FILES) $(PROJ_CSS_DIR);	echo Копируем стили в app/static
   endif
   ifdef SCRIPT_FILES
   	@cp $(SCRIPT_FILES) $(SCRIPT_DIR);	echo Копируем скрипты в папку со скриптами
   endif
   # ============================================================================ END
   
   # ГЛАВНОЕ НАСТРАИВАЕМОЕ ПРАВИЛО для документации =================================
   docu: $(RST_FILES)	# сгенерировать документацию по исходникам (и остальное)
   
   copy: docu		# копируем документацияю в папку с документацией
   	@cp $(RST_FILES) $(ALG_FILES) $(DOCU_DIR); echo Копируем всю документацию в Docu
   ifdef DOCU_CSS_FILES
   	@cp $(DOCU_CSS_FILES) $(DOCU_CSS_DIR);	echo Копируем стили в Docu/_static
   endif
   # ============================================================================ END
   
   # Стандартные правила ============================================================
   .dpy.py .dpy.rst:
   	@echo Converting DPY file $< to RST and PY files
   	@$(MKPYDOC) -i $< 
   	
   # Генерация глоссария и хинтов
   gloss.db.rstp: models.dpy
   	@echo Генерируем словарь по базе данных
   	@$(MKPYDOC) -i models.dpy 
   hints_data.js: gloss.db.rstp $(RST_FILES)
   	@echo Генерируем .js файл с хинтами
   	@$(MKHINTS) gloss.db.rstp $(RST_FILES)
   glossary.rst: gloss.db.rstp gloss0.rstp
	@echo Создаем словарный .rst файл
	@echo "Список терминов" > glossary.rst
	@echo "***************\n" >> glossary.rst
	@cat gloss.db.rstp >> glossary.rst
   
   ifdef $(FEAT_SRC_FILES)
   # Генерация фиче мапа
   feat_map.rst: $(FEAT_SRC_FILES)
	@echo Создаем Feature Map
	@$(MKFTMAP) -i checkvist.opml -o feat_map.rst
   endif
   
   # Генерация списка исходников
   sources.rst: Makefile
	@echo Создаем список исходников
	@echo "Исходники" >sources.rst
	@echo "*********" >>sources.rst
	@echo "\nПеречень документированных исходников\n\n" >>sources.rst
	@echo "Имеющиеся описания:" >>sources.rst
	@echo "-------------------" >>sources.rst
	@echo "\n.. toctree::" >>sources.rst
	@echo "   :maxdepth: 1" >>sources.rst
	@echo "   :numbered: 2" >>sources.rst
	@echo $(SRC_DOC_FILES) | xargs -n 1 echo "  " | sort -u >> sources.rst
   
   # Генерирация TODO и костылей
   todos.rst: $(SRC_FILES)
	@echo Генерируем файлы с TODO
	@$(MKMETA) -o todos.rstp -t TODO $(SRC_DPY_FILES)
	@echo "\nTODOS: что еще надо сделать в проекте" > todos.rst
	@echo "*************************************\n" >> todos.rst
	@echo "Ниже перечислены доделки, найденные в исходниках проекта (в скобках - номер строки исходника).\n" >> todos.rst
	@cat todos.rstp >> todos.rst
   crutches.rst: $(DPY_FILES) $(LIB_FILES)
	@echo Генерируем файлы с Костылями
	@$(MKMETA) -o crutches.rstp -t КОСТЫЛЬ $(SRC_DPY_FILES)
	@echo "КОСТЫЛИ: что криво сделано в проекте" > crutches.rst
	@echo "************************************\n" >> crutches.rst
	@echo "Ниже перечислены "костыли", т.е. куски кода, которые были сделаны на спех из предположений," >> crutches.rst
	@echo "  что "такого быть не может". Их, по-хорошему, нужно переделать..." >> crutches.rst
	@cat crutches.rstp >> crutches.rst
	
   # Генерация .gitignore
   .gitignore: Makefile
	@echo Генерируем .gitignore
	@echo "*.py" > .gitignore
	@echo ".gitignore" >> .gitignore
	@echo "*.rst" >> .gitignore
	@echo "*.rstp" >> .gitignore
	@echo "!*0.rstp" >> .gitignore
	@echo "!sources.rstp" >>.gitignore
	@echo "hints_data.js" >>.gitignore
	@for X in $(RST_SRC_FILES); do echo !$$X >> .gitignore ; done


Пример файла с настройками под конкретный проект (в данном случае - rfwb):

::

   # ======================================== PROJ.DATA
   # Директории
   # Они ничего не решают (т.е. могут быть не все определены или быть /dev/null - по умолчанию)
   # Решение "копировать/нет" принимается по определению или не определению переменных в секции "исходники" ниже
   include local_settings.mk	# там определены PYTH_PATH и DOCU_PATH для локальной машины
   PROJ_SRC_DIR=../gui				## должна быть всегда (туда копируются PY файлы)
   DOCU_DIR=$(DOCU_PATH)/rfwb			## должна быть всегда (туда копируются RST файлы)
   PROJ_LIB_DIR=../lib				# должна быть определена, если LIB_FILES
   PROJ_CONF_DIR=../testgui			# если CONF_FILES
   PROJ_TEMPLATES_DIR=../gui/templates/gui	# если HTML_FILES or JS_FILES
   PROJ_CSS_DIR=../gui/static			# если PROJ_CSS_FILES
   PROJ_ADMIN_TEMPLATES_DIR=../gui/templates/admin # если HTML_ADMIN_FILES
   DOCU_CSS_DIR=$(DOCU_PATH)/_static		# если DOCU_CSS_FILES
   SCRIPT_DIR=/srv/autotests/batch		# если SCRIPT_FILES
   
   # Наши файлы исходники
   DPY_FILES=admin.dpy logger.dpy models.dpy oth_views.dpy proj_views.dpy test_views.dpy toinstr.dpy urls_gui.dpy utils.dpy xml2xls.dpy vers_control.dpy wait_test.dpy
   SCRIPT_FILES=wait_test.py check_res.sh
   LIB_FILES=xml2xls.dpy # datafilelib.dpy
   CONF_FILES=cust_settings.dpy urls.dpy
   HTML_FILES=__base.html html.html ifparam.html img.html proj_list.html run_proj.html test_list.html test_page.html rep_list.html
   HTML_ADMIN_FILES = sel_iface.html
   JS_FILES=ready_func.js ready_test.js ready_proj.js
   DOCU_CSS_FILES=style.css
   PROJ_CSS_FILES=gui.css
   RST_SRC_FILES=index.rst instr.rst ideas.rst
   FEAT_SRC_FILES=checkvist.opml			# определяют генерацию фиче мапа
   # ========================================= END
   
   # ============================================= CUSTOM правила проекта
   wait_test.py: wait_test.dpy
   	@echo Converting executable DPY file $< to RST and PY files
   	@$(MKPYDOC) -x 2 -i $< 
   # ============================================= END
   
   include $(PYTH_PATH)/mkpydoc_std.mk

На подумать - надо как-то научиться вставлять в стили ширину таблицы, сейчас пока вставил в style.css table.docutils width:95%.

Кстати, непонятно, откуда вообще взялись стили в этом файле - они не являются частью никакого проекта...
