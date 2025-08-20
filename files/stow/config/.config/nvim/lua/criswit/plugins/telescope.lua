local config = function()
	local telescope = require("telescope")
	local actions = require("telescope.actions")
	local trouble = require("trouble")
	local trouble_telescope = require("trouble.sources.telescope")

	telescope.setup({
		defaults = {
			path_display = { "smart" },
			prompt_prefix = "   ",
			selection_caret = " ",
			entry_prefix = "  ",
			initial_mode = "insert",
			selection_strategy = "reset",
			sorting_strategy = "ascending",
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					preview_width = 0.55,
					results_width = 0.8,
				},
				vertical = {
					mirror = false,
				},
				width = 0.87,
				height = 0.80,
				preview_cutoff = 120,
			},
			-- Borderless theme configuration
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			color_devicons = true,
			set_env = { ["COLORTERM"] = "truecolor" },
			file_previewer = require("telescope.previewers").vim_buffer_cat.new,
			grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
			qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
			-- Developer configurations: disable the binary file detection
			buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
			mappings = {
				i = {
					["<C-k>"] = actions.move_selection_previous,
					["<C-j>"] = actions.move_selection_next,
					["<C-h>"] = actions.which_key, -- keys from pressing <C-h>
					["<C-x>"] = actions.select_horizontal,
					["<C-v>"] = actions.select_vertical,
					["<C-t>"] = actions.select_tab,
					["<C-u>"] = actions.preview_scrolling_up,
					["<C-d>"] = actions.preview_scrolling_down,
					["<PageUp>"] = actions.results_scrolling_up,
					["<PageDown>"] = actions.results_scrolling_down,
					["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
					["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
					["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
					["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					["<C-l>"] = actions.complete_tag,
					["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
					["<C-w>"] = { "<c-s-w>", type = "command" },
				},
				n = {
					["<esc>"] = actions.close,
					["<CR>"] = actions.select_default,
					["<C-x>"] = actions.select_horizontal,
					["<C-v>"] = actions.select_vertical,
					["<C-t>"] = actions.select_tab,
					["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
					["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
					["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
					["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					["j"] = actions.move_selection_next,
					["k"] = actions.move_selection_previous,
					["H"] = actions.move_to_top,
					["M"] = actions.move_to_middle,
					["L"] = actions.move_to_bottom,
					["<Down>"] = actions.move_selection_next,
					["<Up>"] = actions.move_selection_previous,
					["gg"] = actions.move_to_top,
					["G"] = actions.move_to_bottom,
					["<C-u>"] = actions.preview_scrolling_up,
					["<C-d>"] = actions.preview_scrolling_down,
					["<PageUp>"] = actions.results_scrolling_up,
					["<PageDown>"] = actions.results_scrolling_down,
					["?"] = actions.which_key,
				},
			},
		},
		pickers = {
			-- Default configuration for builtin pickers
			find_files = {
				find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
			},
			live_grep = {
				additional_args = function(opts)
					return {"--hidden"}
				end
			},
		},
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			},
		},
	})

	telescope.load_extension("fzf")

	-- Enhanced keymaps
	vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = " Find files" })
	vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = " Recent files" })
	vim.keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = " Search in files" })
	vim.keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = " Find word under cursor" })
	vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = " Find buffers" })
	vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = " Help tags" })
	vim.keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = " Keymaps" })
	vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = " Find todos" })
	vim.keymap.set("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = " Find word under cursor" })
	vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = " Git commits" })
	vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = " Git status" })
end

return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = config,
}
