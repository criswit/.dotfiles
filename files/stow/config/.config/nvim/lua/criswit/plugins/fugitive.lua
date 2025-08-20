return {
	{
		"tpope/vim-fugitive",
		cmd = {
			"G",
			"Git",
			"Gdiffsplit",
			"Gread",
			"Gwrite",
			"Ggrep",
			"GMove",
			"GDelete",
			"GBrowse",
			"GRemove",
			"GRename",
			"Glgrep",
			"Gedit",
			"Gclog",
			"Gcd",
			"Glcd",
			"Gtabedit",
			"Gpedit",
			"Gsplit",
			"Gvsplit",
			"GcLog",
		},
		ft = { "fugitive" },
		config = function()
			vim.cmd([[
				autocmd BufWinEnter * if &ft == 'fugitive' | nnoremap <buffer> q :q<CR> | endif
				autocmd BufWinEnter * if &ft == 'git' | nnoremap <buffer> q :q<CR> | endif
			]])

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "fugitive",
				callback = function()
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
				end,
			})
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = {
				interval = 1000,
				follow_files = true,
			},
			auto_attach = true,
			attach_to_untracked = false,
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
				ignore_whitespace = false,
				virt_text_priority = 100,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil,
			max_file_length = 40000,
			preview_config = {
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end, { desc = "Next Hunk" })

				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end, { desc = "Prev Hunk" })

				map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Stage Hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Reset Hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "Blame Line" })
				map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
				map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "Diff This ~" })
				map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle Deleted" })

				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
			end,
		},
	},

	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
			"DiffviewFileHistory",
		},
		config = function()
			local actions = require("diffview.actions")
			require("diffview").setup({
				diff_binaries = false,
				enhanced_diff_hl = false,
				git_cmd = { "git" },
				hg_cmd = { "hg" },
				use_icons = true,
				show_help_hints = true,
				watch_index = true,
				icons = {
					folder_closed = "",
					folder_open = "",
				},
				signs = {
					fold_closed = "",
					fold_open = "",
					done = "✓",
				},
				view = {
					default = {
						layout = "diff2_horizontal",
						disable_diagnostics = false,
						winbar_info = false,
					},
					merge_tool = {
						layout = "diff3_horizontal",
						disable_diagnostics = true,
						winbar_info = true,
					},
					file_history = {
						layout = "diff2_horizontal",
						disable_diagnostics = false,
						winbar_info = false,
					},
				},
				file_panel = {
					listing_style = "tree",
					tree_options = {
						flatten_dirs = true,
						folder_statuses = "only_folded",
					},
					win_config = {
						position = "left",
						width = 35,
						win_opts = {},
					},
				},
				file_history_panel = {
					log_options = {
						git = {
							single_file = {
								diff_merges = "combined",
							},
							multi_file = {
								diff_merges = "first-parent",
							},
						},
						hg = {
							single_file = {},
							multi_file = {},
						},
					},
					win_config = {
						position = "bottom",
						height = 16,
						win_opts = {},
					},
				},
				commit_log_panel = {
					win_config = {
						win_opts = {},
					},
				},
				default_args = {
					DiffviewOpen = {},
					DiffviewFileHistory = {},
				},
				hooks = {},
				keymaps = {
					disable_defaults = false,
					view = {
						{ "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
						{
							"n",
							"<s-tab>",
							actions.select_prev_entry,
							{ desc = "Open the diff for the previous file" },
						},
						{ "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
						{ "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
						{ "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
						{ "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
						{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel." } },
						{ "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle through available layouts." } },
						{ "n", "[x", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
						{ "n", "]x", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
						{ "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose the OURS version of a conflict" } },
						{ "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
						{ "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose the BASE version of a conflict" } },
						{ "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose all the versions of a conflict" } },
						{ "n", "dx", actions.conflict_choose("none"), { desc = "Delete the conflict region" } },
						{ "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose the OURS version of a conflict for the whole file" } },
						{ "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
						{ "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose the BASE version of a conflict for the whole file" } },
						{ "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "Choose all the versions of a conflict for the whole file" } },
						{ "n", "dX", actions.conflict_choose_all("none"), { desc = "Delete the conflict region for the whole file" } },
					},
					diff1 = {
						{ "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
					},
					diff2 = {
						{ "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
					},
					diff3 = {
						{ "n", "2do", actions.diffget("ours"), { desc = "Obtain the diff hunk from the OURS version of the file" } },
						{ "n", "3do", actions.diffget("theirs"), { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
					},
					diff4 = {
						{ "n", "1do", actions.diffget("base"), { desc = "Obtain the diff hunk from the BASE version of the file" } },
						{ "n", "2do", actions.diffget("ours"), { desc = "Obtain the diff hunk from the OURS version of the file" } },
						{ "n", "3do", actions.diffget("theirs"), { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
					},
					file_panel = {
						{ "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
						{ "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
						{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
						{ "n", "<up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
						{ "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "l", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
						{ "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
						{ "n", "S", actions.stage_all, { desc = "Stage all entries" } },
						{ "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
						{ "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },
						{ "n", "L", actions.open_commit_log, { desc = "Open the commit log panel" } },
						{ "n", "zo", actions.open_fold, { desc = "Expand fold" } },
						{ "n", "h", actions.close_fold, { desc = "Collapse fold" } },
						{ "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
						{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
						{ "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
						{ "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
						{ "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
						{ "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
						{ "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
						{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
						{ "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
						{ "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
						{ "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
						{ "n", "i", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
						{ "n", "f", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirectories in tree listing style" } },
						{ "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list" } },
						{ "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
						{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
						{ "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
						{ "n", "[x", actions.prev_conflict, { desc = "Go to the previous conflict" } },
						{ "n", "]x", actions.next_conflict, { desc = "Go to the next conflict" } },
						{ "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
						{ "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose the OURS version of a conflict for the whole file" } },
						{ "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
						{ "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose the BASE version of a conflict for the whole file" } },
						{ "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "Choose all the versions of a conflict for the whole file" } },
						{ "n", "dX", actions.conflict_choose_all("none"), { desc = "Delete the conflict region for the whole file" } },
					},
					file_history_panel = {
						{ "n", "g!", actions.options, { desc = "Open the option panel" } },
						{ "n", "<C-A-d>", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
						{ "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
						{ "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
						{ "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
						{ "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
						{ "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
						{ "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
						{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
						{ "n", "<up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
						{ "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "l", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
						{ "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
						{ "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
						{ "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
						{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
						{ "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
						{ "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
						{ "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
						{ "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
						{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
						{ "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
						{ "n", "g?", actions.help("file_history_panel"), { desc = "Open the help panel" } },
					},
					option_panel = {
						{ "n", "<tab>", actions.select_entry, { desc = "Change the current option" } },
						{ "n", "q", actions.close, { desc = "Close the panel" } },
						{ "n", "g?", actions.help("option_panel"), { desc = "Open the help panel" } },
					},
					help_panel = {
						{ "n", "q", actions.close, { desc = "Close help menu" } },
						{ "n", "<esc>", actions.close, { desc = "Close help menu" } },
					},
				},
			})
		end,
	},

	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		cmd = "Neogit",
		config = function()
			require("neogit").setup({
				disable_signs = false,
				disable_hint = false,
				disable_context_highlighting = false,
				disable_commit_confirmation = false,
				auto_refresh = true,
				disable_builtin_notifications = false,
				use_magit_keybindings = false,
				commit_popup = {
					kind = "split",
				},
				kind = "tab",
				signs = {
					section = { ">", "v" },
					item = { ">", "v" },
					hunk = { "", "" },
				},
				integrations = {
					telescope = true,
					diffview = true,
				},
				sections = {
					untracked = {
						folded = false,
					},
					unstaged = {
						folded = false,
					},
					staged = {
						folded = false,
					},
					stashes = {
						folded = true,
					},
					unpulled = {
						folded = true,
					},
					unmerged = {
						folded = false,
					},
					recent = {
						folded = true,
					},
				},
			})
		end,
	},

	{
		"akinsho/git-conflict.nvim",
		event = "VeryLazy",
		config = function()
			require("git-conflict").setup({
				default_mappings = false,
				default_commands = true,
				disable_diagnostics = false,
				list_opener = "copen",
				highlights = {
					incoming = "DiffAdd",
					current = "DiffText",
				},
			})

			vim.keymap.set("n", "<leader>co", "<Plug>(git-conflict-ours)", { desc = "Choose ours" })
			vim.keymap.set("n", "<leader>ct", "<Plug>(git-conflict-theirs)", { desc = "Choose theirs" })
			vim.keymap.set("n", "<leader>cb", "<Plug>(git-conflict-both)", { desc = "Choose both" })
			vim.keymap.set("n", "<leader>c0", "<Plug>(git-conflict-none)", { desc = "Choose none" })
			vim.keymap.set("n", "]x", "<Plug>(git-conflict-next-conflict)", { desc = "Next conflict" })
			vim.keymap.set("n", "[x", "<Plug>(git-conflict-prev-conflict)", { desc = "Previous conflict" })
		end,
	},

	{
		"ruifm/gitlinker.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("gitlinker").setup({
				opts = {
					remote = nil,
					add_current_line_on_normal_mode = true,
					action_callback = require("gitlinker.actions").copy_to_clipboard,
					print_url = true,
				},
				callbacks = {
					["github.com"] = require("gitlinker.hosts").get_github_type_url,
					["gitlab.com"] = require("gitlinker.hosts").get_gitlab_type_url,
					["bitbucket.org"] = require("gitlinker.hosts").get_bitbucket_type_url,
				},
				mappings = nil,
			})
		end,
	},
}