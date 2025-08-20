local config = function()
	local nvimtree = require("nvim-tree")
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1

	-- Define diagnostic signs for nvim-tree
	vim.fn.sign_define("NvimTreeDiagnosticErrorIcon", { text = "", texthl = "DiagnosticError" })
	vim.fn.sign_define("NvimTreeDiagnosticWarnIcon", { text = "", texthl = "DiagnosticWarn" })
	vim.fn.sign_define("NvimTreeDiagnosticInfoIcon", { text = "", texthl = "DiagnosticInfo" })
	vim.fn.sign_define("NvimTreeDiagnosticHintIcon", { text = "", texthl = "DiagnosticHint" })

	nvimtree.setup({
		on_attach = function(bufnr)
			local api = require('nvim-tree.api')

			local function opts(desc)
				return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			-- Default mappings
			api.config.mappings.default_on_attach(bufnr)

			-- Custom mappings
			vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
		end,
		sort = {
			sorter = "case_sensitive",
		},
		view = {
			width = 30,
			relativenumber = false,
			number = false,
			signcolumn = "no",
		},
		renderer = {
			group_empty = true,
			highlight_git = true,
			highlight_opened_files = "name",
			root_folder_modifier = ":~",
			indent_markers = {
				enable = true,
				inline_arrows = true,
				icons = {
					corner = "└",
					edge = "│",
					item = "│",
					bottom = "─",
					none = " ",
				},
			},
			icons = {
				webdev_colors = true,
				git_placement = "before",
				modified_placement = "after",
				padding = " ",
				symlink_arrow = " ➛ ",
				show = {
					file = true,
					folder = true,
					folder_arrow = true,
					git = true,
					modified = true,
				},
				glyphs = {
					default = "",
					symlink = "",
					bookmark = "",
					modified = "●",
					folder = {
						arrow_closed = "",
						arrow_open = "",
						default = "",
						open = "",
						empty = "",
						empty_open = "",
						symlink = "",
						symlink_open = "",
					},
					git = {
						unstaged = "✗",
						staged = "✓",
						unmerged = "",
						renamed = "➜",
						untracked = "★",
						deleted = "",
						ignored = "◌",
					},
				},
			},
			special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
			symlink_destination = true,
		},
		hijack_directories = {
			enable = true,
			auto_open = true,
		},
		update_focused_file = {
			enable = true,
			update_root = false,
			ignore_list = {},
		},
		system_open = {
			cmd = "",
			args = {},
		},
		diagnostics = {
			enable = true,
			show_on_dirs = false,
			show_on_open_dirs = true,
			debounce_delay = 50,
			severity = {
				min = vim.diagnostic.severity.HINT,
				max = vim.diagnostic.severity.ERROR,
			},
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
		filters = {
			dotfiles = false,
			git_clean = false,
			no_buffer = false,
			custom = { ".DS_Store", "node_modules", ".cache" },
			exclude = {},
		},
		filesystem_watchers = {
			enable = true,
			debounce_delay = 50,
			ignore_dirs = {},
		},
		git = {
			enable = true,
			ignore = false,
			show_on_dirs = true,
			show_on_open_dirs = true,
			timeout = 400,
		},
		actions = {
			use_system_clipboard = true,
			change_dir = {
				enable = true,
				global = false,
				restrict_above_cwd = false,
			},
			expand_all = {
				max_folder_discovery = 300,
				exclude = {},
			},
			file_popup = {
				open_win_config = {
					col = 1,
					row = 1,
					relative = "cursor",
					border = "shadow",
					style = "minimal",
				},
			},
			open_file = {
				quit_on_open = false,
				resize_window = true,
				window_picker = {
					enable = true,
					picker = "default",
					chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
					exclude = {
						filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
						buftype = { "nofile", "terminal", "help" },
					},
				},
			},
			remove_file = {
				close_window = true,
			},
		},
		trash = {
			cmd = "gio trash",
			require_confirm = true,
		},
		live_filter = {
			prefix = "[FILTER]: ",
			always_show_folders = true,
		},
		tab = {
			sync = {
				open = false,
				close = false,
				ignore = {},
			},
		},
		notify = {
			threshold = vim.log.levels.INFO,
		},
		log = {
			enable = false,
			truncate = false,
			types = {
				all = false,
				config = false,
				copy_paste = false,
				dev = false,
				diagnostics = false,
				git = false,
				profile = false,
				watcher = false,
			},
		},
	})

	-- Enhanced keymaps with descriptions
	vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = " Toggle file explorer" })
	vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = " Toggle file explorer on current file" })
	vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = " Collapse file explorer" })
	vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = " Refresh file explorer" })
end

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = config,
}