"Neovim resource file from Philipp van Wickevoort Crommelin.
"Contact me by email: philippcrommelin@googlemail.com.
"------------------------------PLUGINS------------------------------{{{
call plug#begin()
"Plug 'ncm2/ncm2'
"Plug 'roxma/nvim-yarp'
Plug 'jalvesaq/Nvim-R'
"Plug 'gaalcaras/ncm-R'
"Plug 'ncm2/ncm2-bufword'
"Plug 'ncm2/ncm2-path'
"Plug 'lervag/vimtex'
"Plug 'junegunn/vim-easy-align'
Plug 'Shougo/deoplete.nvim'
Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'
"Plug 'garbas/vim-snipmate'
Plug 'preservim/nerdtree'
Plug  'ryanoasis/vim-devicons'
"Plug  'vim-syntastic/syntastic'
"Plug 'Lokaltog/powerline'
"Plug 'tpope/vim-surround'
"Plug 'zchee/deoplete-jedi' "
Plug 'vim-airline/vim-airline' "fancy vim status bar
"Plug 'vim-airline/vim-airline-themes'
Plug 'jiangmiao/auto-pairs' "set matching quotation marks, braces, etc.
"Plug 'davidhalter/jedi-vim' "python go-to function and completion
Plug 'sbdchd/neoformat' "code formatting
Plug 'neomake/neomake'
"Plug 'Vigemus/iron.nvim'
Plug 'tpope/vim-fugitive'
Plug 'edkolev/tmuxline.vim'
call plug#end()
"------------------------------CUSTOM PLUGINS
execute ":source ".'/Users/Philipp/.config/nvim/autoload/grep-operator.vim'
"}}}
"	================================================= Personal configuration ===================={{{
"------------------------------GLOBAL VARIABLES------------------------------{{{
"Global indicator variable for more verbose output
let g:SPELL_LANG = "en_us"
let s:verbose = 0
let g:VIMRC_DIR = "/Users/Philipp/Developer/Vimscript/init.vim"
let g:python3_host_prog="/Users/Philipp/anaconda3/python.app/Contents/MacOS/python"
let g:python_host_prog="/usr/bin/python"
let mapleader = '\'|			"set the leader key to the hyphen character
let maplocalleader = '-'|		"map the localleader key to a backslash
let g:trlWspPattern = '\v\s+$'|		"Search pattern for trailing whitespace
"}}}
"------------------------------FUNCTIONS------------------------------{{{
"TODO: Function that changes a word globally
"TODO: create formatter for r function arguments
"set local working directory
function! s:setLocalWorkDir()
	echom &buftype
	if len(&buftype) == 0	"normal buffer has empty option &buftype (see :help buftype)
		execute ":lcd " . expand("%:p:h")
	endif
endfunction
"Format and Feed to Read-Eval-Print-Loop
function! s:FormatAndFeedToRepl(mode)
	if a:mode ==? 'v'
		let [startpos_l,startpos_c] =  getpos("'<")[1:2]
		let [endpos_l,endpos_c] =  getpos("'>")[1:2]
		let firstLn = substitute(getline(startpos_l),'\v(.*\()(.*)','\2','')
		let currLnNum = startpos_l + 1
		let funArgsRaw = ""
		let currLn = ""
		if startpos_l == endpos_l
			let funArgsRaw = substitute(firstLn,'\v(.*)(\).*)','\1','')
		else
			while currLnNum < endpos_l
				let currLn = getline(currLnNum)
				let funArgsRaw .= " ".currLn
				let currLnNum += 1
			endwhile
			let lastLn = substitute(getline(endpos_l),'\v(.*)(\).*)','\1','')
			let funArgsRaw = firstLn . funArgsRaw . lastLn
		endif

		let trimmed = substitute(funArgsRaw,'\v[ \t]','','g')
		let splitted = split(trimmed,',')
		echo splitted
	endif
