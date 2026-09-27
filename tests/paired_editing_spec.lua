local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt", false)
  vim.wait(20)
end

local function buffer(filetype, contents)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf)
  vim.bo.filetype = filetype
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { contents or "" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  return buf
end

local function line(expected, label)
  local actual = vim.api.nvim_get_current_line()
  assert(actual == expected, label .. ": expected " .. vim.inspect(expected)
    .. ", got " .. vim.inspect(actual))
end

local function parser(filetype)
  assert(vim.wait(120000, function()
    local language = vim.treesitter.language.get_lang(filetype)
    local parsed, tree = pcall(vim.treesitter.get_parser, 0, language)
    return parsed and tree ~= nil and pcall(function() tree:parse() end)
  end, 100), filetype .. " parser was not installed")
end

local tags = require("paired_tags")
local tag_autocmds = vim.api.nvim_get_autocmds({ group = "PairedTags" })
local tag_events = {}
for _, autocmd in ipairs(tag_autocmds) do tag_events[autocmd.event] = true end
assert(tag_events.InsertCharPre and tag_events.TextChangedI and tag_events.TextChanged,
  "tag editing must track new openers and Insert/Normal changes")

local unavailable = buffer("html", "<div>")
local original_get_parser = vim.treesitter.get_parser
vim.treesitter.get_parser = function() error("parser unavailable") end
local safe_edit, edit_error = pcall(tags.edit, unavailable, 0, 5, true)
vim.treesitter.get_parser = original_get_parser
assert(safe_edit, "tag editing must survive a missing parser: " .. tostring(edit_error))

buffer("lua")
for _, pair in ipairs({ { "(", ")" }, { "[", "]" }, { "{", "}" },
  { "'", "'" }, { '"', '"' }, { "`", "`" } }) do
  vim.api.nvim_set_current_line("")
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  feed("i" .. pair[1] .. "<Esc>")
  line(pair[1] .. pair[2], "insert " .. pair[1])
end

vim.api.nvim_set_current_line("")
vim.api.nvim_win_set_cursor(0, { 1, 0 })
feed("i()<Esc>")
line("()", "closing bracket skips existing mate")

vim.api.nvim_set_current_line("")
vim.api.nvim_win_set_cursor(0, { 1, 0 })
feed("i(<BS><Esc>")
line("", "Backspace deletes an empty pair")

for _, filetype in ipairs({ "html", "xml", "htmldjango", "javascriptreact",
  "typescriptreact", "vue", "svelte", "markdown" }) do
  local buf = buffer(filetype)
  parser(filetype)
  feed("i<div><Esc>")
  line("<div></div>", filetype .. " mapped > closes the tag")
  tags.edit(buf, 0, 5, true)
  line("<div></div>", filetype .. " closing tag remains unique")
end

local child = buffer("html")
vim.api.nvim_buf_set_lines(child, 0, -1, false,
  { "<html>", "  <head>", "    ", "  </head>", "</html>" })
parser("html")
local new_tag = "<title>"
for index = 1, #new_tag do
  local col = 4 + index - 1
  vim.api.nvim_buf_set_text(child, 2, col, 2, col,
    { new_tag:sub(index, index) })
  tags.edit(child, 2, col + 1, true)
  assert(vim.api.nvim_buf_get_lines(child, 4, 5, false)[1] == "</html>",
    "creating a child tag must not rename the parent's closing tag at character "
      .. index)
end
assert(vim.api.nvim_buf_get_lines(child, 2, 3, false)[1] == "    <title></title>",
  "new child tag must close inside its parent")

local partial_inside_paragraph = buffer("html")
local paragraph_prefix = "      <p>Some "
local surrounding = {
  "<!DOCTYPE html>", "<html>", "  <head><title>Autotag test</title></head>",
  "  <body>", '    <div class="test">',
  "      <p>Some text <span>with wrapped part</span></p>",
  "      <em>Italic text</em>", paragraph_prefix .. "</p>",
  "    </div>", "  </body>", "</html>",
}
vim.api.nvim_buf_set_lines(partial_inside_paragraph, 0, -1, false, surrounding)
parser("html")
local typed = "<address"
for index = 1, #typed do
  local column = #paragraph_prefix + index - 1
  vim.api.nvim_buf_set_text(partial_inside_paragraph, 7, column, 7, column,
    { typed:sub(index, index) })
  tags.edit(partial_inside_paragraph, 7, column + 1, true)
  assert(vim.api.nvim_buf_get_lines(partial_inside_paragraph, 7, 8, false)[1]
      == paragraph_prefix .. typed:sub(1, index) .. "</p>",
    "partial <address must preserve </p> at character " .. index)
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(partial_inside_paragraph, 8, 11, false),
      { "    </div>", "  </body>", "</html>" }),
    "partial <address must preserve ancestor closers at character " .. index
      .. ": " .. vim.inspect(vim.api.nvim_buf_get_lines(
        partial_inside_paragraph, 8, 11, false)))
