ifeq ($(PREFIX),)
    PREFIX := /usr/bin
endif

BIN = build/hxwidgets/Main

$(BIN):
	haxe hxwidgets.hxml

run:
	$(BIN)

install: $(BIN)
	install -d $(DESTDIR)$(PREFIX)/
	install -m 755 $(BIN) $(DESTDIR)$(PREFIX)/gxinput

