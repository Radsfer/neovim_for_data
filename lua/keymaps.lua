local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.g.mapleader = " " 

-- ============================================================================
-- 1. PADRÃO LAZYVIM (Navegação & Editor)
-- ============================================================================

-- Mover entre Janelas com Ctrl + hjkl (Sem precisar de Leader)
keymap("n", "<C-h>", "<C-w>h", { desc = "Ir para Janela Esquerda" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Ir para Janela Baixo" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Ir para Janela Cima" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Ir para Janela Direita" })

-- Redimensionar Janelas com Ctrl + Setas
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffers (Abas) com Shift + h/l
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Aba Anterior" })
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Próxima Aba" })
keymap("n", "<leader>bb", ":e #<CR>", { desc = "Alternar último buffer" })
keymap("n", "<leader>bd", ":bd<CR>", { desc = "Fechar Buffer Atual" })

-- Mover Linhas (Alt + j/k) - Igual VSCode/LazyVim
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Mover linha baixo" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Mover linha cima" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover bloco baixo" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover bloco cima" })

-- --- ATALHOS DE SPLIT (O QUE FALTAVA) ---
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split Vertical" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Split Horizontal" })
keymap("n", "<leader>sc", "<C-w>c", { desc = "Fechar Split Atual" })

-- Salvar e Sair (Padrão LazyVim)
keymap("n", "<leader>ww", ":w<CR>", { desc = "Salvar Arquivo" })
keymap("n", "<leader>qq", ":qa<CR>", { desc = "Sair de Tudo" })

-- ============================================================================
-- 2. PLUGINS LAZYVIM (NeoTree, Telescope, Git)
-- ============================================================================

-- Neo-Tree (Explorador de Arquivos)
keymap("n", "<leader>e", ":Neotree toggle position=left<CR>", { desc = "Explorador de Arquivos (Tree)" })

-- Telescope (Busca)
keymap("n", "<leader><space>", function() require('telescope.builtin').find_files() end, { desc = "Buscar Arquivos (Root)" })
keymap("n", "<leader>ff", function() require('telescope.builtin').find_files() end, { desc = "Buscar Arquivos" })
keymap("n", "<leader>fg", function() require('telescope.builtin').live_grep() end, { desc = "Buscar Texto (Grep)" })
keymap("n", "<leader>fb", function() require('telescope.builtin').buffers() end, { desc = "Buscar Buffers Abertos" })
keymap("n", "<leader>fr", function() require('telescope.builtin').oldfiles() end, { desc = "Arquivos Recentes" })
-- LazyGit
keymap("n", "<leader>gg", ":LazyGit<CR>", { desc = "Abrir LazyGit" })

-- ============================================================================
-- 3. PYTHON SETUP (Nossa config especial)
-- ============================================================================

-- Selecionar Venv
keymap('n', '<leader>vs', ':VenvSelect<CR>', { desc = "Selecionar VirtualEnv" })

-- ---
-- COMANDO ATUALIZADO: :SetupPython (Cria venv E instala IPython + requirements)
-- ---
vim.api.nvim_create_user_command('SetupPython', function()
  print("🐍 Configurando ambiente Python...")
  
  -- 1. Cria a pasta .venv se não existir
  vim.fn.system('python3 -m venv .venv')
  
  -- 2. Prepara o comando de instalação
  -- Nós SEMPRE vamos instalar o ipython por padrão.
  local install_cmd = "pip install ipython ruff"
  
  -- 3. Verifica se o requirements.txt existe
  if vim.fn.filereadable('requirements.txt') == 1 then
    print("... requirements.txt encontrado. Adicionando à instalação.")
    -- Se existir, adiciona ele ao MESMO comando do pip
    -- (O pip é inteligente e lida com isso)
    install_cmd = install_cmd .. " -r requirements.txt"
  else
    print("... nenhum requirements.txt encontrado. Instalando apenas IPython.")
  end
  
  -- 4. Constrói o comando final para o terminal
  local full_cmd = "source .venv/bin/activate && echo '📦 Instalando pacotes (IPython + requirements)...' && " .. install_cmd .. " && echo '✅ Ambiente pronto! Pressione Enter.'"
  
  -- 5. Executa tudo no terminal flutuante
  vim.cmd('botright 10sp | term ' .. full_cmd)
end, {})

