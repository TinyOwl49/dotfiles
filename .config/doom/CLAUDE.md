# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Private Doom Emacs configuration (`$DOOMDIR`), symlinked/copied to `~/.config/doom` on this machine. It is not the Doom Emacs core — that lives separately at `~/.config/emacs` (`$EMACSDIR`). This directory holds only three meaningful files:

- `init.el` — declares which Doom modules are enabled (the `doom! :completion ... :lang ...` block). Editing this requires `doom sync` before it takes effect.
- `config.el` — private config loaded after modules; `use-package!`, `after!`, `map!`, `setq` for module variables, etc. No `doom sync` needed, just restart Emacs or `SPC h r r` (`doom/reload`).
- `packages.el` — declares extra packages via `package!`. Requires `doom sync` to install.

`agent/claude_setting_proposal1.md` is a standing investigation/proposal document (dated, in Japanese) tracking a full audit of this config — font issues, eglot/lsp-mode mismatches, LaTeX preview pipeline, module recommendations, with a status table of what's been applied vs. still open. Treat it as living project notes, not documentation to follow blindly — check current file contents before assuming a listed fix is or isn't applied, since it may have been updated since.

Environment on this machine: macOS (Apple Silicon), Emacs 30.2 (emacs-plus), Doom v2.2.0, native-comp enabled, LSP backend is **eglot** (`:tools lsp +eglot`), not lsp-mode.

## Commands

Doom's CLI lives at `~/.config/emacs/bin/doom` (add to PATH, or invoke by full path).

```sh
doom sync          # required after editing init.el or packages.el (module/package changes)
doom sync -u       # sync + update packages
doom sync -!       # sync with prompts auto-accepted (needed e.g. after switching Emacs binary versions)
doom doctor        # diagnose missing external tools / misconfiguration
doom gc            # delete orphaned packages/repos, compact straight dir
doom upgrade       # update Doom core + module libraries + packages
```

No test suite, linter, or build step exists for this config — validation is "does Emacs start without errors" and manual exercise of the changed feature.

To check startup health after a change:
```sh
emacs --daemon=bench 2>&1 | grep -i "Doom loaded"   # package/module count + load time
emacsclient -s bench -e '(emacs-init-time)'
emacsclient -s bench -e '(kill-emacs)'
```

## Key constraints to respect when editing

- **eglot, not lsp-mode**: because `init.el` selects `lsp +eglot`, any new `:hook` or keybinding for LSP actions must use eglot-compatible calls (`eglot-ensure`, `eglot-format`, or Doom's backend-agnostic `lsp!` dispatcher) — not `lsp-deferred`, `lsp-format-buffer`, or other lsp-mode-only functions. This has been a repeat source of silently-broken config in this repo.
- **`org-agenda-files` is an explicit allowlist**, not a recursive scan of `org-directory` (`~/org/`, an iCloud-synced tree with 30+ files including archives/templates). Adding a new file to agenda tracking means appending its path to the list in `config.el`, not reverting to `directory-files-recursively`.
- **Fonts**: `doom-font`/`doom-variable-pitch-font` must name fonts that are actually installed with the weights/styles requested (variable-font-only families silently ignore `:weight`). CJK glyph coverage is handled separately via `after-setting-font-hook` (`my/setup-fonts`) with explicit `set-fontset-font` calls per charset — this needs to stay in sync with whatever `doom-font` is set to.
- **Module flag changes in `init.el` require `doom sync`**; config.el changes don't. Don't tell the user to restart/sync when only config.el changed, and don't forget to mention sync when init.el or packages.el changed.
- This directory was untracked in the parent `dotfiles` git repo as of the last check — confirm with the user before assuming commits here are tracked/pushed anywhere.
