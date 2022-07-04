local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd

-- Don't auto commenting new lines
autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
	pattern = "*",
	command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]],
})

-- Delete trailing white space on save, useful for some filetypes
autocmd("BufWritePre", {
	pattern = "*",
	command = [[
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
  ]],
})

-- Run current script with python3 by CTRL+R in command and insert mode
cmd("autocmd FileType python map <buffer> <C-r> :w<cr>:exec '!python3' shellescape(@%, 1)<cr>")
cmd("autocmd FileType python imap <buffer> <C-r> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<cr>")

-- Run current script with node by CTRL+R in command and insert mode
cmd("autocmd FileType javascript map <buffer> <C-r> :w<cr>:exec '!node' shellescape(@%, 1)<cr>")
cmd("autocmd FileType javascript imap <buffer> <C-r> <esc>:w<CR>:exec '!node' shellescape(@%, 1)<cr>")

-- Run current script with npx by CTRL+R in command and insert mode
cmd("autocmd FileType typescript map <buffer> <C-r> :w<cr>:exec '!npx ts-node' shellescape(@%, 1)<cr>")
cmd("autocmd FileType typescript imap <buffer> <C-r> <esc>:w<CR>:exec '!npx ts-node' shellescape(@%, 1)<cr>")

-- Set html fyletype for htmldjango files
cmd([[
augroup htmldjang_ft
au!
autocmd BufNew,BufNewFile,BufRead *.html :set filetype=html
augroup END
]])
