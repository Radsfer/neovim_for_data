-- ============================================================================
-- 1. BOOTSTRAP (Auto-Instalação do Lazy.nvim)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 2. LISTA DE PLUGINS E CONFIGURAÇÕES
-- ============================================================================
require("lazy").setup({
  -- Cores (Catppuccin)
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function() vim.cmd.colorscheme "catppuccin" end },

  -- Telescope (Busca)
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Neo-Tree (Explorador de Arquivos estilo VSCode/LazyVim)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Ícones bonitos
      "MunifTanjim/nui.nvim",
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- Mantenha isso como true
          -- Configurações para mostrar TUDO:
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false, -- Garante que outros arquivos ocultos sejam mostrados
        },
      },
    },
  },

  -- Which-Key (Mostra menu de atalhos quando você aperta Espaço)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },

  -- LazyGit (Interface gráfica de Git dentro do Neovim)
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -- Treesitter (Coloração de sintaxe inteligente)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function () 
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "python", "lua", "vim", "javascript", "markdown", "sql", },
        highlight = { enable = true },
      }
    end
  },

  -- Venv Selector (Selecionar ambiente virtual Python)
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    opts = {
      -- APAGUE o que tinha antes (a opção 'name') e COLOQUE ISTO:
      explicit_pythons = {
        -- !!! SUBSTITUA PELO CAMINHO QUE VOCÊ COPIOU !!!
        system = "/usr/bin/python3",
      }
      -- Se você tiver outros Pythons (ex: anaconda), pode adicionar aqui:
      -- anaconda = "/home/radsfer/anaconda3/bin/python",
    }
  },

-- LSP Zero (Configuração de Linguagem/Autocomplete)
  {
    'VonHeikemen/lsp-zero.nvim', branch = 'v3.x',
    -- RESTAURE A LISTA DE DEPENDÊNCIAS COMPLETA:
    dependencies = {
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
      {'neovim/nvim-lspconfig'},
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'L3MON4D3/LuaSnip'},
    },
config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({buffer = bufnr})
      end)
      
      -- ==========================================================
      -- A CORREÇÃO ESTÁ AQUI:
      -- 1. 'mason' agora vai garantir o 'debugpy' (DAP)
      -- 2. 'mason-lspconfig' vai garantir SÓ os LSPs
      -- ==========================================================
      require('mason').setup({
        ensure_installed = {
          'debugpy' -- O DAP (Debugger) vem para cá
        }
      })
      require('mason-lspconfig').setup({
        -- 'debugpy' FOI REMOVIDO DAQUI
        ensure_installed = {'pyright', 'ruff', 'sqlls'},
        handlers = { lsp_zero.default_setup },
      })
      local cmp = require('cmp')
      cmp.setup({
        -- Esta configuração será mesclada com a do lsp-zero
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }
      })
      require('cmp').setup.filetype({'sql'},{
        sources = {
            {name = "vim-dadbod-completion"},
            {name = "buffer"},
         }
      })

    end
  },
  -- ==========================================================
  -- 6. DEBUGGER (DAP) - NOVO BLOCO
  -- ==========================================================
-- Em /lua/plugins.lua

  {
    "mfussenegger/nvim-dap",
    -- Configuração para usar o debugpy instalado pelo Mason
    config = function()
      local dap = require('dap')
      
      -- ==========================================================
      -- A CORREÇÃO ESTÁ AQUI
      -- O adaptador precisa ser um 'executable', não uma função
      -- ==========================================================
      dap.adapters.python = {
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
        args = { '-m', 'debugpy.adapter' },
      }
      -- ==========================================================

      -- O resto (as configurações de 'launch') continua igual
      dap.configurations.python = {
        {
          type = 'python', -- Este 'type' usa o 'adapter' que definimos acima
          request = 'launch',
          name = 'Lançar arquivo',
          program = '${file}', -- Rodar o arquivo atual
          pythonPath = function()
            -- Tenta usar o .venv local se existir
            if vim.fn.isdirectory('.venv') == 1 then
              return '.venv/bin/python'
            end
            -- Senão, usa o python do sistema
            return '/usr/bin/python3'
          end,
        },
      }
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = function()
      -- Tenta carregar o plugin de forma segura
      local status_ok, dapui = pcall(require, "dapui")
      if not status_ok then
        return -- Se falhar, só para de rodar este bloco
      end
      dapui.setup()
    end
  },

  -- 6. O Terminal "PyCharm-like" (ToggleTerm)
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
      open_mapping = [[<c-\>]], -- Atalho para abrir um terminal "nu"
      direction = 'float', -- Abre flutuando
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
      }
    }
  },

-- 8. PLUGIN DE COMENTÁRIOS (O CORRETO)
  {
    'terrortylor/nvim-comment',
    config = function()
      -- Nós chamamos o setup manualmente, como o erro pediu
      require('nvim_comment').setup()
    end
  },





  {
    "kristijanhusak/vim-dadbod-ui",
    "tpope/vim-dadbod", 
    "kristijanhusak/vim-dadbod-completion",
  
    
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_connections"
    end,
  },
})



