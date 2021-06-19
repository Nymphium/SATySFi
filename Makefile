PREFIX=/usr/local
LIBDIR=$(PREFIX)/share/satysfi
SRCROOT=src
BACKEND=src/backend
FRONTEND=src/frontend
CHARDECODER=src/chardecoder
BYTECOMP=$(FRONTEND)/bytecomp
TARGET=satysfi
BINDIR=$(PREFIX)/bin
RM=rm -f
RUBY=ruby
GENCODE_RB=gen_code.rb
INSTDEF_YAML=$(BYTECOMP)/vminstdef.yaml
DUNE=dune
INSTTYPE_GEN=$(FRONTEND)/__insttype.gen.ml
ATTYPE_GEN=$(FRONTEND)/__attype.gen.ml
CODETYPE_GEN=$(FRONTEND)/__codetype.gen.ml
UNLIFTCODE_GEN=$(FRONTEND)/__unliftcode.gen.ml
VM_GEN=$(BYTECOMP)/__vm.gen.ml
IR_GEN_0=$(BYTECOMP)/__ir_0.gen.ml
IR_GEN_1=$(BYTECOMP)/__ir_1.gen.ml
EVAL_GEN_0=$(FRONTEND)/__evaluator_0.gen.ml
EVAL_GEN_1=$(FRONTEND)/__evaluator_1.gen.ml
PRIM_PDF_GEN=$(FRONTEND)/__primitives_pdf_mode.gen.ml
PRIM_TEXT_GEN=$(FRONTEND)/__primitives_text_mode.gen.ml
GENS= \
  $(INSTTYPE_GEN) \
  $(ATTYPE_GEN) \
  $(CODETYPE_GEN) \
  $(UNLIFTCODE_GEN) \
  $(VM_GEN) \
  $(IR_GEN_0) \
  $(IR_GEN_1) \
  $(EVAL_GEN_0) \
  $(EVAL_GEN_1) \
  $(PRIM_PDF_GEN) \
  $(PRIM_TEXT_GEN)
GENCODE_DIR=tools/gencode
GENCODE_EXE=gencode.exe
GENCODE_BIN=$(GENCODE_DIR)/_build/default/$(GENCODE_EXE)
GENCODE=$(DUNE) exec --root $(GENCODE_DIR) ./$(GENCODE_EXE) --
INSTDEF=$(GENCODE_DIR)/vminst.ml

.PHONY: all gen install lib uninstall clean

all: gen
	$(DUNE) build --root .
	cp _build/install/default/bin/$(TARGET) .

$(INSTDEF): $(INSTDEF_YAML)
	$(RUBY) $(GENCODE_RB) --ml $< > $@

gen: $(GENS)

$(ATTYPE_GEN): $(INSTDEF)
	$(GENCODE) --gen-attype > $@

$(CODETYPE_GEN): $(INSTDEF)
	$(GENCODE) --gen-codetype > $@

$(UNLIFTCODE_GEN):
	$(GENCODE) --gen-unliftcode > $@

$(INSTTYPE_GEN): $(INSTDEF)
	$(GENCODE) --gen-insttype > $@

$(VM_GEN): $(INSTDEF)
	$(GENCODE) --gen-vm > $@

$(IR_GEN_0): $(INSTDEF)
	$(GENCODE) --gen-ir-0 > $@

$(IR_GEN_1): $(INSTDEF)
	$(GENCODE) --gen-ir-1 > $@

$(EVAL_GEN_0): $(INSTDEF)
	$(GENCODE) --gen-interps-0 > $@

$(EVAL_GEN_1): $(INSTDEF)
	$(GENCODE) --gen-interps-1 > $@

$(PRIM_PDF_GEN): $(INSTDEF)
	$(GENCODE) --gen-pdf-mode-prims > $@

$(PRIM_TEXT_GEN): $(INSTDEF)
	$(GENCODE) --gen-text-mode-prims > $@

install: $(TARGET)
	mkdir -p $(BINDIR)
	install $(TARGET) $(BINDIR)

#preliminary:
#	[ -d .git ] && git submodule update -i || echo "Skip git submodule update -i"

uninstall:
	rm -rf $(BINDIR)/$(TARGET)
	rm -rf $(LIBDIR)

clean:
	$(DUNE) clean
	$(RM) $(GENS)
	$(RM) satysfi