endfunction
"Open adequate completion menu
function! s:OpenOmni()
	if !pumvisible()
		let minLength = 1
		let ln = line(".")
		let l = getline(ln)
		let g:lineUntilCursor = strpart(l,0,col(".")-1)
		let g:wordUntilCursor = matchstr(g:lineUntilCursor,'\v[^ \t][^^ \t]*$')
		let g:wordIsLongEnough = len(g:wordUntilCursor)>=minLength
		let cursorIsWithinFunctionArgs = match(getline(ln-1),'\v\(\s*$')>=0 && len(g:wordUntilCursor)==0
		call Pvwc_c("wordUntilCursor = ".g:wordUntilCursor)
		let L = len(g:wordUntilCursor)
		let wantsToGetNewFunArg = strpart(g:wordUntilCursor,L-1,1)==#','
		let g:wordIsFilePath = match(g:wordUntilCursor,'\v\/')>=0
		if len(g:wordUntilCursor)>=3
			return "\<c-x>\<c-o>"
		elseif len(g:wordUntilCursor)>=1 && g:wordIsFilePath
			return "\<c-x>\<c-f>"
		elseif(cursorIsWithinFunctionArgs || wantsToGetNewFunArg)
			return "\<c-x>\<c-o>"
		else
			return "\<tab>"
		endif
	else
		return "\<C-n>"
	endif
endfunction
"Toggle spell check
function! s:SpellCheckToggle()
	if &spell
		set nospell
	else
		execute "set spell spelllang=".g:SPELL_LANG
	endif
endfunction
"Toggle quickfix window
function! s:QuickFixToggle()
	if exists("g:quickfix_window_is_open") && g:quickfix_window_is_open
		cclose
		let g:quickfix_window_is_open = 0
		"restore last window
		execute g:quickfix_last_open_win."wincmd w"
	else
		let g:quickfix_last_open_win = winnr()
		copen
		let g:quickfix_window_is_open = 1
	endif
	return
endfunction
"Function to toggle the foldcolumn
function! s:FoldColumnToggle()
	if &foldcolumn
		setlocal foldcolumn=0
	else
		setlocal foldcolumn=4
	endif
endfunction

function! Pvwc_checkBuf(bufNr)
	function! Local_addBuf(_bufNr)
		let g:numOfBufs += 1
		let g:bufNumbrs += [a:_bufNr]
		let g:tabBufNames += [bufname(a:_bufNr)]
		call Pvwc_c("Buffer nr. ".a:_bufNr." with name ".bufname(a:_bufNr)." will be added")
	endfunction
	function! Local_rmBuf(_bufNr)
		let bufNumbrsInd = index(g:bufNumbrs,a:_bufNr)
		let tabBufNamesInd = index(g:tabBufNames,bufname(a:_bufNr))
		call Pvwc_c("Buffer nr. ".a:_bufNr." with name ".bufname(a:_bufNr)." will be removed")
		call remove(g:bufNumbrs,bufNumbrsInd)
		call remove(g:tabBufNames,tabBufNamesInd)
	endfunction
	if buflisted(a:bufNr) && index(g:bufNumbrs,a:bufNr)<0
		call Local_addBuf(a:bufNr)
	else
		call Pvwc_c("Buffer nr. ".a:bufNr." with name ".bufname(a:bufNr)." will be ignored")
	endif
