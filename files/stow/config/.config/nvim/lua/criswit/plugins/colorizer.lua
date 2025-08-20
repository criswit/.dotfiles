return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("colorizer").setup({
      -- Filetypes to enable colorizer on
      filetypes = {
        "*", -- Highlight all files, but customize some others.
        css = { rgb_fn = true }, -- Enable parsing rgb(...) functions in css.
        html = { names = false }, -- Disable parsing "names" like Blue or Gray
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "lua",
        "vim",
        "tmux",
        "zsh",
        "bash",
        "sh",
        "fish",
        "conf",
        "config",
        "dosini",
        "json",
        "yaml",
        "toml",
      },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false, -- "Name" codes like Blue or blue (disable for minimalist look)
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = "background", -- Set the display mode (background looks cleaner for rice)
        -- Available methods are false / true / "normal" / "lsp" / "both"
        tailwind = true, -- Enable tailwind colors
        sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
        virtualtext = "■", -- Virtual text character
        -- update color values even if buffer is not focused
        always_update = false
      },
      -- all the sub-options of filetypes apply to buftypes
      buftypes = {},
    })
    
    -- Auto commands to refresh colorizer when needed
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      group = vim.api.nvim_create_augroup("ColorizerRefresh", { clear = true }),
      pattern = { "*.css", "*.html", "*.js", "*.ts", "*.jsx", "*.tsx", "*.vue", "*.svelte", "*.lua", "*.conf", "*.config", "*.json", "*.yaml", "*.toml" },
      callback = function()
        require("colorizer").attach_to_buffer(0)
      end,
    })
  end,
}