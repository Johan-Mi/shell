CFLAGS += -Wall -Wextra -Wpedantic -Wno-keyword-macro -Wno-gnu

all: main
.PHONY: all

run: main
	./main
.PHONY: all

compile_flags.txt: makefile
	$(file >$@)
	$(foreach O,$(CFLAGS),$(file >>$@,$O))