endfunction
"Open a new window and cycle through all listed buffers (A)
function! s:Pvwc_bufferCycle(direction)
	function! Local_incrementIndex()
		if g:curBufIndex ==# (g:numOfBufs-1)
			let g:curBufIndex = 0
		else
			let g:curBufIndex += 1
		endif
	endfunction
	function! Local_decrementIndex()
		if g:curBufIndex==#0
			let g:curBufIndex = (g:numOfBufs-1)
		else
			let g:curBufIndex -= 1
		endif
	endfunction
	function! Local_cycleIndex(direc)
		if exists("g:curBufIndex")
			if a:direc ==? "up"
				call Local_incrementIndex()
			elseif a:direc ==? "down"
				call Local_decrementIndex()
			endif
		else
			let g:curBufIndex = 0
		endif
	endfunction
	function! Local_openNewWindow()
		"let g:lastWinID = win_getid()
		execute ":topleft vertical split ".g:tabBufNames[g:curBufIndex]
		let g:bufCycWindowID = win_getid()
		"call win_gotoid(g:lastWinID)
	endfunction
	function! Local_openExistingWindow()
		let g:lastWinID = win_getid()
		call win_gotoid(g:bufCycWindowID)
		execute ":edit ".g:tabBufNames[g:curBufIndex]
		call win_gotoid(g:lastWinID)
	endfunction

	if exists("g:bufCycWindowID")
		if !empty(getwininfo(g:bufCycWindowID))
			call Local_cycleIndex(a:direction)
			call Local_openExistingWindow()
		else
			call Local_cycleIndex(a:direction)
			call Local_openNewWindow()
		endif
	else
		let g:numOfTrialBufs = 20
		let g:numOfBufs = 0
		let g:bufNumbrs = []
		let g:tabBufNames = []
		for bufNr in range(1,g:numOfTrialBufs)
			call Pvwc_checkBuf(bufNr)
		endfor
		call Local_cycleIndex(a:direction)
		call Local_openNewWindow()
		augroup startBufferCyclerAutomation
			autocmd!
			autocmd BufReadPost * call Pvwc_checkBuf(bufnr())
			"autocmd BufWinEnter * execute "if index(g:bufNumbrs,bufnr())<0"."\n"."call Pvwc_checkBuf(bufnr())"."\n"."echom \"Buffer checked\""."\n"."else"."\n"."echom \"Buffer already checked\""."\n"."endif"."\n"
			"autocmd BufWinEnter * execute "if index(g:bufNumbrs,bufnr())>0"."\n"."call Pvwc_checkBuf(bufnr())"."\n"."echom \"Buffer checked\""."\n"."else"."\n"."echom \"Buffer already checked\""."\n"."endif"."\n"
		augroup END
	endif
endfunction
"Function that toggles highlighting trailing white-space characters
function! Pvwc_hlTrlWsp()
	highlight trlWspGroup ctermbg=green guibg=green
	function! Local_hl()
		execute ":match trlWspGroup /".g:trlWspPattern."/"
		let g:highlTrailWhsp = 1
	endfunction
	function! Local_nohl()
		"Do not highlight anything
		:match trlWspGroup /-dd-sdf-weiosdf-sdfhas-ewhd/
		let g:highlTrailWhsp = 0
	endfunction
	if exists("g:highlTrailWhsp")
		if g:highlTrailWhsp
			call Local_nohl()
		else
			call Local_hl()
		endif
	else
		call Local_hl()
	endif
endfunction
"Print a comment if boolean script variable s:verbose is set
function! Pvwc_c(comment)
	if s:verbose
		echo a:comment
	endif
endfunction

