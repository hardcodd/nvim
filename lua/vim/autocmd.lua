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

-- {{exp}} »»» {{ exp }}
autocmd("BufWritePre", {
	pattern = "*.{md,html,liquid}",
	command = [[
		silent! %s#\v\{\{[\s]{2,}#{{ #g
		silent! %s#\v[\s]{2,}\}\}# }}#g

		silent! %s#\v\{\{(\w+)#\=printf("{{ %s", submatch(1))#g
		silent! %s#\v(\w+)\}\}#\=printf("%s }}", submatch(1))#g
	]],
})

-- Px2Em
autocmd("BufWritePre", {
	pattern = "*.{css,scss,sass,less,styl,md,html}",
	command = [[
		let font_size = get(g:, "font_size", 16)

		silent! %s#\v(\d*\.*\d+)rpx\s*\/\s*(\d*\.*\d+)(px)?#\=printf("%0.3frem", 1.0/str2float(submatch(2))*str2float(submatch(1)))#g
		silent! %s#\v(\d*\.*\d+)epx\s*\/\s*(\d*\.*\d+)(px)?#\=printf("%0.3fem", 1.0/str2float(submatch(2))*str2float(submatch(1)))#g

		silent! %s#\v(\d*\.*\d+)rpx#\=printf("%0.3frem", 1.0/font_size*str2float(submatch(1)))#g
		silent! %s#\v(\d*\.*\d+)epx#\=printf("%0.3fem", 1.0/font_size*str2float(submatch(1)))#g
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
