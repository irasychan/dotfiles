# LazyVim Conjure Keymap Leak — Handoff

## Goal

Fix the Clojure extra in LazyVim that leaks Conjure keymaps to all buffers,
and submit a PR upstream.

## Issue

https://github.com/LazyVim/LazyVim/issues/7064

## Status

- [x] Identify root cause
- [x] Verify bug is reproducible (confirmed in two projects)
- [x] Write analysis document (`analysis.md`)
- [x] Apply local workaround (`nvim/.config/nvim/lua/plugins/clojure.lua`)
- [x] File upstream issue (#7064)
- [x] Fork and clone LazyVim to `~/workspace/LazyVim`
- [x] Create fix branch (`fix/conjure-keymap-leak`) and apply one-line fix
- [x] Test with headless repro (confirmed 24 maps on .clj, 0 on .md)
- [x] Submit PR: https://github.com/LazyVim/LazyVim/pull/7065
- [x] Respond to reviewer comment (dpetka2001) — confirmed `config` with `main()` is necessary
- [ ] PR merged

## Root Cause (quick summary)

In `lua/lazyvim/plugins/extras/lang/clojure.lua`, the Conjure spec has:

```lua
config = function(_, _)
  require("conjure.main").main()
  require("conjure.mapping")["on-filetype"]()  -- BUG
end,
```

`main()` already calls `mapping.init(filetypes)` which conditionally sets up
keymaps only for supported filetypes. The extra `on-filetype()` bypasses
that guard and sets keymaps on whatever buffer is active.

## The Fix

Remove one line:

```diff
     config = function(_, _)
       require("conjure.main").main()
-      require("conjure.mapping")["on-filetype"]()
     end,
```

File: `lua/lazyvim/plugins/extras/lang/clojure.lua` (line 55 in current main)

## Key Files

| File | Location | Purpose |
|------|----------|---------|
| Analysis | `dotfiles/docs/lazyvim-conjure-fix/analysis.md` | Full bug analysis, PR draft, Q&A |
| Local workaround | `dotfiles/nvim/.config/nvim/lua/plugins/clojure.lua` | Overrides Conjure spec locally |
| Fix target | `LazyVim/lua/lazyvim/plugins/extras/lang/clojure.lua` | The file to patch |
| Fork | `~/workspace/LazyVim` | Cloned fork (origin = your fork, upstream = LazyVim/LazyVim) |

## Repo Setup

```
~/workspace/LazyVim/
  origin   -> your GitHub fork
  upstream -> LazyVim/LazyVim
```

## PR

- URL: https://github.com/LazyVim/LazyVim/pull/7065
- Branch: `fix/conjure-keymap-leak`
- CI: flaky `defaults should be loaded` failure on first run (same failure seen on main); rebased on upstream fix and force-pushed

## Reviewer Feedback

dpetka2001 asked if the `config` function could be removed entirely. Tested locally:

| Config | `.clj` maps | `.md` maps |
|---|---|---|
| Original (`main()` + `on-filetype()`) | 24 | **20 (leaked)** |
| This PR (`main()` only) | 24 | **0** |
| No `config` at all | 0 | 0 |

`config` with `main()` is required. The loading sequence explains why:

1. User opens a file (e.g. `test.clj`)
2. `LazyFile` event triggers — lazy.nvim loads Conjure
3. Conjure's `plugin/conjure.lua` would normally call `main()`, but lazy.nvim
   does not source `plugin/` files for lazy-loaded plugins in the same way
4. The `config` function explicitly calls `main()`, which runs `mapping.init(filetypes)`
5. `mapping.init()` registers a `FileType` autocmd for supported filetypes AND
   checks if the current buffer already has a matching filetype — if so, it
   schedules `on-filetype()` via `vim.schedule()`

Without `config`, step 4 never happens, so no keymaps are set at all.
The removed `on-filetype()` call was redundant because `main()` already handles
the current buffer, but it bypassed the filetype guard and leaked keymaps to
whatever buffer triggered the load.

## Notes

- LazyVim CONTRIBUTING.md requires proper lazy-loading for every plugin in extras
- Precedent: PR #4849 fixed an analogous LSP keymap leak (merged Nov 2024)
- The `event = "LazyFile"` vs `ft = { "clojure" }` discussion is separate — the
  minimal fix just removes the redundant line
- Local workaround also clears `event` and restricts `g:conjure#filetypes` since
  lazy.nvim merges specs (can't just override one field)
- GPG key updated on GitHub to include both `ira.sychan@gmail.com` and `ira@sidegiglab.com` for verified commits
