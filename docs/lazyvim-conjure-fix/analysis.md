# LazyVim Clojure Extra: Conjure Keymaps Leak to Non-Clojure Buffers

---

## Brief

The LazyVim Clojure extra's `config` function calls
`require("conjure.mapping")["on-filetype"]()` unconditionally after
`require("conjure.main").main()`. Since the plugin loads on `event = "LazyFile"`
(any file), this sets Conjure's buffer-local keymaps (`<localleader>ee`,
`<localleader>er`, `K`, `gd`, etc.) on whatever buffer happens to trigger the
load — even markdown, JSON, TypeScript, or any non-Clojure file.

The call is redundant: `main()` internally calls `mapping.init(filetypes)`,
which already registers a `FileType` autocmd for supported filetypes **and**
conditionally calls `on-filetype()` for the current buffer only if its filetype
matches. The extra `on-filetype()` bypasses that guard.

**Reproduced:** Confirmed in two separate projects (a TypeScript/Next.js app
and a dotfiles repo). Opening `README.md` in either project shows the full set
of Conjure keymaps on the markdown buffer via `:nmap <localleader>`.

**Fix:** Remove the redundant line. One-line change.

**Precedent:** [PR #4849](https://github.com/LazyVim/LazyVim/pull/4849) fixed
an analogous keymap leak for LSP server configs.

---

## PR Draft

### Title

fix(clojure): remove redundant `on-filetype()` call that leaks keymaps

### Description

The Clojure extra's Conjure spec calls
`require("conjure.mapping")["on-filetype"]()` unconditionally in its `config`
function. Because the plugin loads on `event = "LazyFile"` (any file open),
this sets Conjure's buffer-local keymaps on whatever buffer triggered the load,
regardless of filetype.

This call is redundant. `require("conjure.main").main()` internally calls
`mapping.init(filetypes)`, which:

1. Registers a `FileType` autocmd scoped to supported filetypes.
2. Checks if the current buffer's filetype is in the list before calling
   `on-filetype()`.

From `conjure/mapping.lua`:

```lua
M.init = function(filetypes)
  local group = vim.api.nvim_create_augroup("conjure_init_filetypes", {})
  if (true == config["get-in"]({"mapping", "enable_ft_mappings"})) then
    vim.api.nvim_create_autocmd("FileType", {
      group = group, pattern = filetypes,
      callback = autocmd_callback(M["on-filetype"])
    })
    if core.some(function(x) return x == vim.bo.filetype end, filetypes) then
      vim.schedule(M["on-filetype"])
    end
  end
end
```

The extra `on-filetype()` bypasses this guard. Removing it restores the intended
behavior: Conjure keymaps only appear in buffers whose filetype Conjure supports.

### Related Issue(s)

- Fixes #XXXX (file the bug report first, then reference it)

### Commit Message

```
fix(clojure): remove redundant on-filetype() call that leaks keymaps

The Conjure spec calls `require("conjure.mapping")["on-filetype"]()`
unconditionally in its `config` function. Because the plugin loads on
`event = "LazyFile"` (any file open), this sets Conjure's buffer-local
keymaps on whatever buffer triggered the load, regardless of filetype.

This call is redundant. `require("conjure.main").main()` internally
calls `mapping.init(filetypes)`, which registers a FileType autocmd
scoped to supported filetypes and checks the current buffer's filetype
before calling `on-filetype()`. The extra call bypasses that guard.

Fixes #7064
```

### Diff

```diff
diff --git a/lua/lazyvim/plugins/extras/lang/clojure.lua b/lua/lazyvim/plugins/extras/lang/clojure.lua
--- a/lua/lazyvim/plugins/extras/lang/clojure.lua
+++ b/lua/lazyvim/plugins/extras/lang/clojure.lua
@@ -50,7 +50,6 @@
     "Olical/conjure",
     event = "LazyFile",
     config = function(_, _)
       require("conjure.main").main()
-      require("conjure.mapping")["on-filetype"]()
     end,
     init = function()
```

### Repro

Save as `repro.lua` and run with `nvim -u repro.lua`. Open any non-Clojure
file (e.g. `:e test.md`), then check keymaps with `:nmap <localleader>`.

```lua
vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").repro({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.clojure" },
  },
})
```

Steps:
1. `nvim -u repro.lua`
2. `:e test.md`
3. `:nmap <localleader>` — observe Conjure keymaps on a markdown buffer:
   ```
   n  \ee  *@<Lua ...: .../conjure/lua/conjure/mapping.lua:31>  Evaluate current form
   n  \er  *@<Lua ...: .../conjure/lua/conjure/mapping.lua:31>  Evaluate root form
   n  \ls  *@<Lua ...: .../conjure/lua/conjure/mapping.lua:31>  Open log in new horizontal split window
   n  \K   *@<Lua ...: .../conjure/lua/conjure/mapping.lua:31>  Get documentation under cursor
   n  \gd  *@<Lua ...: .../conjure/lua/conjure/mapping.lua:31>  Get definition under cursor
   ... (25+ Conjure keymaps total)
   ```
4. These should not be present in a markdown buffer.

### Checklist

- [x] I've read the [CONTRIBUTING](https://github.com/LazyVim/LazyVim/blob/main/CONTRIBUTING.md) guidelines.

---

## Q&A — Anticipated Questions

### Why not change `event = "LazyFile"` to `ft = { "clojure", "edn" }`?

That would also fix the leak, but it changes the loading behavior more broadly.
With `event = "LazyFile"`, Conjure loads early and is ready when a Clojure
buffer opens later. With `ft`, it only loads on the first Clojure buffer. Both
work, but the minimal fix is removing the redundant line — it preserves the
existing loading strategy while fixing the bug.

If the maintainers prefer `ft`-based loading, that's a fine alternative, but
it's a separate discussion about lazy-loading strategy.

### Does `main()` already handle the first-buffer case?

Yes. `mapping.init()` (called by `main()`) checks if the current buffer's
filetype is in the supported list. If it is, it calls `on-filetype()` via
`vim.schedule()`. If not, it skips — and the `FileType` autocmd handles future
buffers. The extra `on-filetype()` was likely added as a safety net, but it
defeats the guard.

### What about Conjure's default filetypes list being too broad?

Conjure supports 12 languages by default (clojure, lua, python, ruby, rust,
sql, etc.). This is a Conjure design choice, not a LazyVim bug. Users who only
want Clojure can set `vim.g["conjure#filetypes"] = { "clojure" }` in their own
config. The LazyVim extra could optionally restrict this, but that's a separate
enhancement — the keymap leak to *completely unsupported* filetypes (markdown,
JSON) is the bug being fixed here.

### Could removing the line break Conjure for the first Clojure buffer?

No. `mapping.init()` already handles this case with the `core.some()` check.
If the triggering buffer is a Clojure file, `on-filetype()` is called via
`vim.schedule()`. If it's not a Clojure file, the `FileType` autocmd catches
future Clojure buffers. Both paths are covered.

### How does this compare to PR #4849 (LSP keymap leak fix)?

PR #4849 fixed LSP server-specific keymaps (e.g., omnisharp's `gd`) leaking to
unrelated buffers. Same category of bug: language-specific keymaps appearing
where they shouldn't. That PR was merged in Nov 2024, establishing precedent
that this type of fix is accepted.

### Why are `K` and `gd` specifically problematic?

The LazyVim Clojure extra remaps Conjure's `K` (doc lookup) and `gd`
(definition) to `<localleader>K` and `<localleader>gd`. But the unconditional
`on-filetype()` call still sets other Conjure mappings. More importantly, users
who haven't customized these may get Conjure's `K`/`gd` overriding LSP hover
and go-to-definition in non-Clojure buffers — directly contradicting the
CONTRIBUTING.md guideline: "Don't override standard LSP keymaps (like `K` for
hover, `gd` for definition) unless absolutely necessary."

---

## References

- LazyVim Clojure extra source: `lua/lazyvim/plugins/extras/lang/clojure.lua`
- [LazyVim PR #2179](https://github.com/LazyVim/LazyVim/pull/2179) — original PR adding Clojure support
- [LazyVim PR #4849](https://github.com/LazyVim/LazyVim/pull/4849) — analogous LSP keymap leak fix
- [Conjure #614](https://github.com/Olical/conjure/issues/614) — Conjure hijacks `<leader>gd`
- [Conjure #628](https://github.com/Olical/conjure/issues/628) — Conjure ignores filetypes config when loaded eagerly
- [Conjure #749](https://github.com/Olical/conjure/issues/749) — cannot unmap Conjure's `K` per-filetype

## Local Workaround

Until fixed upstream, add to your own plugin config (`lua/plugins/clojure.lua`):

```lua
return {
  {
    "Olical/conjure",
    ft = { "clojure", "edn" },
    init = function()
      vim.g["conjure#filetypes"] = { "clojure", "edn" }
    end,
  },
}
```