"Go to a window with given window number and reload current working dir of
"NERDTree
function! s:GoToWinAndRefreshNerdtree(winNumber)
	call win_gotoid(win_getid(a:winNumber))
	if(&buftype==#'')	"empty buftype option corresponds to normal buffer (see help buftype)
		NERDTreeCWD
		call win_gotoid(win_getid(a:winNumber))
	endif
endfunction

"Go to previous/next window if direction is 'backward'/'forward'
function! s:GoToNeighbourWin(direction)
	let c = winnr('$')
	if a:direction ==# "backward"
		let p = winnr()-1
		if( p==0 )
			call <SID>GoToWinAndRefreshNerdtree(c)
		else
			call <SID>GoToWinAndRefreshNerdtree(p%c)
		endif
	else	"forward
		let p = winnr()+1
		if( p==c )
			call <SID>GoToWinAndRefreshNerdtree(c)
		else
			call <SID>GoToWinAndRefreshNerdtree(p%c)
		endif
	endif
endfunction

"Toggle syntax coloring
function! Pvwc_ToggleSyntax()
	if(exists("g:syntax_on"))
		syntax off
	else
		syntax enable
	endif
endfunction

function GR(replacementString)
	  %s/{expand("<cword>")}/{a:replacementString}/gc
endfunction

"Perform search with "/" within visually selected range
function! RangeSearch(direction)
  call inputsave()
  let g:srchstr = input(a:direction)
  call inputrestore()
  if strlen(g:srchstr) > 0
    let g:srchstr = g:srchstr.
          \ '\%>'.(line("'<")-1).'l'.
          \ '\%<'.(line("'>")+1).'l'
  else
    let g:srchstr = ''
  endif
endfunction

"Reset cursor position
function! ResCur()
	try
		if line("'\"") <= line("$")
			normal! g`"
			return 1
		endif
	endtry
endfunction

"Maximize current window
"TODO: if a buffer change occurs in either window mirror
"that in the other one
"TODO: if a split occurs in maximized window connect that split to the minimized
"window somehow
function! Pvwc_MaxCurWin()
	let g:cursorPosition = getcurpos()
	"let g:cursorRow = g:cp[1]
	"let g:cursorCol = g:cp[4]
	if !exists("g:minMaxPairs")
		let g:minMaxPairs = {}
		let g:maxMinPairs = {}
	endif
	let g:minWinID = win_getid()
	let g:minBn = bufname(bufnr())
	call Pvwc_c("Pvwc: Current window ID = ".g:minWinID."\tbuffer name\t".g:minBn)
	let g:maxWinID = get(g:minMaxPairs,g:minWinID,0)
	function! NewTab()
		execute ":tabedit ".g:minBn
		let g:maxWinID = win_getid()
		call extend(g:minMaxPairs,{g:minWinID:g:maxWinID})
		call extend(g:maxMinPairs,{g:maxWinID:g:minWinID})
		call setpos(".",g:cursorPosition)
	endfunction
	if g:maxWinID!=#0 && !empty(getwininfo(g:maxWinID))
		call Pvwc_c("Max window does already exist. MaxWinID is\t".g:maxWinID)
		call win_gotoid(g:maxWinID)
		call setpos(".",g:cursorPosition)
	elseif g:maxWinID!=#0 && empty(getwininfo(g:maxWinID))
		call Pvwc_c("remove invalid entries")
		call remove(g:minMaxPairs,g:minWinID)
		call remove(g:maxMinPairs,g:maxWinID)
		call NewTab()
	else
		call Pvwc_c("Max window does not exist")
		call NewTab()
	endif
endfunction

function! Pvwc_MinCurWin()
	if exists("g:maxMinPairs")
		let g:maxWinID = win_getid()
		let g:minWinID = get(g:maxMinPairs,g:maxWinID,0)
		if g:minWinID==#0
			call Pvwc_c("There is not minimized window that belongs to the current window. Nothing done")
		else
			call Pvwc_c("Close maximized window and go to minimized version")
			let g:cursorPosition = getcurpos()
			execute ":close"
			call win_gotoid(g:minWinID)
			call setpos(".",g:cursorPosition)
			call remove(g:maxMinPairs,g:maxWinID)
			call remove(g:minMaxPairs,g:minWinID)
		endif
	endif
endfunction
"}}}
"------------------------------SETTINGS------------------------------{{{
"TODO:command that repeats last command
command! Tex :w|:!pdflatex -shell-escape %
set omnifunc=syntaxcomplete#Complete
set foldcolumn=4|
set ignorecase|		"Ignore case for vim search function / or ?
set hlsearch incsearch|	"highlight all matching search patterns while typing
set textwidth=80|	"Insert mode: Line feed is automatically inserted during writing.
set splitright|		"make new vertical splits appear to the right
set splitbelow|		"make new horizontal splits appear below
			"consider command <<aboveleft>> for vertical/horizontal splits to open to the left/top of the
"current active window
set wrap|		"let lines break, if their lengths exceed the window size
set mouse=a
set shiftround|		"round value for indentation to multiple of shiftwidth
set number
set laststatus=2
set autoindent
set smartindent
"set autowriteall 	"automatically write buffers when required
filetype plugin indent on
"}}}

"------------------------------ABBREVIATIONS------------------------------{{{
iabbrev 'van\ W' van Wickevoort Crommelin
"
"}}}

"------------------------------MAPPINGS------------------------------{{{
"------------------------------GLOBAL{{{
"move cursor just before found character
noremap f t
"move cursor just after found character
noremap F T
"}}}
"------------------------------NORMAL MODE{{{
"Search operator
"nnoremap <silent> <leader>g :execute "grep! -iR ".shellescape(expand("<cWORD>"))." /Users/Philipp/Desktop/pythonOutput"<cr>:copen<cr>
"toggle number option
nnoremap <silent> <localleader>N :setlocal number!<cr>
"toggle spell control
nnoremap <localleader>s :call <SID>SpellCheckToggle()<cr>
"Enter insert mode automatically after Deletion from cursor to EOL character
nnoremap <silent> D Da
"toggle quickfix window
nnoremap <localleader>q :call <SID>QuickFixToggle()<cr>
"navigate within the quickfix-window
nnoremap <silent> ä :cprevious<cr>
nnoremap <silent> ü :cnext<cr>
"Cycle through all listed buffers
nnoremap <localleader>f :call <SID>FoldColumnToggle()<cr>
noremap <silent> t :call <SID>Pvwc_bufferCycle("up")<cr>
noremap <silent> <s-T> :call <SID>Pvwc_bufferCycle("down")<cr>
"echo cword
nnoremap <localleader>ee :execute "echom shellescape(expand(\"\<cword>\"))"<cr>
"echo cWORD
nnoremap <localleader>EE :execute "echom shellescape(expand(\"\<cWORD>\"))"<cr>
"disable highlighting from previous search commands.
nnoremap <silent> <localleader>v :nohl<cr>
"Disable search highlighting
nnoremap <silent> <localleader>l :nohlsearch<cr>
"Perform 'very magic' searches by default, for conventional regex pattern parsing like
"perl, python and ruby.
nnoremap / /\v
"Highlight all trailing white space charactes before end-of-line character
nnoremap <silent> <localleader>w :call Pvwc_hlTrlWsp()<cr>
"Delete all trailing white space charactes before end-of-line character
nnoremap <silent> <localleader>W :execute "normal! mq:%s/".trlWspPattern."//g\r:nohl\r`q"<cr>
"Write and close all windows in all tabs und quit vim
nnoremap <localleader>Z :wqall<cr>
"maximize window
"nnoremap <localleader>M :tabedit %<cr>
nnoremap <silent> <localleader>M :call Pvwc_MaxCurWin()<cr>
"minimize window
nnoremap <silent> <localleader>m :call Pvwc_MinCurWin()<cr>
"write and close
nnoremap Z ZZ|	"write and close
"map redo to capital u
nnoremap U <c-r>
"go to next buffer
nnoremap <silent> <localleader>b :bnext<cr>
"go to previous buffer
nnoremap <silent> <localleader>B :bprevious<cr>
"go to next window
nnoremap <silent> <tab> :call <SID>GoToNeighbourWin("forward")<esc>
"go to previous window
nnoremap <silent> <S-tab> :call <SID>GoToNeighbourWin("backward")<esc>
"Edit vimrc file
nnoremap <silent> <localleader>ev :execute ":split ".$MYVIMRC."\|:lcd ".g:VIMRC_DIR<cr>
"source (aka. "reload") vimrc file
nnoremap <silent> <localleader>r :source $MYVIMRC<CR>
"open terminal emulator
nnoremap <silent> <localleader>C :<c-u>execute "split term://zsh"<cr>:startinsert<cr>
"select word with space key
nnoremap <space> viw
"clear current line
nnoremap <localleader>d ddO
"Increase tabstop
noremap <silent> <localleader>ll :let &tabstop += (&tabstop < 10) ? 1 : 0 <CR>
"Decrease tabsto
noremap <silent> <localleader>hh :let &tabstop -= (&tabstop < 2) ? 0 : 1 <CR>
"}}}
"------------------------------VISUAL MODE{{{
"feed to REPL
vnoremap <localleader>, <esc><c-u>:call <SID>FormatAndFeedToRepl(visualmode())<cr>
"Enclose/surround visually selected area with/by angle brackets
vnoremap <localleader>e< <esc>`<i<<esc>`>la><esc>
"Enclose/surround visually selected area with/by brackets
vnoremap <localleader>e[ <esc>`<i[<esc>`>la]<esc>
"Enclose/surround visually selected area with/by braces
vnoremap <localleader>e{ <esc>`<i{<esc>`>la}<esc>
"Enclose/surround visually selected area with/by parenthesis
vnoremap <localleader>e( <esc>`<i(<esc>`>la)<esc>
"Enclose/surround visually selected area with/by single quotes
vnoremap <localleader>e' <esc>`<i'<esc>`>la'<esc>
"Enclose/surround visually selected area with/by single quotes
vnoremap <localleader>e" di"<esc>pa"<esc>
"go to the last printable character of current line (skip newline char)
vnoremap $ g_
"Search constrained to visually selected range.
vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|execute '/'.g:srchstr\|endif<CR>
"Backward search constrained to visually selected range
vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|execute '?'.g:srchstr\|endif<CR> <lsflaksjfd>
"constrain selection to content of next emerging pair of paranthesis
vnoremap n( <esc>:<c-u>execute "normal! /".'\v\('."\rlvi("<cr>
"constrain selection to content of previously emerging pair of paranthesis
vnoremap p( <esc>:<c-u>execute "normal! ?".'\v\)'."\rhvi("<cr>
"constrain selection to content of next emerging pair of braces
vnoremap n{ <esc>:<c-u>execute "normal! /".'\v\{'."\rlvi{"<cr>
"constrain selection to content of previously emerging pair of braces
vnoremap p{ <esc>:<c-u>execute "normal! ?".'\v\}'."\rhvi{"<cr>
"constrain selection to content of next emerging pair of square brackets
vnoremap n[ <esc>:<c-u>execute "normal! /".'\v\['."\rlvi["<cr>
"constrain selection to content of previously emerging pair of square brackets
vnoremap p[ <esc>:<c-u>execute "normal! ?".'\v\]'."\rhvi["<cr>
"constrain selection to content of next emerging pair of angle brackets
vnoremap n< <esc>:<c-u>execute "normal! /".'\v\<'."\rlvi<"<cr>
"constrain selection to content of previously emerging pair of angle brackets
vnoremap p< <esc>:<c-u>execute "normal! ?".'\v\>'."\rhvi<"<cr>
"}}} <alskdjflkasf>
"------------------------------INSERT MODE{{{
"Open completion menuh
"inoremap <expr> <tab> :call openOmni()
inoremap <tab> <c-r>=<SID>OpenOmni()<CR>
"Capitalize word, place cursor behind word, and enter instert mode
inoremap <c-u>  <esc>viwgUea
"Escape sequence
"inoremap jk <esc>
"inoremap <esc> <nop>
"enable the <tab> and shift <tab> to cycle through completion pop up menu
"execture expression pumvisible, when pressing tap
"inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <localleader><tab> <tab>
"}}}
"------------------------------TERMINAL MODE{{{
"terminal mode: escape key --> exit insert mode
tnoremap <Esc> <C-\><C-n>
"}}}
"------------------------------OPERATOR PENDING MODE{{{
if(len(maparg('cp'))!=0)|	"check whether mapping already exists
	unmap cp|		"unmap iron-vims repeat command
endif
onoremap p i(|"inner paranthesis environment
onoremap p( :<c-u>normal! F)hvi(<cr>|	"last paranethesis environment
onoremap n( :<c-u>normal! f(lvi(<cr>|	"next paranthesis environment
onoremap b :<c-u>normal! vi{<cr>|	"inner brace environment
onoremap n{ :<c-u>normal! f{lvi{<cr>|	"next brace environment
onoremap p{ :<c-u>normal! F}hvi{<cr>|	"last brace environment
"}}}
"}}}
"------------------------------AUTOCOMMANDS	{{{
"autocmd BufWinEnter * :write|echom("PVWC\tFile saved.")
"TODO: autocmd BufWinenter *.R "deactivate iron-vim plugin"
"	or alternatively
"	autocmd FileType r "deactivate iron-vim plugin"
"Comment a line specific to its filetype
"------------------------------Filetype html{{{
augroup html
	autocmd!
	"Don't wrap text for html files
	autocmd BufNewFile,BufRead *.html setlocal nowrap
	autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END
"}}}
"------------------------------Filetype python{{{
augroup python
	autocmd!|	"Delete all comands from group first
	autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>
	autocmd FileType python :iabbrev iff if:<left>
	autocmd FileType python :iabbrev fnn def ()<left><left>
	autocmd FileType python setlocal foldmethod=indent
	autocmd FileType python setlocal foldlevelstart=0
augroup END
"}}}
"------------------------------Filetype r{{{
augroup r
	autocmd!
	autocmd FileType r nnoremap <buffer> <localleader>c I#<esc>
	autocmd FileType r :iabbrev iff if()<left>
	autocmd FileType r :call StartR("R")
	autocmd FileType r :iabbrev fnn = function()<left><left><left><left><left><left><left><left><left><left><left><left><left><left>
augroup END
"}}}
"------------------------------Filetype html{{{
augroup markdown
	autocmd!
	autocmd FileType markdown onoremap <buffer> in@ :<c-u>execute "normal! /@\r:nohlsearch\rhviw"<cr>
 	autocmd FileType markdown onoremap <buffer> ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>|	"delete markdown file heading of current section
	autocmd FileType markdown onoremap <buffer> ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_j"<cr>|	"delete around heading
augroup END
"}}}
"------------------------------Filetype vim{{{
augroup vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
	autocmd FileType vim setlocal foldlevelstart=0
	autocmd FileType vim nnoremap <buffer> <localleader>c I"<esc>
augroup END
"}}}
"------------------------------miscellaneous{{{
augroup miscellaneous
	autocmd!
	autocmd Filetype help setlocal number|			"show line numbers for vim documentation files
	autocmd FileType plaintex :setlocal spell spelllang=de|	"check spelling automatically for tex files
	autocmd BufWinEnter * call ResCur()|			"reset cursor position
	autocmd BufWinEnter * execute ":setlocal scrolloff=".&lines/4|	"TODO: &lines is not adequate since it is global
	autocmd BufReadPost * call <SID>setLocalWorkDir()|	"Set working directory local to buffer
augroup END
"}}}
"}}}
"}}}
"================================================== PLugin configuration ===================={{{
"------------------------------NCM CONFIGURATION------------------------------{{{
" IMPORTANT: :help Ncm2PopupOpen for more information
" enable ncm2 for all buffers
"autocmd BufEnter * call ncm2#enable_for_buffer()
"let g:ncm2#auto_popup = 1
"let g:ncm2#is_incomplete=2
"inoremap <Tab> <Plug>(ncm2_manual_trigger)
"set completeopt=noinsert,menuone,noselect
"let g:ncm2#auto_popup=1
"let g:vimtex_compiler_progname = 'nvr'
"}}}
"------------------------------DEOPLETE CONFIGURATION------------------------------{{{
let g:deoplete#enable_at_startup = 1 "enable deoplete auto completion at vim startup
call deoplete#custom#option({
    \ 'ignore_case': 1,
    \ 'camel_case' : 1,
    \ })
"let the vimtex plugin use deoplete as completion engine
"call deoplete#custom#var('omni', 'input_patterns', {
"      \ 'tex': g:vimtex#re#deoplete
"      \})
"}}}
"------------------------------NERDTREE CONFIGURATION------------------------------{{{
"try fc-cache -v -f in terminal to reset font buffer
augroup nerdtree
	autocmd!
	autocmd FileType nerdtree set ignorecase | call Pvwc_c("Ignorecase option set for nerdtree")
	autocmd FileType nerdtree nnoremap <silent> <buffer> t <c-w><c-w>
	"Trigger nerdtree file system browser automatically, when starting vim session
	"autocmd vimenter * NERDTree0
augroup END
set guifont=hack_nerd_font:h11
set encoding=utf-8
"show line numbers per default
let NERDTreeShowLineNumbers = 0
"show hidden files per default
let NERDTreeShowHidden = 1
"nnoremap <localleader>n :NERDTreeToggle<CR>|if &ignorecase\|set noignorecase\|else\|set ignorecase<cr>
nnoremap <localleader>n :NERDTreeCWD<cr>
"nnoremap <localleader>h :call <Plug>NERDTreeMapOpenSplit()<CR>
let g:webdevicons_enable_nerdtree = 1
"}}}
"------------------------------IRON CONFIGURATION------------------------------{{{
"send visually selected code fragment in visual mode
"vnoremap <silent> , <Plug>(iron-visual-send)<Esc><CR>
"nmap <localleader>t    <Plug>(iron-send-motion)
"nmap <localleader>r    <Plug>(iron-repeat-cmd)
"send line in normal mode - TODO: move cursor to next line afterwards
nnoremap <silent> , <Plug>(iron-send-line)<CR>
"nmap <localleader><CR> <Plug>(iron-cr)
"nmap <localleader>i    <plug>(iron-interrupt)
"nmap <localleader>q    <Plug>(iron-exit)
"nmap <localleader>c    <Plug>(iron-clear)
"}}}
"------------------------------NVIM-R CONFIGURATION------------------------------{{{
"Show function arguments
let R_show_args = 1
let R_complete = 2 " Always include names of objects
let R_hi_fun_globenv = 1
let R_show_arg_help = 1
let R_assign = 0
"remap the 'send line' command of Nvim-R plugin"
nmap , <Plug>RDSendLine
"remap the 'Send selection' command of Nvim-R plugin"
vmap , <Plug>RDSendSelection
"remap the 'check code before sending and then send' command of Nvim-R plugin"
"vmap ,c <Plug>RESendSelection
"}}}
"------------------------------ULTISNIPS CONFIGURATION------------------------------{{{
let g:UltiSnipsEditSplit="context"
"dont use <Tab> key to expand snippet
let g:UltiSnipsExpandTrigger = "<nop>"
"let snippet displayed in the completion pop up be expanded by hitting Carriage Return
let g:ulti_expand_or_jump_res = 0
function ExpandSnippetOrCarriageReturn()
    let snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
        return snippet
    else
        return "\<CR>"
    endif
endfunction
inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"
"}}}
"------------------------------JEDI-VIM CONFIGURATION------------------------------{{{
" disable autocompletion, cause we use deoplete for completion
let g:jedi#completions_enabled = 1
" open the go-to function in split, not another buffer
let g:jedi#use_splits_not_buffers = "right"
"}}}
"------------------------------NEOFORMAT CONFIGURATION------------------------------{{{
"use 'styler' formatter for R source files
let g:neoformat_enabled_r = ['styler']
"}}}
"------------------------------NEOMAKE CONFIGURATION------------------------------{{{
"make 'pylint' the linter for python source files
let g:neomake_python_enabled_makers = ['pylint']
"}}}
"------------------------------AIRLINE CONFIGURATION------------------------------{{{
"Automatically displays all buffers when there's only one tab open.
let g:airline#extensions#tabline#enabled = 1
"enable modified detection
let g:airline_detect_modified=1
"}}}
