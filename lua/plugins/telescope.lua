return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.6",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-media-files.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  cmd = "Telescope",
  keys = {
    -- find
    { "ff",         "<cmd>Telescope find_files <CR>",                                        "Find files" },
    { "fa",         "<cmd>Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find all" },
    { "fw",         "<cmd> Telescope live_grep <CR>",                                        "Live grep" },
    { "fb",         "<cmd>Telescope file_browser <CR>",                                      "File browser" },
    { "fh",         "<cmd>Telescope help_tags <CR>",                                         "Help page" },
    { "fo",         "<cmd>Telescope oldfiles <CR>",                                          "Find oldfiles" },
    { "fz",         "<cmd>Telescope current_buffer_fuzzy_find <CR>",                         "Find in current buffer" },
    { "ft",         "<cmd>TodoTelescope<CR>",                                                "Find TODOs" },
    { "fm",         "<cmd>Telescope media_files<CR>",                                        "Find media files" },
    { "fr",         "<cmd>Telescope lsp_references<CR>",                                     "Find references" },
    { "fi",         "<cmd>Telescope lsp_implementations<CR>",                                "Find implementations" },
    { "fd",         "<cmd>Telescope lsp_definitions<CR>",                                    "Find definitions" },
    { "fC",         "<cmd>Telescope commands<CR>",                                           "Find commands" },

    -- git
    { "<leader>gc", "<cmd> Telescope git_commits <CR>",                                      "Git commits" },
    { "<leader>gs", "<cmd> Telescope git_status <CR>",                                       "Git status" },

    { "<leader>ma", "<cmd> Telescope marks <CR>",                                            "Telescope bookmarks" },
  },
  opts = function()
    return {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "-L",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
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
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = { "node_modules", "venv", "__pycache__", "/model/" },
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
          ["n"] = { ["q"] = require("telescope.actions").close },
          ["i"] = {
            ["jk"] = require("telescope.actions").close,
            ["<PageUp>"] = require("telescope.actions").preview_scrolling_up,
            ["<PageDown>"] = require("telescope.actions").preview_scrolling_down,
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
          },
        },
      },
    }
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("file_browser")
    require("telescope").load_extension("media_files")
  end,
}