end
local address_end = #paragraph_prefix + #typed
vim.api.nvim_buf_set_text(partial_inside_paragraph, 7, address_end,
  7, address_end, { ">" })
tags.edit(partial_inside_paragraph, 7, address_end + 1, true)
assert(vim.api.nvim_buf_get_lines(partial_inside_paragraph, 7, 8, false)[1]
    == paragraph_prefix .. "<address></address></p>",
  "completed <address> must close before </p> without consuming it: "
    .. vim.inspect(vim.api.nvim_buf_get_lines(partial_inside_paragraph, 7, 8, false)))
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(partial_inside_paragraph, 8, 11, false),
    { "    </div>", "  </body>", "</html>" }),
  "completed <address> must preserve ancestor closing tags")

local parent_of_partial = buffer("html", "<main><p>Some <address</p></main>")
parser("html")
vim.api.nvim_win_set_cursor(0, { 1, 2 })
feed("ciwsection<Esc>")
tags.edit(parent_of_partial, 0, 8, false)
line("<section><p>Some <address</p></section>",
  "renaming a parent must ignore an incomplete child tag")

local expanding_link = buffer("html", "<div><p>Some <a></a></p></div>")
parser("html")
local link_prefix = "<div><p>Some <a"
local suffix = "</p></div>"
local extension = "ddress"
for index = 1, #extension do
  local column = #link_prefix + index - 1
  vim.api.nvim_buf_set_text(expanding_link, 0, column, 0, column,
    { extension:sub(index, index) })
  tags.edit(expanding_link, 0, column + 1, true)
  assert(vim.api.nvim_get_current_line():sub(-#suffix) == suffix,
    "expanding <a> must preserve the paragraph and div at character " .. index)
end
line("<div><p>Some <address></address></p></div>",
  "expanding a paired <a> updates only its own closer")

local parent_closer = buffer("html")
vim.api.nvim_buf_set_lines(parent_closer, 0, -1, false,
  { "<html>", "  <head>", "</html>" })
parser("html")
tags.edit(parent_closer, 1, 8, true)
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(parent_closer, 0, -1, false),
  { "<html>", "  <head></head>", "</html>" }),
  "a new child tag must not treat its parent's closer as its own")

local same_name_child = buffer("html", "<div></div>")
parser("html")
vim.api.nvim_win_set_cursor(0, { 1, 4 })
feed("a<div><Esc>")
line("<div><div></div></div>",
  "new same-name child must not consume its parent's closing tag")

local fast_enter = buffer("html")
vim.api.nvim_buf_set_lines(fast_enter, 0, -1, false,
  { "<html>", "  ", "</html>" })
