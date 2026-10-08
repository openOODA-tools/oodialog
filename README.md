# oodialog: Sovereign Terminal Modal Dialogue & Widget Engine

<div align="center">

```
================================================================================
                               oodialog v0.2.0
               Sovereign openOODA TUI Modal Dialogue Engine
================================================================================
```

**Sovereign Terminal Modal Dialogue & Widget Engine**  
*Renders interactive modal dialogues, input boxes, checklists, menus, and progress gauges.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage streaming MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64](https://img.shields.io/badge/Arch-x86__64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64)
```bash
curl -fsSL https://openooda-tools.github.io/oodialog/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oodialog-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oodialog/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oodialog/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oodialog-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oodialog/uninstall.sh | bash
```

---

## 2. CLI Usage & Widgets

```
Usage: oodialog [OPTIONS]... <--widget> [WIDGET_ARGS]...

Box Options:
  --title <text>           Set modal frame title
  --backtitle <text>       Set top canvas backtitle banner
  --theme <name>           ANSI palette (ember, ocean, matrix, cyber, monochrome)
  --ascii-lines            Use plain ASCII box borders (+, -, |) instead of Unicode
  --defaultno              Set 'No' as default focus in yesno dialogs

Widgets:
  --msgbox <text> [h] [w]                      Display informative message box
  --yesno <text> [h] [w]                       Prompt for confirmation (exit 0=Yes, 1=No)
  --infobox <text> [h] [w]                     Display message without buttons
  --inputbox <text> [h] [w] [init]             Prompt for user text input
  --menu <text> [h] [w] [mh] tag1 item1 ...    Display select menu list
  --checklist <text> [h] [w] [lh] t i s ...    Display multi-select checklist
  --radiolist <text> [h] [w] [lh] t i s ...    Display single-select radiolist
  --gauge <text> [h] [w] [percent]             Display progress gauge bar

General Options:
  -j, --json               Output modal metadata or result in JSON format
  -D, --demo               Run interactive showcase of all modal dialog types
      --mcp                Launch streaming MCP JSON-RPC 2.0 stdio server
      --help               Display this help and exit
  -v, --version            Output version information and exit
```

### Examples
```bash
# Display informative modal message box
oodialog --title "SYSTEM NOTICE" --msgbox "Kernel update applied successfully."

# Confirmation query with 'No' default
oodialog --title "CONFIRM" --defaultno --yesno "Proceed with volume format?"

# Multi-select checklist
oodialog --title "FEATURES" --checklist "Enable services:" 0 0 0 SSH "SSH Server" on DB "Database" off

# Progress gauge bar
oodialog --title "BACKUP" --gauge "Archiving filesystem blocks..." 0 0 75

# Synthetic showcase demonstration
oodialog --demo --theme=ocean
```

---

## 3. Model Context Protocol (MCP)

When invoked with `--mcp`, `oodialog` runs a streaming JSON-RPC 2.0 stdio server providing structured tools for AI coding agents:

```bash
oodialog --mcp
```

### Registered Tools

| Tool | Parameters | Description |
| :--- | :--- | :--- |
| `dialog_render` | `kind`, `title`, `text`, `theme`, `ascii_lines` | Universal dialog renderer for any widget type. |
| `dialog_msgbox` | `title`, `text`, `theme` | Render an informative modal message box. |
| `dialog_yesno` | `title`, `text`, `default_no`, `theme` | Render a confirmation prompt with Yes/No buttons. |
| `dialog_menu` | `title`, `text`, `theme` | Render an administrative task select menu. |
| `dialog_checklist` | `title`, `text`, `theme` | Render a multi-select feature checklist. |
| `dialog_gauge` | `title`, `text`, `percent`, `theme` | Render a percentage-based progress gauge bar. |
| `dialog_demo` | *(none)* | Return comprehensive multi-modal dialog showcase document. |

---

## 4. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit capability tokens (`&FsReadCap`, `&ProcessCap`, `&EnvCap`). Physical absence of ambient disk writing or socket network leakage.
* **Negative-Trust Architecture:** Strict input bounding and terminal dimensions validation.
* **Hermetic Binary:** Standalone zero-dependency executable compiled via `oodac`.

---

## 5. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
