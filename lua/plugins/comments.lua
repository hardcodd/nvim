return {
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    commit = "6141a40173c6efa98242dc951ed4b6f892c97027",
    lazy = false,
    main = "ts_context_commentstring",
    opts = { enable_autocmd = false },
  },
  {
    "numToStr/Comment.nvim",
    commit = "e30b7f2008e52442154b66f7c519bfd2f1e32acb",
    lazy = false,
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = require("functions.plugins").comments,
  },
  {
    "folke/todo-comments.nvim",
    commit = "31e3c38ce9b29781e4422fc0322eb0a21f4e8668",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = require("functions.plugins").todo_comments,
    opts = {
      signs = false,
      keywords = {
        FIX = { icon = "F " },
        TODO = { icon = "T " },
        HACK = { icon = "H " },
        WARN = { icon = "W " },
        PERF = { icon = "P " },
        NOTE = { icon = "N " },
        TEST = { icon = "S " },
      },
    },
  },
}