parser("html")
vim.api.nvim_win_set_cursor(0, { 2, 2 })
feed("A<head><CR><Esc>")
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(fast_enter, 0, -1, false),
  { "<html>", "  <head>", "    ", "  </head>", "</html>" }),
  "a typed Enter immediately after > must split the newly closed tag: "
    .. vim.inspect(vim.api.nvim_buf_get_lines(fast_enter, 0, -1, false)))

local inline_child = buffer("html", "<p><strong><em></em></strong></p>")
parser("html")
local before = "<p><strong><em>"
local after = "</em></strong></p>"
local inline_tag = "<span>"
for index = 1, #inline_tag do
  local inserted = inline_tag:sub(index, index)
  local col = #before + index - 1
  vim.api.nvim_buf_set_text(inline_child, 0, col, 0, col, { inserted })
  tags.edit(inline_child, 0, col + 1, true)
  local actual = vim.api.nvim_get_current_line()
  assert(actual:sub(-#after) == after,
    "new inline child must preserve every enclosing closer at character " .. index)
end
line("<p><strong><em><span></span></em></strong></p>",
  "new inline child closes before all ancestor tags")

local opening_html = buffer("html", "<div></div>")
parser("html")
vim.api.nvim_win_set_cursor(0, { 1, 2 })
feed("ciwsection<Esc>")
tags.edit(opening_html, 0, 8, false)
line("<section></section>", "rename from opening tag")

local closing_html = buffer("html", "<div></div>")
parser("html")
vim.api.nvim_win_set_cursor(0, { 1, 7 })
feed("ciwsection<Esc>")
tags.edit(closing_html, 0, 14, false)
line("<section></section>", "rename from closing tag")

for _, filetype in ipairs({ "htmldjango", "javascriptreact", "typescriptreact",
  "vue", "svelte", "markdown" }) do
  local buf = buffer(filetype, "<div></div>")
  parser(filetype)
  vim.api.nvim_win_set_cursor(0, { 1, 2 })
  feed("ciwsection<Esc>")
  tags.edit(buf, 0, 8, false)
  line("<section></section>", filetype .. " paired rename")
end

local nested = buffer("html", "<div><div></div></div>")
parser("html")
vim.api.nvim_win_set_cursor(0, { 1, 7 })
feed("ciwspan<Esc>")
tags.edit(nested, 0, 10, false)
line("<div><span></span></div>", "nested tags rename only their own mate")

local nested_closer = buffer("html", "<div><span></span></div>")
parser("html")
vim.api.nvim_win_set_cursor(0, { 1, 14 })
feed("ciwsection<Esc>")
tags.edit(nested_closer, 0, 20, false)
line("<div><section></section></div>", "nested closing tag renames its own opener")

local script = buffer("html", '<div><script>const x = "<fake>";</script></div>')
parser("html")
vim.api.nvim_win_set_cursor(0, { 1, 2 })
feed("ciwsection<Esc>")
tags.edit(script, 0, 8, false)
line('<section><script>const x = "<fake>";</script></section>',
  "tag-like text in script content is not paired")

local jsx_text = buffer("javascriptreact", '<div>{ "<fake>" }</div>')
parser("javascriptreact")
vim.api.nvim_win_set_cursor(0, { 1, 2 })
feed("ciwsection<Esc>")
tags.edit(jsx_text, 0, 8, false)
line('<section>{ "<fake>" }</section>', "tag-like text in JSX strings is not paired")

local renamed_xml = buffer("xml", "<item></item>")
parser("xml")
vim.api.nvim_win_set_cursor(0, { 1, 2 })
feed("ciwnode<Esc>")
tags.edit(renamed_xml, 0, 5, false)
line("<node></node>", "XML paired rename")

local replaced_optional_close = buffer("html", "<p><span>text</span></p>")
parser("html")
vim.api.nvim_buf_set_text(replaced_optional_close, 0, 22, 0, 23, { "div" })
tags.edit(replaced_optional_close, 0, 25, false)
line("<div><span>text</span></div>",
  "a completed block-name replacement must rename its explicit p opener")

local cdata = buffer("xml", "<item><![CDATA[<fake>]]></item>")
parser("xml")
vim.api.nvim_win_set_cursor(0, { 1, 2 })
feed("ciwnode<Esc>")
tags.edit(cdata, 0, 5, false)
line("<node><![CDATA[<fake>]]></node>", "CDATA tag-like text is not paired")

local existing_html = buffer("html", "</div>")
parser("html")
feed("i<div><Esc>")
line("<div></div>", "existing closing tag is not duplicated")

local mixed_case_html = buffer("html", "</DIV>")
parser("html")
feed("i<div><Esc>")
line("<div></DIV>", "HTML closing tag matching ignores case")

local void_html = buffer("html")
parser("html")
feed("i<br><Esc>")
tags.edit(void_html, 0, 4, true)
line("<br>", "HTML void element")

local self_closing_xml = buffer("xml")
parser("xml")
feed("i<item/><Esc>")
tags.edit(self_closing_xml, 0, 7, true)
line("<item/>", "XML self-closing element")

local quoted_html = buffer("html")
parser("html")
feed('i<div title=">"><Esc>')
tags.edit(quoted_html, 0, #vim.api.nvim_get_current_line(), true)
line('<div title=">"></div>', "greater-than sign inside a quoted attribute")

local angled_attribute = buffer("html")
parser("html")
feed('i<div title="<x>"><Esc>')
line('<div title="<x>"></div>', "angle brackets inside a quoted attribute")

for _, filetype in ipairs({ "javascriptreact", "typescriptreact" }) do
  local jsx_expression = buffer(filetype)
  parser(filetype)
  feed("i<Card value={a > b}><Esc>")
  line("<Card value={a > b}></Card>",
    filetype .. " expression comparison does not end the opening tag")
end

local comparison = buffer("javascriptreact", "const value = a > b")
parser("javascriptreact")
tags.edit(comparison, 0, 17, true)
line("const value = a > b", "comparison is not a JSX tag")

local html = buffer("html", "<div></div>")
vim.api.nvim_win_set_cursor(0, { 1, 5 })
feed("i<CR>content<Esc>")
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(html, 0, -1, false),
  { "<div>", "  content", "</div>" }), "existing HTML Enter mapping must survive")

