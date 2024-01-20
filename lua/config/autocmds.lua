local cmd = vim.cmd

local function augroup(name)
	return vim.api.nvim_create_augroup("xxx_" .. name, { clear = true })
end

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Don't auto commenting new lines
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]],
})

-- {{exp}} »»» {{ exp }}
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.{md,html,liquid}",
	command = [[
		silent! %s#\v\{\{\s{2,}#{{ #g
		silent! %s#\v\s{2,}\}\}# }}#g

		silent! %s#\v\{\{(\w+)#\=printf("{{ %s", submatch(1))#g
		silent! %s#\v(\w+)\}\}#\=printf("%s }}", submatch(1))#g
	]],
})

-- {%exp%} »»» {% exp %}
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.{md,html,liquid}",
	command = [[
		silent! %s#\v\{\%\s{2,}#{% #g
		silent! %s#\v\s{2,}\%\}# %}#g

		silent! %s#\v\{\%(\w+)#\=printf("{%% %s", submatch(1))#g
		silent! %s#\v(\w+)\%\}#\=printf("%s %%}", submatch(1))#g
	]],
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
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

-- Run MarkdownPreviewStop command after closing a buffer
cmd("autocmd BufDelete *.md ++once MarkdownPreviewStop")

-- Save / Load folding
vim.api.nvim_create_autocmd({ "BufWinLeave", "BufLeave" }, {
	pattern = { "*" },
	command = [[silent! mkview]],
})
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = { "*" },
	command = [[silent! loadview]],
})

-- Disable treesitter-context extension for some filetypes
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "html", "htmldjango" },
	command = "lua require('treesitter-context').disable()",
})

-- Save buffer with prompt
vim.cmd([[
function! SaveBufferWithPrompt()
    if expand('%') == ''
        execute 'w ' . input('Save as: ')
    else
        write
    endif
endfunction
command! WSave call SaveBufferWithPrompt()
]])
