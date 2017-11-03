#
# Стандартный файл сборки DJANGO файлов из DPY (позже - из других типов тоже) при помощи генераторов
# он включается после файла настройки, см. документацию по литеральному программированию, куда включен
# эталон этого файла и краткое описание и пример файла с настройками проекта
#

.SUFFIXES: .dpy .py .html .rst .rstp .js .css

# Исполнимые команды
MKPYDOC=python3 $(PYTH_PATH)/mkpydoc.py		# собственно генератор исходников и документации
MKHINTS=python3  $(PYTH_PATH)/gen_hints.py	# генератор хинтов для JS
MKMETA=python3  $(PYTH_PATH)/gen_inlines.py	# генератор мета информации (todo и костылей)
MKFTMAP=python3  $(PYTH_PATH)/gen_feat_map.py 	# генератор фиче мапа

# Правила именования - какие переменные что значат и на что влияют
# DPY_FILES - это наши питонные исходники (те, которые мы ручками редактируем)
# MODEL_FILES - файл с моделью данных (не во всех проектах есть...)
# RST_SRC_FILES - это файлы документации (RST файлы, которые мы ручками редактируем)
# LIB_FILES - общие файлы (какие-то библиотеки, они живут вне проекта)
# CONF_FILES - конфигурационные файлы DJANGO
# HTML_FILES - шаблоны Django
# HTML_ADMIN_FILES - шаблоны админки Django
# PROJ_CSS_FILES - стили проекта
# SCRIPT_FILES - скрипты (не JS, например, для запуска автотестов)
# FEAT_SRC_FILES - файлы с фичем мапами (генерятся отдельной тулзой)
# ALG_FILES - файлы с алгоритмами и интересными местами (специфичны для проектов, но генерятся mkpydoc)
# GEN_FILES - похоже на алгоритмы: то, что еще генерится в проекте (для них нужны спец правила)
# JS_FILES - исходники на JS

# То же самое про директории - куда что копируется
# PROJ_DIR - директория проекта, исходники пойдут туда
# PROJ_LIB_DIR - туда будут копироваться библиотеки (если есть, см. выше)
# PROJ_CONF_DIR - директория с конфигурационными файлами Django
# PROJ_TEMPLATES_DIR - директория для шаблонов Django(templates)
# PROJ_ADMIN_TEMPLATES_DIR - директория для шаблонов админки Django (templates/admin)
# PROJ_CSS_DIR - директория со стилями (static)
# SCRIPT_DIR - директория со скриптами (питонными)
# DOCU_DIR - директория с исходниками sphinx (потом надо будет запустить make html для всего sphinx)
# DOCU_CSS_DIR - директория со стилями sphinx ( Docu/_static )

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
T_RST_FILES += $(FEAT_SRC_FILES)
endif
ifdef ALG_FILES
T_RST_FILES += $(ALG_FILES)
endif
ifdef GEN_FILES
T_RST_FILES += $(GEN_FILES)
endif
RST_FILES = $(sort $(T_RST_FILES) )

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
	@cp $(TO_GUI) $(PROJ_DIR);		echo Копируем исходники в папку проекта
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
	@cp $(RST_FILES) $(DOCU_DIR); echo Копируем всю документацию в Docu
ifdef DOCU_CSS_FILES
	@cp $(DOCU_CSS_FILES) $(DOCU_CSS_DIR);	echo Копируем стили в Docu/_static
endif
# ============================================================================ END

# Стандартные правила ============================================================
.dpy.py .dpy.rst:
	@echo Converting DPY file $< to RST and PY files
	@$(MKPYDOC) -i $< 

# Генерация глоссария и хинтов
ifdef MODEL_FILES
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
else
glossary.rst: gloss0.rstp
	@echo Создаем словарный .rst файл
	@echo "Список терминов" > glossary.rst
	@echo "***************\n" >> glossary.rst
	@cat gloss0.rstp >> glossary.rst
endif

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
	@echo "   :numbered: 2\n" >>sources.rst
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
	@echo "hints_data.js" >>.gitignore
	@for X in $(RST_SRC_FILES); do echo !$$X >> .gitignore ; done
