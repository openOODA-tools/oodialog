Name:           oodialog
Version:        0.1.0
Release:        1%{?dist}
Summary:        Renders interactive modal dialogues, input boxes, checklists, and file pickers.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/oodialog
Source0:        oodialog-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oodialog is a sovereign, capability-bounded TUI MODAL ENGINE written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oodialog
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oodialog-uninstall

%files
/usr/bin/oodialog
/usr/bin/oodialog-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