-- Atalho que CHAMA o comando acima
keymap('n', '<leader>pi', ':SetupPython<CR>', { desc = "Setup Python Env" })


keymap("n", "<leader>pp", function()
  -- --- Tabela de Alias (Import -> Pip) ---
  local package_aliases = {
    -- Data Science & Engenharia
    sklearn = "scikit-learn",
    skimage = "scikit-image",
    cv2 = "opencv-python",
    PIL = "Pillow",
    fitz = "PyMuPDF",
    
    -- Web & APIs
    bs4 = "beautifulsoup4",
    jwt = "PyJWT",
    dotenv = "python-dotenv",
    yaml = "PyYAML",
    
    -- Bancos de Dados
    MySQLdb = "mysqlclient",
    psycopg = "psycopg2-binary", -- ou psycopg2
    
    -- Sistema & Automação
    Crypto = "pycryptodome",
    nacl = "PyNaCl",
    telebot = "pyTelegramBotAPI",
    vlc = "python-vlc",
    wx = "wxPython",
    xdg = "pyxdg",
    zmq = "pyzmq",
    gi = "PyGObject",
    gtk = "PyGObject",
    fpdf = "fpdf2", -- 'fpdf' está morto, 'fpdf2' é o moderno
    
    -- Office & Documentos
    docx = "python-docx",
    pptx = "python-pptx",
    
    -- Utilitários
    dateutil = "python-dateutil",
    memcache = "python-memcached",

    -- Windows Específico (caso use)
    win32api = "pywin32",
    win32con = "pywin32",
    win32gui = "pywin32",
  }
  -- --------------------------------------

  local package_name = vim.fn.expand("<cword>") -- Pega a palavra no cursor

  -- Verifica se o nome do import está na nossa tabela de alias
  if package_aliases[package_name] then
    -- Se estiver, usa o nome corrigido do pip
    package_name = package_aliases[package_name]
    print("Corrigido: Usando '" .. package_name .. "' para instalar.")
  end

  -- O resto do script continua igual, checando o venv
  if vim.fn.isdirectory('.venv') == 1 then
    print("📦 Instalando " .. package_name .. " no .venv...")
    vim.cmd("botright 10sp | term source .venv/bin/activate && pip install " .. package_name .. " && echo '✅ Pronto! Pressione Enter.'")
  else
    vim.api.nvim_err_writeln("🚨 Erro: Pasta '.venv' não encontrada. Rode :SetupPython (<leader>pi) primeiro.")
  end
end, { desc = "Pip Install Pacote (Inteligente)" })

-- ============================================================================
-- 5. EXTRAS: Rodar Código (ToggleTerm - O "Botão Play")
-- ============================================================================

-- 1. O "Botão Play" (Rodar o arquivo atual)
local function run_current_file()
  local Terminal = require("toggleterm.terminal").Terminal
  
  -- Checa se .venv existe para ativar
  local venv_cmd = ""
  if vim.fn.isdirectory('.venv') == 1 then
    venv_cmd = "source .venv/bin/activate && "
  end
  
  -- !!! A MUDANÇA ESTÁ AQUI !!!
  -- Rodamos o python E DEPOIS chamamos 'exec $SHELL'
  -- Isso mantém o terminal vivo depois que o script rodar.
  local cmd = venv_cmd .. "python " .. vim.fn.expand("%") .. "; exec $SHELL"
  
  -- Cria e abre o terminal rodando o comando
  local term = Terminal:new({
    cmd = cmd,
    direction = 'float',
    -- 'auto_close' agora é redundante, mas não faz mal
    auto_close = false, 

    on_exit = function(self, jobid, exit_code, name)
      if exit_code ~= 0 then
        vim.api.nvim_err_writeln("Processo falhou com código: " .. exit_code)
      end
    end,
  })
  term:toggle()
end
-- Atalho: Espaço + r + r (Run Script)
keymap("n", "<leader>rr", run_current_file, { desc = "Rodar Script Python Atual" })

