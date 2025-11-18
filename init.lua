local vim = vim

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 4
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"

vim.keymap.set('n', '<leader>o', ':update | source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')

-- window movement
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')

vim.keymap.set('n', '<leader>t', ':sp<CR><C-w><C-j>:ter<CR>i')
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]])

vim.keymap.set('i', '<C-P>', '<Esc>Ypgi')

vim.pack.add({
	{ src = "https://github.com/vague-theme/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/echasnovski/mini.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/folke/zen-mode.nvim" },
})


vim.cmd("colorscheme vague")


vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
vim.keymap.set('n', '<leader>z', ':ZenMode<CR>')
 

-- MINI
require "mini.pick".setup()
require "mini.ai".setup()
require "mini.git".setup()
require "mini.files".setup()
require "mini.completion".setup()
require "mini.snippets".setup()
require "mini.icons".setup()
local mc = require "mini.clue"
mc.setup({
	triggers = {
		-- Leader triggers
		{ mode = 'n', keys = '<Leader>' },
		{ mode = 'x', keys = '<Leader>' },

		-- Built-in completion
		{ mode = 'i', keys = '<C-x>' },

		-- `g` key
		{ mode = 'n', keys = 'g' },
		{ mode = 'x', keys = 'g' },

		-- Marks
		{ mode = 'n', keys = "'" },
		{ mode = 'n', keys = '`' },
		{ mode = 'x', keys = "'" },
		{ mode = 'x', keys = '`' },

		-- Registers
		{ mode = 'n', keys = '"' },
		{ mode = 'x', keys = '"' },
		{ mode = 'i', keys = '<C-r>' },
		{ mode = 'c', keys = '<C-r>' },

		-- Window commands
		{ mode = 'n', keys = '<C-w>' },

		-- `z` key
		{ mode = 'n', keys = 'z' },
		{ mode = 'x', keys = 'z' },
	},

	clues = {
		mc.gen_clues.builtin_completion(),
		mc.gen_clues.g(),
		mc.gen_clues.marks(),
		mc.gen_clues.registers(),
		mc.gen_clues.windows(),
		mc.gen_clues.z(),
	},
})
require "mini.sessions".setup({
	autowrite = true,
})
local mp = require('mini.pick')
local ms = require('mini.sessions')
local mf = require('mini.files')

vim.keymap.set('n', '<leader>e', ':lua MiniFiles.open()<CR>')

-- SESSIONS

vim.keymap.set("n", "<leader>ss", function()
	vim.ui.input({ prompt = "Session name: " }, function(input)
		if input and input ~= "" then
			ms.write(input)
		end
	end)
end, { desc = "Save session" })
vim.keymap.set('n', '<leader>sl', function()
	ms.select('read')
end, { desc = 'Load session' })

vim.keymap.set('n', '<leader>sd', function()
	ms.select('delete')
end, { desc = 'Delete session' })



-- LSP

vim.lsp.enable({ "lua_ls", "tinymist", "pyright" })

local diagnostics_enabled = true
function ToggleDiagnostics()
	if diagnostics_enabled then
		vim.diagnostic.config({
			signs = false,
			virtual_text = false,
		})
		diagnostics_enabled = false
		print("Diagnostics Disabled")
	else
		vim.diagnostic.config({
			signs = true,
			virtual_text = true,
		})
		diagnostics_enabled = true
		print("Diagnostics Enabled")
	end
end

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>ld', ToggleDiagnostics)
-- END LSP


-- CMD
function FindTermBuffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == "terminal" then
			return buf
		end
	end
	return nil
end

local cmd = "echo ':SetCmd'"
local pid = nil
function RunCmd()
	local buf = FindTermBuffer()
	if not buf then
		print("No terminal buffer found.")
		return
	end

	vim.fn.chansend(vim.b[buf].terminal_job_id, cmd .. " & echo $!\n")

	vim.defer_fn(function()
		-- Get all lines from the terminal
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		for i = #lines, 1, -1 do
			pid = tonumber(lines[i])
			if pid then break end
		end
		if pid then
			print("PID:", pid)
		else
			print("Could not detect PID. Check terminal output.")
		end
	end, 100)
end

function KillCmd()
	if not pid then
		print("No saved PID.")
		return
	end

	os.execute("kill " .. pid)

	print("Killed python process with PID " .. pid)
	pid = nil
end

vim.api.nvim_create_user_command("SetCmd", function(opts)
	cmd = opts.args
end, { nargs = "+" })

vim.api.nvim_create_user_command("RunCmd", RunCmd, {})
vim.api.nvim_create_user_command("KillCmd", KillCmd, {})
vim.keymap.set('n', '<leader>r', RunCmd)
vim.keymap.set('n', '<leader>k', KillCmd)
-- END CMD
