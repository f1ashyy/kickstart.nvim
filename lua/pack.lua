-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim,
  --  which provides a Lua interface for installing and managing plugins.
  --
  --  See `:help vim.pack`, `:help vim.pack-examples` or the
  --  excellent blog post from the creator of vim.pack and mini.nvim:
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  To inspect plugin state and pending updates, run
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  To update plugins, run
  --    :lua vim.pack.update()
  --
  --
  --  Throughout the rest of the config there will be examples
  --  of how to install and configure plugins using `vim.pack`.
  --
  --  In this section we set up some autocommands to run build
  --  steps for certain plugins after they are installed or updated.

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================

-- [[ Installing and Configuring Plugins ]]
--
-- To install a plugin simply call `vim.pack.add` with its git url.
-- This will download the default branch of the plugin, which will usually be `main` or `master`
-- You can also have more advanced specs, which we will talk about later.
--
-- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
--
-- For example, lets say we want to install `guess-indent.nvim` - a plugin for
-- automatically detecting and setting the indentation.
--
-- We first install it from https://github.com/NMAC427/guess-indent.nvim
-- and then call its `setup()` function to start it with default settings.
---------------------------------------
---------------------------------------
--This block is for telescope kickstart logic of installing multiple plugins and some
---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end
---------------------------------------
---------------------------------------
vim.pack.add {
  -- automatically detecting and setting the indentation.
  gh 'NMAC427/guess-indent.nvim',

  -- Adds git related signs to the gutter, as well as utilities for managing changes
  gh 'lewis6991/gitsigns.nvim',

  -- Useful plugin to show you pending keybinds.
  gh 'folke/which-key.nvim',

  -- ColorScheme
  gh 'folke/tokyonight.nvim',

  -- Highlight todo, notes, etc in comments
  gh 'folke/todo-comments.nvim',

  --  mini.nvim
  --  A collection of various small independent plugins/modules
  gh 'nvim-mini/mini.nvim',

  -- telescope was orignally called here

  -- Useful status updates for LSP.
  gh 'j-hui/fidget.nvim',

  -- lsp and mason
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',

  -- debugger given given by kickstart
  gh 'mfussenegger/nvim-dap',
  gh 'rcarriga/nvim-dap-ui',
  gh 'nvim-neotest/nvim-nio',
  -- gh '/mason-org/mason.nvim',
  gh 'jay-babu/mason-nvim-dap.nvim',
  -- gh 'leoluz/nvim-dap-go',  (Go Debugger)
  gh 'mfussenegger/nvim-dap-python',

  -- Formatter
  gh 'stevearc/conform.nvim',

  -- Linting
  gh 'mfussenegger/nvim-lint',

  -- Rainbow brackets
  gh 'hiphish/rainbow-delimiters.nvim',

  -- Indent_lines
  gh 'lukas-reineke/indent-blankline.nvim',

  -- Auto pairs
  gh 'windwp/nvim-autopairs',

  -- Undo Tree
  gh 'mbbill/undotree',

  -- Neo-Tree
  {
    src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
    version = vim.version.range '*',
  },
  -- Neo tree dependencies
  gh 'nvim-lua/plenary.nvim', -- this one is also needed for harpoon 2
  gh 'MunifTanjim/nui.nvim',

  -- Harpoon 2
  {
    src = gh 'ThePrimeagen/harpoon',
    version = 'harpoon2',
  },
  -- Snippet Engine

  -- NOTE: You can also specify plugin using a version range for its git tag.
  --  See `:help vim.version.range()` for more info
  {
    src = gh 'L3MON4D3/LuaSnip',
    version = vim.version.range '2.*',
  },

  -- Autocomplete Engine
  {
    src = gh 'saghen/blink.cmp',
    version = vim.version.range '1.*',
  },

  -- Configure Treesitter
  -- Used to highlight, edit, and navigate code
  -- See `:help nvim-treesitter-intro`

  -- NOTE: You can also specify a branch or a specific commit
  {
    src = gh 'nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
}

-- that some strange looking logic above is for this
-- NOTE: You can install multiple plugins at once
vim.pack.add(telescope_plugins)
