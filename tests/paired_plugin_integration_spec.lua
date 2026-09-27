local spec = require("plugins.paired_tags")
assert(spec[1] == "hardcodd/paired-tags.nvim",
  "paired tags must load from the published GitHub repository")
assert(spec.main == "paired_tags" and spec.lazy == false,
  "paired tags must initialize at startup")

local tags = require("paired_tags")
assert(type(tags.setup) == "function" and type(tags.html_enter) == "function",
  "the standalone plugin must provide closing and Enter")

local greater = vim.fn.maparg(">", "i", false, true)
local enter = vim.fn.maparg("<CR>", "i", false, true)
assert(greater.expr == 1 and greater.desc == "Close a completed markup tag",
  "plugin must install the tag closing mapping")
assert(enter.expr == 1 and enter.desc == "Indent between matching HTML tags",
  "plugin must install the HTML Enter mapping")
assert(#vim.api.nvim_get_autocmds({ group = "PairedTags" }) > 0,
  "plugin must install its own tag callbacks")

print("Paired plugin integration passed")
