#
# Сборка генератора mkpydoc и документации по нему
#

# Директории
include local_settings.mk
PROJ_DIR=$(PYTH_PATH)
DOCU_DIR=$(DOCU_PATH)/mkpydoc

# Наши файлы исходники
DPY_FILES=mkpydoc.dpy simple.dpy model.dpy function.dpy termdef.dpy ch_utils.dpy gen_hints.dpy gen_inlines.dpy gen_feat_map.dpy rst_utils.dpy glossary.dpy
RST_SRC_FILES=index.rst build.rst generators.rst ideas.rst
ALG_FILES=syntax.rst
GEN_FILES=frefs.rst
# TEST_FILES=test.py

include $(PYTH_PATH)/mkpydoc_std.mk

# Генерация референса
frefs.rst: $(DPY_FILES)
	@echo Генерируем референс файл \(файлы frefs.имя функции.rstp генерятся mkpydoc function\)
	@cat frefs0.rstp frefs.*.rstp > frefs.rst

