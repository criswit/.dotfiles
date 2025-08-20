return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
  },
  opts = {
    options = {
      -- Minimal styling for clean look
      mode = "buffers", -- can be "buffers" or "tabs"
      style_preset = "minimal", -- minimal | default | no_bold | no_italic
      themable = true,
      numbers = "none", -- can be "none" | "ordinal" | "buffer_id" | "both"
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      left_mouse_command = "buffer %d",
      middle_mouse_command = nil,
      indicator = {
        icon = "▎", -- this should be omitted if indicator style is not 'icon'
        style = "icon", -- can be 'icon' | 'underline' | 'none'
      },
      buffer_close_icon = "󰅖",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      
      -- Minimal separators for clean look
      separator_style = "slope", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
      
      -- Enhanced UI settings for minimalist rice
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      hover = {
        enabled = true,
        delay = 200,
        reveal = {"close"}
      },
      
      -- Buffer management
      sort_by = "insert_after_current",
      move_wraps_at_ends = false,
      
      -- Diagnostic integration
      diagnostics = "nvim_lsp",
      diagnostics_update_in_insert = false,
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      
      -- Custom filter for special buffers
      custom_filter = function(buf_number, buf_numbers)
        -- Don't show terminal buffers in bufferline
        if vim.bo[buf_number].filetype ~= "terminal" then
          return true
        end
      end,
      
      -- Tab settings
      show_tab_indicators = false,
      show_duplicate_prefix = true,
      tab_size = 21,
      max_name_length = 30,
      max_prefix_length = 30,
      truncate_names = true,
      
      -- Icon and styling settings
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      
      -- Offset for file explorer
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
        {
          filetype = "NvimTree",
          text = "Explorer",
          highlight = "Directory",
          text_align = "left",
        }
      },
    },
    
    -- Custom highlighting to match our rice theme
    highlights = {
      fill = {
        bg = "#1B1E2B",
      },
      background = {
        fg = "#B2CCD6",
        bg = "#1B1E2B",
      },
      buffer_visible = {
        fg = "#B2CCD6",
        bg = "#212335",
      },
      buffer_selected = {
        fg = "#82AAFF",
        bg = "#0F111A",
        bold = true,
        italic = false,
      },
      numbers = {
        fg = "#546E7A",
        bg = "#1B1E2B",
      },
      numbers_visible = {
        fg = "#546E7A",
        bg = "#212335",
      },
      numbers_selected = {
        fg = "#82AAFF",
        bg = "#0F111A",
        bold = true,
        italic = false,
      },
      diagnostic = {
        fg = "#546E7A",
        bg = "#1B1E2B",
      },
      diagnostic_visible = {
        fg = "#546E7A",
        bg = "#212335",
      },
      diagnostic_selected = {
        fg = "#FF5370",
        bg = "#0F111A",
        bold = true,
        italic = false,
      },
      hint = {
        fg = "#C3E88D",
        sp = "#C3E88D",
        bg = "#1B1E2B",
      },
      hint_visible = {
        fg = "#C3E88D",
        bg = "#212335",
      },
      hint_selected = {
        fg = "#C3E88D",
        bg = "#0F111A",
        sp = "#C3E88D",
        bold = true,
        italic = false,
      },
      hint_diagnostic = {
        fg = "#C3E88D",
        sp = "#C3E88D",
        bg = "#1B1E2B",
      },
      hint_diagnostic_visible = {
        fg = "#C3E88D",
        bg = "#212335",
      },
      hint_diagnostic_selected = {
        fg = "#C3E88D",
        bg = "#0F111A",
        sp = "#C3E88D",
        bold = true,
        italic = false,
      },
      info = {
        fg = "#89DDFF",
        sp = "#89DDFF",
        bg = "#1B1E2B",
      },
      info_visible = {
        fg = "#89DDFF",
        bg = "#212335",
      },
      info_selected = {
        fg = "#89DDFF",
        bg = "#0F111A",
        sp = "#89DDFF",
        bold = true,
        italic = false,
      },
      info_diagnostic = {
        fg = "#89DDFF",
        sp = "#89DDFF",
        bg = "#1B1E2B",
      },
      info_diagnostic_visible = {
        fg = "#89DDFF",
        bg = "#212335",
      },
      info_diagnostic_selected = {
        fg = "#89DDFF",
        bg = "#0F111A",
        sp = "#89DDFF",
        bold = true,
        italic = false,
      },
      warning = {
        fg = "#FFCB6B",
        sp = "#FFCB6B",
        bg = "#1B1E2B",
      },
      warning_visible = {
        fg = "#FFCB6B",
        bg = "#212335",
      },
      warning_selected = {
        fg = "#FFCB6B",
        bg = "#0F111A",
        sp = "#FFCB6B",
        bold = true,
        italic = false,
      },
      warning_diagnostic = {
        fg = "#FFCB6B",
        sp = "#FFCB6B",
        bg = "#1B1E2B",
      },
      warning_diagnostic_visible = {
        fg = "#FFCB6B",
        bg = "#212335",
      },
      warning_diagnostic_selected = {
        fg = "#FFCB6B",
        bg = "#0F111A",
        sp = "#FFCB6B",
        bold = true,
        italic = false,
      },
      error = {
        fg = "#FF5370",
        sp = "#FF5370",
        bg = "#1B1E2B",
      },
      error_visible = {
        fg = "#FF5370",
        bg = "#212335",
      },
      error_selected = {
        fg = "#FF5370",
        bg = "#0F111A",
        sp = "#FF5370",
        bold = true,
        italic = false,
      },
      error_diagnostic = {
        fg = "#FF5370",
        sp = "#FF5370",
        bg = "#1B1E2B",
      },
      error_diagnostic_visible = {
        fg = "#FF5370",
        bg = "#212335",
      },
      error_diagnostic_selected = {
        fg = "#FF5370",
        bg = "#0F111A",
        sp = "#FF5370",
        bold = true,
        italic = false,
      },
      modified = {
        fg = "#FFCB6B",
        bg = "#1B1E2B",
      },
      modified_visible = {
        fg = "#FFCB6B",
        bg = "#212335",
      },
      modified_selected = {
        fg = "#FFCB6B",
        bg = "#0F111A",
      },
      duplicate_selected = {
        fg = "#546E7A",
        bg = "#0F111A",
        italic = false,
      },
      duplicate_visible = {
        fg = "#546E7A",
        bg = "#212335",
        italic = false,
      },
      duplicate = {
        fg = "#546E7A",
        bg = "#1B1E2B",
        italic = false,
      },
      separator_selected = {
        fg = "#1B1E2B",
        bg = "#0F111A",
      },
      separator_visible = {
        fg = "#1B1E2B",
        bg = "#212335",
      },
      separator = {
        fg = "#1B1E2B",
        bg = "#1B1E2B",
      },
      indicator_selected = {
        fg = "#82AAFF",
        bg = "#0F111A",
      },
      pick_selected = {
        fg = "#C792EA",
        bg = "#0F111A",
        bold = true,
        italic = false,
      },
      pick_visible = {
        fg = "#C792EA",
        bg = "#212335",
        bold = true,
        italic = false,
      },
      pick = {
        fg = "#C792EA",
        bg = "#1B1E2B",
        bold = true,
        italic = false,
      },
    },
  },
}