local plain = buffer("text")
feed("i<div><Esc>")
tags.edit(plain, 0, 5, true)
line("<div>", "ordinary text must not gain an HTML closing tag")

local landing = vim.fn.readfile("tests/fixtures/paired_editing_landing.html")
assert(#landing > 40, "live-typed landing page fixture is missing")
local landing_buf = buffer("html")
vim.api.nvim_buf_set_lines(landing_buf, 0, -1, false, landing)
parser("html")
local tree = vim.treesitter.get_parser(landing_buf):parse()[1]
local sections = 0
local function inspect(node)
  assert(node:type() ~= "ERROR" and node:type() ~= "erroneous_end_tag",
    "landing page contains malformed HTML at " .. vim.inspect({ node:range() }))
  if node:type() == "element" then
    local text = vim.treesitter.get_node_text(node, landing_buf)
    if text:match("^<section[%s>]") then
      sections = sections + 1
    end
  end
  for child in node:iter_children() do inspect(child) end
end
inspect(tree:root())
assert(sections == 2, "landing page must contain two content sections")
local void = { meta = true, br = true, hr = true, img = true, input = true, link = true }
local stack = {}
for _, source in ipairs(landing) do
  for slash, name in source:gmatch("<(/?)([%a][%w]*)[^>]*>") do
    if slash == "/" then
      assert(stack[#stack] == name,
        "landing page has an unmatched closing tag </" .. name .. ">")
      table.remove(stack)
    elseif not void[name] then
      stack[#stack + 1] = name
    end
  end
end
assert(#stack == 0, "landing page has unclosed tags: " .. vim.inspect(stack))

print("Paired editing passed")
