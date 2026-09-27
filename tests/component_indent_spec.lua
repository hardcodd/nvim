local failures = {}
local count = 0
local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'xt', false)
end
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
for _, ft in ipairs({ 'vue', 'typescriptreact', 'javascriptreact' }) do
  for _, policy in ipairs({ 'default', 'spaces', 'tabs' }) do
    local width = policy == 'default' and 2 or 4
    local unit = policy == 'tabs' and '\t' or string.rep(' ', width)
    local extension = ({ vue = 'vue', typescriptreact = 'tsx', javascriptreact = 'jsx' })[ft]
    if policy == 'default' then
      vim.fn.delete(root .. '/.editorconfig')
    else
      vim.fn.writefile({ 'root = true', '[*]', 'indent_size = 4', 'tab_width = 4',
        'indent_style = ' .. (policy == 'tabs' and 'tab' or 'space') }, root .. '/.editorconfig')
    end
    local path = root .. '/' .. policy .. '.' .. extension
    vim.fn.writefile({}, path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    assert(vim.bo.filetype == ft and vim.bo.shiftwidth == width, 'filetype and width')
    assert(vim.treesitter.get_parser(0), 'installed parser required')
    local lines = ft == 'vue'
      and { '<template>', unit .. '<main>', unit:rep(2) .. '<Card :items="items" @click="select">',
        unit:rep(3) .. '<Input>Query</Input>', unit:rep(2) .. '</Card>', unit .. '</main>', '</template>' }
      or { 'const App = () => (', unit .. '<main>', unit:rep(2) .. '<Card items={items}>',
        unit:rep(3) .. '<Input>Query</Input>', unit:rep(2) .. '</Card>', unit .. '</main>', ');' }
    for _, action in ipairs({ {3, 'oCONTENT<Esc>'}, {3, 'A<CR>CONTENT<Esc>'}, {4, 'OCONTENT<Esc>'} }) do
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      vim.api.nvim_win_set_cursor(0, { action[1], 0 })
      feed(action[2])
      local expected = vim.deepcopy(lines)
      table.insert(expected, 4, unit:rep(3) .. 'CONTENT')
      local actual = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      count = count + 1
      if not vim.deep_equal(actual, expected) then
        failures[#failures + 1] = ft .. '/' .. policy .. '/' .. action[2] .. ': ' .. vim.inspect(actual)
      end
      assert(vim.api.nvim_win_get_cursor(0)[1] == 4, 'cursor on inserted content line')
    end
    vim.bo.modified = false
  end
end
local cases = {
  { ft = 'vue', lines = { '<template>', '  <Card', '    :items="items"', '  >',
      '  </Card>', '</template>' }, row = 4, indent = 4 },
  { ft = 'vue', lines = { '<script setup lang="ts">', 'if (ready) {', '}', '</script>' },
    row = 2, indent = 2 },
  { ft = 'vue', lines = { '<style scoped>', '.card {', '}', '</style>' }, row = 2, indent = 2 },
  { ft = 'typescriptreact', lines = { 'const App = () => (', '  <>', '  </>', ');' },
    row = 2, indent = 4 },
  { ft = 'javascriptreact', lines = { 'const App = () => (', '  <>', '  </>', ');' },
    row = 2, indent = 4 },
  { ft = 'typescriptreact', lines = { 'const App = () => (', '  <Menu.Item active={left > right}>',
      '  </Menu.Item>', ');' }, row = 2, indent = 4 },
  { ft = 'typescriptreact', lines = { 'const App = () => (', '  <Card>', '    <Icon />',
      '  </Card>', ');' }, row = 3, indent = 4 },
  { ft = 'typescriptreact', lines = { 'const App = () => (', '  <Card>', '    <Input>Query</Input>',
      '  </Card>', ');' }, row = 3, indent = 4 },
}
for _, case in ipairs(cases) do
  vim.cmd.enew()
  vim.bo.filetype = case.ft
  vim.api.nvim_buf_set_lines(0, 0, -1, false, case.lines)
  vim.api.nvim_win_set_cursor(0, { case.row, 0 })
  feed('oCONTENT<Esc>')
  local expected = vim.deepcopy(case.lines)
  table.insert(expected, case.row + 1, string.rep(' ', case.indent) .. 'CONTENT')
  local actual = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  count = count + 1
  if not vim.deep_equal(actual, expected) then
    failures[#failures + 1] = case.ft .. '/extra: ' .. vim.inspect(actual)
  end
  vim.bo.modified = false
end
vim.fn.delete(root, 'rf')
assert(#failures == 0, table.concat(failures, '\n'))
print('Component indentation passed: ' .. count)
