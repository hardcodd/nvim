local cmd = vim.cmd
local augroup = require("config.utils").augroup

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"help",
		"PlenaryTestPopup",
		"lspinfo",
		"man",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"notest-output",
		"neotest-summary",
		"checkhealth",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Automatically create missing directories when writing a file
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("create_missing_dirs"),
	pattern = "*",
	callback = function(event)
		local dir = vim.fn.fnamemodify(event.file, ":h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- Return to last edited position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("return_to_last_position"),
	pattern = "*",
	callback = function()
		if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
			vim.cmd('normal! g`"')
		end
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Save buffer with prompt
vim.cmd([[
function! SaveBufferWithPrompt()
  if expand('%') == ''
    let new_name = input('Save as: ', '', 'file')
    if new_name != ''
      exec ':w ' . new_name
      redraw!
    endif
  else
    write
  endif
endfunction
command! -nargs=0 WSave call SaveBufferWithPrompt()
]])

-- Rename the file for the buffer
vim.cmd([[
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('Moving: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm -rf ' . old_name
    exec ':bdelete! ' . old_name
    redraw!
  endif
endfunction
command! -nargs=0 RenameFile call RenameFile()
]])

-- Remove the file and close the buffer
vim.cmd([[
function! RemoveFile()
  let file_name = expand('%')
  if file_name != '' && file_name != '.'
    let confirm_msg = 'Are you sure you want to delete ' . file_name . '? (y/n)'
    if confirm(confirm_msg, "&Yes\n&No", 2) == 1
      exec ':bdelete! ' . file_name
      exec ':silent !rm -rf ' . file_name
      redraw!
    endif
  endif
endfunction
command! -nargs=0 RemoveFile call RemoveFile()
]])

-- Run current script with python3 by CTRL+R in command and insert mode
cmd("autocmd FileType python map <buffer> <C-r> :w<cr>:exec '!python3' shellescape(@%, 1)<cr>")
cmd("autocmd FileType python imap <buffer> <C-r> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<cr>")

-- Run current script with node by CTRL+R in command and insert mode
cmd("autocmd FileType javascript map <buffer> <C-r> :w<cr>:exec '!node' shellescape(@%, 1)<cr>")
cmd("autocmd FileType javascript imap <buffer> <C-r> <esc>:w<CR>:exec '!node' shellescape(@%, 1)<cr>")

-- Run current script with npx by CTRL+R in command and insert mode
cmd("autocmd FileType typescript map <buffer> <C-r> :w<cr>:exec '!npx ts-node' shellescape(@%, 1)<cr>")
cmd("autocmd FileType typescript imap <buffer> <C-r> <esc>:w<CR>:exec '!npx ts-node' shellescape(@%, 1)<cr>")

-- Run MarkdownPreviewStop command after closing a buffer
cmd("autocmd BufDelete *.md ++once MarkdownPreviewStop")
