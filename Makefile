PREFIX ?= /usr/local

# APPLICATION
BIN_NAME=git-gossip

# TOOLS
PANDOC=pandoc
PANDOC_FLAGS=--standalone
SHELLCHECK=shellcheck
SHELLCHECK_FLAGS=-e SC2076

SRC_DIR=src
DST_DIR=build

# ENTRY TARGETS
.PHONY: all clean install uninstall
all: executables man-pages
clean:
	-rm -rf $(DST_DIR)
install: install-executables install-man-pages
uninstall: uninstall-executables uninstall-man-pages

# EXECUTABLES
SRC_BIN_DIR=$(SRC_DIR)/bin
DST_BIN_DIR=$(DST_DIR)/bin

.PHONY: executables
executables: $(DST_BIN_DIR)/$(BIN_NAME)
$(DST_BIN_DIR)/$(BIN_NAME): $(SRC_BIN_DIR)/$(BIN_NAME)
	$(SHELLCHECK) $(SHELLCHECK_FLAGS) $^
	install -D $^ $@

.PHONY: install-executables uninstall-executables
install-executables:
	install -Dm555 $(DST_BIN_DIR)/$(BIN_NAME) -t $(PREFIX)/bin
uninstall-executables:
	rm -f $(PREFIX)/bin/$(BIN_NAME)

# MAN PAGES
SRC_MAN_DIR=$(SRC_DIR)/man
DST_MAN_DIR=$(DST_DIR)/share/man
MAN_SRC_FILES=$(wildcard $(SRC_MAN_DIR)/*.md)
MAN_DST_FILES=$(patsubst $(SRC_MAN_DIR)/%.md, $(DST_MAN_DIR)/%.gz, $(MAN_SRC_FILES))

.PHONY: man-pages
man-pages: $(MAN_DST_FILES)
$(DST_MAN_DIR)/%.gz: $(SRC_MAN_DIR)/%.md
	mkdir -p $(dir $@)
	$(PANDOC) $(PANDOC_FLAGS) --to man $^ | gzip > $@

.PHONY: install-man-pages uninstall-man-pages
install-man-pages:
	install -Dm444 $(wildcard $(DST_MAN_DIR)/*.1.gz) -t $(PREFIX)/share/man/man1
uninstall-man-pages:
	rm -f $(patsubst $(DST_MAN_DIR)/%, $(PREFIX)/share/man/man1/%, $(filter %.1.gz, $(wildcard $(MAN_DST_FILES))))

