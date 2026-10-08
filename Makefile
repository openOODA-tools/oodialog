# oodialog v0.2.0 Makefile

OODA_COMPILER ?= $(firstword $(wildcard $(HOME)/.openooda/bin/oodac $(CURDIR)/../../openOODA/oodac/bin/oodac))
OODACODEX ?= $(HOME)/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592
BIN := dist/oodialog

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

SRC := $(wildcard *.oo) $(wildcard */*.oo)
VERSION ?= $(shell cat VERSION 2>/dev/null || echo 0.2.0)

.PHONY: build check line-cap file-law academy density verify clean test package package-deb package-rpm package-arch install uninstall

build: $(BIN)

$(BIN): $(SRC)
	@mkdir -p dist .ooda-cache/ooda-tmp
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) build main.oo -o $(BIN)
	@chmod +x $(BIN)
	@cp -a $(BIN) dist/oodialog-linux-x86_64
	@sha256sum dist/oodialog-linux-x86_64 > dist/oodialog-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oodialog-linux-x86_64)"

# --- Verification gate ---------------------------------------------------------

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v "/dist/" | grep -v "/.ooda-cache/"); do \
		n=$$(wc -l < "$$f"); \
		if [ $$n -gt 256 ]; then \
			echo "VIOLATION: $$f = $$n lines (exceeds 256)"; violations=$$((violations+1)); \
		fi; \
		code=$$(grep -vE '^[[:space:]]*(//.*)?$$' "$$f" | grep -cvE '^[[:space:]]*import[[:space:]]+"'); \
		if [ "$$code" = "0" ]; then continue; fi; \
		if [ $$n -lt 16 ]; then \
			echo "VIOLATION: $$f = $$n lines (under 16-line floor, not a shim)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate the Page Rule"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@forbidden="js ts rb pl json yaml toml"; \
	violations=0; \
	for ext in $$forbidden; do \
		found=$$(find . -name "*.$$ext" -not -path "./.git/*" -not -path "./.github/*" -not -path "./dist/*" -not -path "./.ooda-cache/*" 2>/dev/null | head -3); \
		if [ -n "$$found" ]; then \
			echo "VIOLATION: .$$ext forbidden:"; echo "$$found"; violations=$$((violations+1)); \
		fi; \
	done; \
	for f in $$(find . -name "*.md" -not -path "./.git/*" -not -path "./.github/*" -not -path "./dist/*" -not -path "./.ooda-cache/*" 2>/dev/null); do \
		if [ "$$f" != "./README.md" ] && [ "$$f" != "./AGENTS.md" ]; then \
			echo "VIOLATION: .md forbidden outside README.md and AGENTS.md: $$f"; violations=$$((violations+1)); \
		fi; \
	done; \
	for f in $$(find . -name "*.sh" -not -path "./.git/*" -not -path "./dist/*" 2>/dev/null); do \
		if [ "$$f" != "./install.sh" ] && [ "$$f" != "./uninstall.sh" ]; then \
			echo "VIOLATION: .sh forbidden outside install.sh and uninstall.sh: $$f"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: file-law violations"; exit 1; fi; \
	echo "PASS: file law holds"

academy:
	@failures=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		header=$$(head -7 "$$f"); \
		missing=""; \
		echo "$$header" | grep -q "^// # "        || missing="$$missing title"; \
		echo "$$header" | grep -q "^// Logline:"  || missing="$$missing logline"; \
		echo "$$header" | grep -q "^// Setup:"    || missing="$$missing setup"; \
		echo "$$header" | grep -q "^// Beats:"    || missing="$$missing beats"; \
		if [ -n "$$missing" ]; then \
			echo "FAIL: $$f missing Academy element(s):$$missing"; failures=$$((failures+1)); \
		fi; \
	done; \
	if [ $$failures -gt 0 ]; then echo "FAIL: $$failures academy header violations"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -type d -not -path "./.git*" -not -path "./dist*" -not -path "./.ooda-cache*" -not -path "./packaging*" -not -path "./qa*"); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help > /dev/null && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version | grep -q "0.2.0" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "oodialog: internal anchor tests PASSED" && echo "PASS: internal anchors"
	@echo "=== testing --demo ==="
	@./$(BIN) -D | grep -q "SOVEREIGN TUI SHOWCASE" && echo "PASS: --demo"
	@echo "=== testing --demo --json ==="
	@./$(BIN) -D -j | grep -q "oodialog" && echo "PASS: --demo -j"
	@echo "=== testing msgbox ==="
	@./$(BIN) --title "MSG" --msgbox "System update complete." | grep -q "System update complete" && echo "PASS: msgbox"
	@echo "=== testing yesno ==="
	@./$(BIN) --title "YESNO" --yesno "Confirm operation?" | grep -q "Confirm operation" && echo "PASS: yesno"
	@echo "=== testing menu ==="
	@./$(BIN) --title "MENU" --menu "Choose task:" 0 0 0 1 "Opt A" 2 "Opt B" | grep -q "Opt A" && echo "PASS: menu"
	@echo "=== testing checklist ==="
	@./$(BIN) --title "CHK" --checklist "Features:" 0 0 0 F1 "Feature 1" on | grep -q "\[X\] F1" && echo "PASS: checklist"
	@echo "=== testing gauge ==="
	@./$(BIN) --title "GAUGE" --gauge "Working..." 0 0 50 | grep -q "50%" && echo "PASS: gauge"
	@echo "=== testing ascii-lines ==="
	@./$(BIN) --title "ASCII" --ascii-lines --msgbox "ASCII frame" | grep -q "+-- ASCII" && echo "PASS: ascii-lines"
	@echo "=== testing MCP initialize ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "dialog_msgbox" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call dialog_msgbox ==="
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"dialog_msgbox","arguments":{"title":"MCP_TEST","text":"Hello World"}}}\n' | ./$(BIN) --mcp | grep -q 'MCP_TEST' && echo "PASS: MCP dialog_msgbox"
	@echo "=== testing MCP tools/call dialog_yesno ==="
	@printf '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"dialog_yesno","arguments":{"title":"CONFIRM","text":"Proceed?"}}}\n' | ./$(BIN) --mcp | grep -q 'CONFIRM' && echo "PASS: MCP dialog_yesno"
	@echo "=== testing MCP tools/call dialog_menu ==="
	@printf '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"dialog_menu","arguments":{"title":"SELECT"}}}\n' | ./$(BIN) --mcp | grep -q 'SELECT' && echo "PASS: MCP dialog_menu"
	@echo "=== testing MCP tools/call dialog_checklist ==="
	@printf '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"dialog_checklist","arguments":{"title":"RULES"}}}\n' | ./$(BIN) --mcp | grep -q 'RULES' && echo "PASS: MCP dialog_checklist"
	@echo "=== testing MCP tools/call dialog_gauge ==="
	@printf '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"dialog_gauge","arguments":{"percent":85}}}\n' | ./$(BIN) --mcp | grep -q '85%' && echo "PASS: MCP dialog_gauge"
	@echo "=== testing MCP tools/call dialog_demo ==="
	@printf '{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"dialog_demo","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q 'SHOWCASE' && echo "PASS: MCP dialog_demo"
	@echo "ALL TESTS PASSED"

install: $(BIN)
	@mkdir -p $(DESTDIR)$(BINDIR)
	install -m 0755 $(BIN) $(DESTDIR)$(BINDIR)/oodialog
	install -m 0755 uninstall.sh $(DESTDIR)$(BINDIR)/oodialog-uninstall
	@echo "installed oodialog and oodialog-uninstall to $(DESTDIR)$(BINDIR)"

uninstall:
	@rm -f $(DESTDIR)$(BINDIR)/oodialog $(DESTDIR)$(BINDIR)/oodialog-uninstall
	@if [ "$(PURGE)" = "1" ]; then rm -rf $(HOME)/.cache/oodialog $(HOME)/.config/oodialog; echo "purged user cache and config"; fi
	@echo "uninstalled oodialog and oodialog-uninstall from $(DESTDIR)$(BINDIR)"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oodialog
	@chmod 0755 dist/deb-root/usr/bin/oodialog
	@cp uninstall.sh dist/deb-root/usr/bin/oodialog-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oodialog-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oodialog_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oodialog_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oodialog-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oodialog.spec > ~/rpmbuild/SPECS/oodialog.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oodialog.spec
	@cp ~/rpmbuild/RPMS/x86_64/oodialog-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oodialog
	@chmod 0755 dist/arch-pkg/usr/bin/oodialog
	@cp uninstall.sh dist/arch-pkg/usr/bin/oodialog-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oodialog-uninstall
	@printf "pkgname = oodialog\npkgbase = oodialog\npkgver = $(VERSION)-1\npkgdesc = Sovereign TUI modal dialogue and input box interface engine in pure openOODA.\nurl = https://github.com/openOODA-tools/oodialog\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oodialog\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oodialog-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oodialog-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cd dist && sha256sum oodialog* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