-- 2. O "Console Interativo" (IPython - REPL)
local function open_ipython()
  -- !!! Garantindo que o 'require' está aqui dentro !!!
  local Terminal = require("toggleterm.terminal").Terminal

  -- Checa se .venv existe para ativar
  local venv_cmd = ""
  if vim.fn.isdirectory('.venv') == 1 then
    venv_cmd = "source .venv/bin/activate && "
  end
  
  -- !!! A MUDANÇA ESTÁ AQUI !!!
  -- Adicionamos o '; exec $SHELL' para forçar a janela
  -- a ficar aberta e podermos ver o erro.
  local cmd = venv_cmd .. "ipython; exec $SHELL"
  
  local term = Terminal:new({
    cmd = cmd,
    direction = 'float',
    hidden = true, -- Reutiliza o mesmo terminal
  })
  term:toggle()
end
-- Atalho: Espaço + r + t (Run Terminal/REPL)
keymap("n", "<leader>rt", open_ipython, { desc = "Abrir Console IPython (REPL)" })


--
-- 3. O "Botão Play" do PROJETO (Estilo PyCharm)
--
local function run_main_project()
  local Terminal = require("toggleterm.terminal").Terminal
  
  -- Prepara o comando do venv
  local venv_cmd = ""
  if vim.fn.isdirectory('.venv') == 1 then
    venv_cmd = "source .venv/bin/activate && "
  end
  
  -- Lógica de "Run Configuration":
  local main_file = nil
  if vim.fn.filereadable('main.py') == 1 then
    main_file = "main.py"
  elseif vim.fn.filereadable('app.py') == 1 then
    main_file = "app.py"
  end

  -- Se achou um arquivo principal, roda ele
  if main_file then
    print("Rodando arquivo principal do projeto: " .. main_file)
    local cmd = venv_cmd .. "python " .. main_file .. "; exec $SHELL"
    
    local term = Terminal:new({
      cmd = cmd,
      direction = 'float',
      auto_close = false,
    })
    term:toggle()
  else
    -- Se não achou, avisa o usuário
    vim.api.nvim_err_writeln("🚨 Erro: 'main.py' ou 'app.py' não encontrado.")
  end
end

-- Atalho: Espaço + r + m (Run Main)
keymap("n", "<leader>rm", run_main_project, { desc = "Rodar Projeto (main.py / app.py)" }) 


-- ============================================================================
-- 6. EXTRAS: Formatação de Código (LSP)
-- ============================================================================
-- Atalho: Espaço + c + f (Code Format)
-- Vai formatar Python, SQL, Lua, etc.
local function lsp_format()
  vim.lsp.buf.format({ async = true })
end

keymap("n", "<leader>cf", lsp_format, { desc = "Formatar Código (LSP)" })

-- ============================================================================
-- 7. EXTRAS: Comentários (Estilo PyCharm Ctrl+/)
-- ============================================================================
-- Atalho: Espaço + /
keymap({"n", "v"}, "<leader>/", ":CommentToggle<CR>", { desc = "Comentar/Descomentar" })

-- Em /lua/keymaps.lua (pode ser no final)

-- ============================================================================
-- 8. DEBUGGER (DAP)
-- ============================================================================

-- Desta forma, o 'require' só acontece QUANDO você aperta a tecla,
-- o que impede o crash na inicialização.

-- Iniciar Debug (F5 do VSCode)
keymap("n", "<leader>ds", function() require('dap').continue() end, { desc = "Debug Start (Continue)" })
-- Fechar Sessão
keymap("n", "<leader>de", function() require('dap').terminate() end, { desc = "Debug End (Terminate)" })
-- Toggle Breakpoint
keymap("n", "<leader>db", function() require('dap').toggle_breakpoint() end, { desc = "Debug Breakpoint" })

-- Navegação
keymap("n", "<leader>dn", function() require('dap').step_over() end, { desc = "Debug Step Over (Next)" })
keymap("n", "<leader>dj", function() require('dap').step_over() end, { desc = "Debug Step Over (Next)" }) -- Alias
keymap("n", "<leader>di", function() require('dap').step_into() end, { desc = "Debug Step Into" })
keymap("n", "<leader>do", function() require('dap').step_out() end, { desc = "Debug Step Out" })
keymap("n", "<leader>dk", function() require('dap').step_out() end, { desc = "Debug Step Out" }) -- Alias

-- UI
keymap("n", "<leader>du", function() require('dapui').toggle() end, { desc = "Debug Toggle UI" })
keymap("n", "<leader>dr", function() require('dap').repl.toggle() end, { desc = "Debug REPL" })
