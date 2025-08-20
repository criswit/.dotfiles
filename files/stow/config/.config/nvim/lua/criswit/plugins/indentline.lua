return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- Minimal character for indent guides
    indent = {
      char = "│",
      tab_char = "│",
    },
    -- Subtle scope highlighting
    scope = {
      enabled = true,
      char = "│",
      show_start = false,
      show_end = false,
      include = {
        node_type = {
          ["*"] = {
            "class",
            "return_statement",
            "function",
            "method",
            "^if",
            "^while",
            "jsx_element",
            "^for",
            "^object",
            "^table",
            "block",
            "arguments",
            "if_statement",
            "else_clause",
            "jsx_element",
            "jsx_self_closing_element",
            "try_statement",
            "catch_clause",
            "import_statement",
            "operation_type",
          },
        },
      },
    },
    -- Exclude certain filetypes for cleaner look
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
    },
  },
  config = function(_, opts)
    -- Set up minimal indent guide colors
    local highlight = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
    }
    
    -- Very subtle colors for minimal rice aesthetic
    vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { fg = "#2A2D3A", nocombine = true })
    vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = "#2A2D3A", nocombine = true })
    vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#37474F", nocombine = true })
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2A2D3A", nocombine = true })
    vim.api.nvim_set_hl(0, "IblScope", { fg = "#37474F", nocombine = true })
    
    -- Configure highlights
    opts.indent.highlight = highlight
    opts.scope.highlight = "IblScope"
    
    require("ibl").setup(opts)
  end,
}