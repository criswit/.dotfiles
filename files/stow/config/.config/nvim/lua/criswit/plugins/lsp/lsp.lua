local lsp_attach = function()
	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "LSP actions",
		callback = function(event)
			local opts = {
				buffer = event.buf,
			}
			vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
			vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
			vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
			vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
			vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
			vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
			vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)

			vim.keymap.set("n", "<leader>ff", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
			vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
			vim.keymap.set("n", "<leader>ra", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
		end,
	})
end

local config = function()
	local lspconfig = require("lspconfig")
	local cmp_lsp = require("cmp_nvim_lsp")

	local capabilities = cmp_lsp.default_capabilities()

	-- Setup each LSP server directly
	local servers = { "ts_ls", "gopls", "bashls", "jsonls", "lua_ls", "jdtls" }
	for _, server in ipairs(servers) do
		lspconfig[server].setup({
			capabilities = capabilities,
		})
	end

	lsp_attach()
end

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = config,
}
