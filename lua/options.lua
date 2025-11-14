local opt = vim.opt

-- Visual
opt.number = true          -- Mostra número da linha
opt.relativenumber = true  -- Números relativos (bom para pular linhas)
opt.termguicolors = true   -- Cores reais
opt.cursorline = true      -- Destaca a linha atual

-- Comportamento
opt.clipboard = "unnamedplus" -- Integra com Ctrl+C / Ctrl+V do sistema
opt.ignorecase = true      -- Busca ignora maiúsculas/minúsculas
opt.smartcase = true       -- ...a menos que você digite uma maiúscula
opt.scrolloff = 8          -- Mantém 8 linhas de margem ao rolar
opt.tabstop = 4            -- Tabs de 4 espaços (padrão Python)
opt.shiftwidth = 4
opt.expandtab = true       -- Transforma tab em espaços

-- Desativa netrw (padrão) para usar plugins de árvore se quiser
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
