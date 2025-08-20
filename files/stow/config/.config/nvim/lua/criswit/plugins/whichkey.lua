return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		plugins = {
			marks = true,
			registers = true,
			spelling = {
				enabled = true,
				suggestions = 20,
			},
			presets = {
				operators = true,
				motions = true,
				text_objects = true,
				windows = true,
				nav = true,
				z = true,
				g = true,
			},
		},
		-- Replace deprecated operators with defer
		defer = function(ctx)
			return ctx.mode == "V" or ctx.mode == "<C-V>"
		end,
		-- Replace deprecated triggers_nowait with delay
		delay = function(ctx)
			-- Instant show for certain keys
			if ctx.keys and (
				ctx.keys == "`" or
				ctx.keys == "'" or
				ctx.keys == "g`" or
				ctx.keys == "g'" or
				ctx.keys == '"' or
				ctx.keys == "<c-r>" or
				ctx.keys == "z="
			) then
				return 0
			end
			return ctx.plugin and 0 or 200
		end,
		-- Replace deprecated triggers_blacklist with triggers configuration
		triggers = {
			{ "<auto>", mode = "nixso" }, -- Exclude 'v' mode for j/k
		},
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
			ellipsis = "…",
			mappings = true,
			keys = {
				Up = " ",
				Down = " ",
				Left = " ",
				Right = " ",
				C = "󰘴 ",
				M = "󰘵 ",
				S = "󰘶 ",
				CR = "󰌑 ",
				Esc = "󱊷 ",
				ScrollWheelDown = "󱕐 ",
				ScrollWheelUp = "󱕑 ",
				NL = "󰌑 ",
				BS = "⌫",
				Space = "󱁐 ",
				Tab = "󰌒 ",
			},
		},
		win = {
			border = "rounded",
			position = "bottom",
			margin = { 1, 0, 1, 0 },
			padding = { 1, 2, 1, 2 },
			title = true,
			title_pos = "center",
			zindex = 1000,
		},
		layout = {
			height = { min = 4, max = 25 },
			width = { min = 20, max = 50 },
			spacing = 3,
			align = "left",
		},
		show_help = true,
		show_keys = true,
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)

		wk.add({
			-- Normal mode mappings
			{ mode = "n" },

			-- Leader key groups
			{ "<leader>", group = "Leader" },
			{ "<leader>a", group = " AI Assistant" },
			{ "<leader>b", group = " Buffers" },
			{ "<leader>c", group = " Code/Conflicts" },
			{ "<leader>d", group = " Debug/Diagnostics" },
			{ "<leader>f", group = " Find/Search" },
			{ "<leader>g", group = " Git" },
			{ "<leader>h", group = " Harpoon/Hunks" },
			{ "<leader>l", group = " LSP" },
			{ "<leader>n", group = " Notes" },
			{ "<leader>o", group = " Open" },
			{ "<leader>p", group = " Project" },
			{ "<leader>q", group = " Quit/Session" },
			{ "<leader>r", group = " Refactor" },
			{ "<leader>s", group = " Split/Select" },
			{ "<leader>t", group = " Terminal/Toggle" },
			{ "<leader>u", group = " UI/UX" },
			{ "<leader>w", group = " Windows" },
			{ "<leader>x", group = " Trouble/Diagnostics" },
			{ "<leader>z", group = " Fold" },

			-- Quick actions
			{ "<leader><leader>", desc = "Quick action menu" },
			{ "<leader>?", desc = " Cheatsheet" },
			{ "<leader>e", desc = " File Explorer" },
			{ "<leader>,", desc = " Settings" },
			{ "<leader>.", desc = " File browser" },
			{ "<leader>/", desc = " Comment line" },
			{ "<leader>;", desc = " Command history" },
			{ "<leader>:", desc = " Command palette" },

			-- Buffer operations
			{ "<leader>bb", desc = " Switch buffer" },
			{ "<leader>bd", desc = " Delete buffer" },
			{ "<leader>bD", desc = " Delete buffer (force)" },
			{ "<leader>bn", desc = " Next buffer" },
			{ "<leader>bp", desc = " Previous buffer" },
			{ "<leader>bs", desc = " Save buffer" },
			{ "<leader>bS", desc = " Save all buffers" },
			{ "<leader>bc", desc = " Close other buffers" },
			{ "<leader>bf", desc = " Format buffer" },
			{ "<leader>br", desc = " Rename buffer" },
			
			-- Bufferline specific operations (rice theme)
			{ "<leader>bo", desc = " Delete other buffers (bufferline)" },
			{ "<leader>bl", desc = " Delete buffers to the left" },
			{ "<leader>bP", desc = " Delete non-pinned buffers" },
			
			-- Smooth scrolling keybindings
			{ "<C-u>", desc = " Smooth scroll up (half page)" },
			{ "<C-d>", desc = " Smooth scroll down (half page)" },
			{ "<C-b>", desc = " Smooth scroll up (full page)" },
			{ "<C-f>", desc = " Smooth scroll down (full page)" },
			{ "<C-y>", desc = " Smooth scroll up (line)" },
			{ "<C-e>", desc = " Smooth scroll down (line)" },
			{ "zt", desc = " Smooth scroll to top" },
			{ "zz", desc = " Smooth scroll to center" },
			{ "zb", desc = " Smooth scroll to bottom" },

			-- Code actions
			{ "<leader>ca", desc = " Code action" },
			{ "<leader>cd", desc = " Type definition" },
			{ "<leader>cf", desc = " Format code" },
			{ "<leader>ci", desc = " Organize imports" },
			{ "<leader>cR", desc = " Rename symbol" },
			{ "<leader>cr", desc = " Refactor" },
			{ "<leader>cs", desc = " Symbol outline" },

			-- Conflict resolution
			{ "<leader>co", desc = " Choose ours" },
			{ "<leader>ct", desc = " Choose theirs" },
			{ "<leader>cb", desc = " Choose both" },
			{ "<leader>c0", desc = " Choose none" },
			{ "<leader>cO", desc = " Choose ours (file)" },
			{ "<leader>cT", desc = " Choose theirs (file)" },
			{ "<leader>cB", desc = " Choose base (file)" },
			{ "<leader>cA", desc = " Choose all (file)" },
			{ "<leader>cl", desc = " List conflicts" },
			{ "<leader>cn", desc = " Next conflict" },
			{ "<leader>cp", desc = " Previous conflict" },

			-- Diagnostics
			{ "<leader>dd", desc = " Show diagnostics" },
			{ "<leader>dD", desc = " Workspace diagnostics" },
			{ "<leader>dn", desc = " Next diagnostic" },
			{ "<leader>dp", desc = " Previous diagnostic" },
			{ "<leader>df", desc = " Fix diagnostic" },
			{ "<leader>dl", desc = " List diagnostics" },
			{ "<leader>dq", desc = " Quickfix diagnostics" },

			-- Find/Search
			{ "<leader>fb", desc = " Buffers" },
			{ "<leader>fc", desc = " Current buffer" },
			{ "<leader>fC", desc = " Commands" },
			{ "<leader>ff", desc = " Files" },
			{ "<leader>fF", desc = " Files (all)" },
			{ "<leader>fg", desc = " Grep" },
			{ "<leader>fG", desc = " Grep (word)" },
			{ "<leader>fh", desc = " Help" },
			{ "<leader>fH", desc = " Highlights" },
			{ "<leader>fk", desc = " Keymaps" },
			{ "<leader>fl", desc = " Location list" },
			{ "<leader>fm", desc = " Marks" },
			{ "<leader>fM", desc = " Man pages" },
			{ "<leader>fo", desc = " Old files" },
			{ "<leader>fp", desc = " Projects" },
			{ "<leader>fq", desc = " Quickfix" },
			{ "<leader>fr", desc = " Recent files" },
			{ "<leader>fR", desc = " Registers" },
			{ "<leader>fs", desc = " Symbols" },
			{ "<leader>fS", desc = " Snippets" },
			{ "<leader>ft", desc = " Tags" },
			{ "<leader>fT", desc = " Todo comments" },
			{ "<leader>fw", desc = " Word (current)" },
			{ "<leader>fW", desc = " WORD (current)" },

			-- Git operations
			{ "<leader>gg", "<cmd>Git<cr>", desc = " Git status" },
			{ "<leader>gG", "<cmd>Neogit<cr>", desc = " Neogit panel" },
			{ "<leader>ga", "<cmd>Git add %<cr>", desc = " Add current file" },
			{ "<leader>gA", "<cmd>Git add .<cr>", desc = " Add all" },
			{ "<leader>gb", "<cmd>Git blame<cr>", desc = " Blame" },
			{ "<leader>gB", "<cmd>GBrowse<cr>", desc = " Browse on web" },
			{ "<leader>gc", "<cmd>Git commit<cr>", desc = " Commit" },
			{ "<leader>gC", "<cmd>Git commit --amend<cr>", desc = " Commit (amend)" },
			{ "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = " Diff split" },
			{ "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = " Diff view" },
			{ "<leader>ge", "<cmd>Gedit<cr>", desc = " Edit" },
			{ "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = " File history" },
			{ "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = " Branch history" },
			{ "<leader>gh", group = " GitHub" },
			{ "<leader>ghi", desc = " Issues" },
			{ "<leader>ghp", desc = " Pull requests" },
			{ "<leader>gha", desc = " Actions" },
			{ "<leader>gl", "<cmd>Git log --oneline<cr>", desc = " Log" },
			{ "<leader>gL", "<cmd>Gclog<cr>", desc = " Log (quickfix)" },
			{ "<leader>gm", "<cmd>Git merge<cr>", desc = " Merge" },
			{ "<leader>go", "<cmd>Git checkout<cr>", desc = " Checkout" },
			{ "<leader>gp", "<cmd>Git push<cr>", desc = " Push" },
			{ "<leader>gP", "<cmd>Git pull<cr>", desc = " Pull" },
			{ "<leader>gr", "<cmd>Gread<cr>", desc = " Read (reset file)" },
			{ "<leader>gR", "<cmd>Git rebase<cr>", desc = " Rebase" },
			{ "<leader>gs", "<cmd>Git<cr>", desc = " Status" },
			{ "<leader>gS", "<cmd>Git stash<cr>", desc = " Stash" },
			{ "<leader>gt", "<cmd>Git tag<cr>", desc = " Tags" },
			{ "<leader>gu", "<cmd>Git reset %<cr>", desc = " Unstage file" },
			{ "<leader>gU", "<cmd>Git reset<cr>", desc = " Unstage all" },
			{ "<leader>gw", "<cmd>Gwrite<cr>", desc = " Write (stage)" },
			{ "<leader>gx", "<cmd>DiffviewClose<cr>", desc = " Close Diffview" },
			{ "<leader>gy", desc = " Copy permalink" },

			-- Hunk operations
			{ "<leader>hs", desc = " Stage hunk" },
			{ "<leader>hr", desc = " Reset hunk" },
			{ "<leader>hS", desc = " Stage buffer" },
			{ "<leader>hR", desc = " Reset buffer" },
			{ "<leader>hu", desc = " Undo stage" },
			{ "<leader>hp", desc = " Preview hunk" },
			{ "<leader>hb", desc = " Blame line" },
			{ "<leader>hd", desc = " Diff this" },
			{ "<leader>hD", desc = " Diff this ~" },

			-- LSP operations
			{ "<leader>la", desc = " Code action" },
			{ "<leader>ld", desc = " Definition" },
			{ "<leader>lD", desc = " Declaration" },
			{ "<leader>lf", desc = " Format" },
			{ "<leader>lh", desc = " Hover" },
			{ "<leader>li", desc = " Implementation" },
			{ "<leader>lI", desc = " Info" },
			{ "<leader>ll", desc = " Line diagnostics" },
			{ "<leader>lL", desc = " Log" },
			{ "<leader>ln", desc = " Rename" },
			{ "<leader>lo", desc = " Outline" },
			{ "<leader>lq", desc = " Quickfix" },
			{ "<leader>lr", desc = " References" },
			{ "<leader>lR", desc = " Restart LSP" },
			{ "<leader>ls", desc = " Signature help" },
			{ "<leader>lS", desc = " Workspace symbols" },
			{ "<leader>lt", desc = " Type definition" },
			{ "<leader>lw", group = " Workspace" },
			{ "<leader>lwa", desc = " Add folder" },
			{ "<leader>lwr", desc = " Remove folder" },
			{ "<leader>lwl", desc = " List folders" },

			-- Open/Launch
			{ "<leader>ot", desc = " Terminal" },
			{ "<leader>of", desc = " File manager" },
			{ "<leader>og", desc = " Lazygit" },
			{ "<leader>od", desc = " Database UI" },
			{ "<leader>om", desc = " Markdown preview" },
			{ "<leader>oh", desc = " HTTP client" },

			-- Project
			{ "<leader>pp", desc = " Find project" },
			{ "<leader>pf", desc = " Find file" },
			{ "<leader>pr", desc = " Recent projects" },
			{ "<leader>ps", desc = " Search in project" },
			{ "<leader>pt", desc = " Todo list" },

			-- Quit/Session
			{ "<leader>qq", "<cmd>qa<cr>", desc = " Quit all" },
			{ "<leader>qQ", "<cmd>qa!<cr>", desc = " Quit all (force)" },
			{ "<leader>qs", desc = " Save session" },
			{ "<leader>ql", desc = " Load session" },
			{ "<leader>qd", desc = " Delete session" },

			-- Split/Window
			{ "<leader>sh", "<cmd>split<cr>", desc = " Split horizontal" },
			{ "<leader>sv", "<cmd>vsplit<cr>", desc = " Split vertical" },
			{ "<leader>sc", "<cmd>close<cr>", desc = " Close split" },
			{ "<leader>so", "<cmd>only<cr>", desc = " Close others" },
			{ "<leader>s=", desc = " Equal splits" },
			{ "<leader>s-", desc = " Decrease height" },
			{ "<leader>s+", desc = " Increase height" },
			{ "<leader>s<", desc = " Decrease width" },
			{ "<leader>s>", desc = " Increase width" },

			-- Terminal
			{ "<leader>tt", desc = " Toggle terminal" },
			{ "<leader>tF", desc = " Float terminal" },
			{ "<leader>tH", desc = " Horizontal terminal" },
			{ "<leader>tv", desc = " Vertical terminal" },
			{ "<leader>tg", desc = " Lazygit" },
			{ "<leader>tN", desc = " Node REPL" },
			{ "<leader>tp", desc = " Python REPL" },

			-- Toggle UI elements
			{ "<leader>tb", desc = " Git blame" },
			{ "<leader>tc", desc = " Conceal" },
			{ "<leader>tC", desc = " Color column" },
			{ "<leader>td", desc = " Deleted (git)" },
			{ "<leader>tD", desc = " Diagnostics" },
			{ "<leader>tf", desc = " Format on save" },
			{ "<leader>th", desc = " Highlight search" },
			{ "<leader>ti", desc = " Indent guides" },
			{ "<leader>tl", desc = " Line numbers" },
			{ "<leader>tL", desc = " Relative line numbers" },
			{ "<leader>tn", desc = " Line diagnostics" },
			{ "<leader>tr", desc = " Relative numbers" },
			{ "<leader>ts", desc = " Spell check" },
			{ "<leader>tS", desc = " Status line" },
			{ "<leader>tw", desc = " Word wrap" },
			{ "<leader>tW", desc = " Whitespace" },
			{ "<leader>tz", desc = " Zen mode" },

			-- UI/UX
			{ "<leader>uc", desc = " Colorscheme" },
			{ "<leader>uC", desc = " Contrast" },
			{ "<leader>ub", desc = " Background" },
			{ "<leader>un", desc = " Notifications" },
			{ "<leader>uN", desc = " Notification history" },
			{ "<leader>ui", desc = " Indent guides" },
			{ "<leader>ul", desc = " List chars" },

			-- Window management
			{ "<leader>ww", desc = " Switch window" },
			{ "<leader>wd", "<cmd>close<cr>", desc = " Delete window" },
			{ "<leader>wh", "<cmd>wincmd h<cr>", desc = " Go left" },
			{ "<leader>wj", "<cmd>wincmd j<cr>", desc = " Go down" },
			{ "<leader>wk", "<cmd>wincmd k<cr>", desc = " Go up" },
			{ "<leader>wl", "<cmd>wincmd l<cr>", desc = " Go right" },
			{ "<leader>ws", "<cmd>split<cr>", desc = " Split horizontal" },
			{ "<leader>wv", "<cmd>vsplit<cr>", desc = " Split vertical" },
			{ "<leader>w=", "<cmd>wincmd =<cr>", desc = " Equal size" },
			{ "<leader>w_", "<cmd>wincmd _<cr>", desc = " Max height" },
			{ "<leader>w|", "<cmd>wincmd |<cr>", desc = " Max width" },
			{ "<leader>wo", "<cmd>only<cr>", desc = " Only window" },
			{ "<leader>wx", "<cmd>wincmd x<cr>", desc = " Swap windows" },

			-- Navigation mappings (no leader)
			{ "]", group = "Next" },
			{ "]b", desc = " Next buffer" },
			{ "]c", desc = " Next change" },
			{ "]d", desc = " Next diagnostic" },
			{ "]e", desc = " Next error" },
			{ "]h", desc = " Next hunk" },
			{ "]q", desc = " Next quickfix" },
			{ "]t", desc = " Next tab" },
			{ "]x", desc = " Next conflict" },

			{ "[", group = "Previous" },
			{ "[b", desc = " Previous buffer" },
			{ "[c", desc = " Previous change" },
			{ "[d", desc = " Previous diagnostic" },
			{ "[e", desc = " Previous error" },
			{ "[h", desc = " Previous hunk" },
			{ "[q", desc = " Previous quickfix" },
			{ "[t", desc = " Previous tab" },
			{ "[x", desc = " Previous conflict" },
			
			-- Enhanced buffer navigation (rice theme)
			{ "<S-h>", desc = " Previous buffer (bufferline)" },
			{ "<S-l>", desc = " Next buffer (bufferline)" },

			-- g prefix mappings
			{ "g", group = "Go/Git" },
			{ "gd", desc = "Go to definition" },
			{ "gD", desc = "Go to declaration" },
			{ "gi", desc = "Go to implementation" },
			{ "gr", desc = "Go to references" },
			{ "gt", desc = "Go to type definition" },
			{ "gf", desc = "Go to file" },
			{ "gg", desc = "Go to top" },
			{ "G", desc = "Go to bottom" },
			{ "gh", desc = "Go to hover" },
			{ "gx", desc = "Open URL" },

			-- Visual mode mappings
			{ mode = "v" },
			{ "<leader>/", desc = " Toggle comment" },
			{ "<leader>c", group = " Code" },
			{ "<leader>ca", desc = " Code action" },
			{ "<leader>cf", desc = " Format selection" },
			{ "<leader>cr", desc = " Refactor" },
			{ "<leader>g", group = " Git" },
			{ "<leader>gy", desc = " Copy permalink" },
			{ "<leader>h", group = " Git hunks" },
			{ "<leader>hs", desc = " Stage hunk" },
			{ "<leader>hr", desc = " Reset hunk" },
			{ "<leader>r", group = " Refactor" },
			{ "<leader>re", desc = "Extract" },
			{ "<leader>rf", desc = "Function" },
			{ "<leader>rv", desc = "Variable" },
			{ "<leader>s", group = " Search/Sort" },
			{ "<leader>sr", desc = "Replace" },
			{ "<leader>ss", desc = "Sort" },

			-- Text objects (operator pending mode)
			{ mode = "o" },
			{ "ih", desc = "Inner hunk" },
			{ "ah", desc = "Around hunk" },
			{ "ii", desc = "Inner indent" },
			{ "ai", desc = "Around indent" },
			{ "if", desc = "Inner function" },
			{ "af", desc = "Around function" },
			{ "ic", desc = "Inner class" },
			{ "ac", desc = "Around class" },
		})

		-- Register additional mappings for specific modes
		wk.add({
			{
				mode = { "n", "v" },
				{ "<C-s>", "<cmd>w<cr>", desc = "Save file" },
				{ "<C-q>", "<cmd>q<cr>", desc = "Quit" },
				{ "<C-a>", "ggVG", desc = "Select all" },
			},
		})

		-- Terminal mode mappings
		wk.add({
			{
				mode = "t",
				{ "<Esc>", [[<C-\><C-n>]], desc = "Normal mode" },
				{ "<C-h>", [[<C-\><C-n><C-w>h]], desc = "Go left" },
				{ "<C-j>", [[<C-\><C-n><C-w>j]], desc = "Go down" },
				{ "<C-k>", [[<C-\><C-n><C-w>k]], desc = "Go up" },
				{ "<C-l>", [[<C-\><C-n><C-w>l]], desc = "Go right" },
			},
		})
	end,
}