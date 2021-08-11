"Neovim resource file Philipp van Wickevoort Crommelin.
"Please send bug reports to philippcrommelin@googlemail.com.
"================================================= Plugins{{{
call plug#begin()
Plug 'jalvesaq/Nvim-R'
Plug 'preservim/nerdcommenter'
" Plug 'ycm-core/YouCompleteMe'
" Plug 'ncm2/ncm2'
" Plug 'roxma/nvim-yarp'
" Plug 'gaalcaras/ncm-R'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
" Plug 'ncm2/ncm2-ultisnips'
Plug 'SirVer/ultisnips'
" Plug 'ncm2/ncm2-neosnippet'
Plug 'easymotion/vim-easymotion'
Plug 'dense-analysis/ale'
Plug 'rakr/vim-one'
Plug 'preservim/tagbar'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-gitgutter'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'ivalkeen/nerdtree-execute'
Plug 'dag/vim-fish'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-fugitive'
Plug 'Chiel92/vim-autoformat'
call plug#end()
"}}}
"================================================= Personal configuration {{{
"------------------------------ GLOBAL VARIABLES{{{
"Clipboard, pasteboard, copy and paste, Zwischenablage
"Clipboard interaction Windows and WSL
"It would suffice, to deposit win32yank.exe into the search path
"The unix command line tool win32yank.exe
"is available at https://www.github.com/equalsraf/win32yank/releases
"The following global variable defines a more explicit way
"to control the behaviour of the copy and paste mechanism
" let g:clipboard = {
"			\'name' : 'win32yank-wsl',
"			\'copy' : {
"			\'+' : 'win32yank.exe -i --crlf',
"			\'*' : 'win32yank.exe -i --crlf'
"			\},
"			\'paste' : {
"			\'+' : 'win32yank.exe -o --lf',
"			\'*' : 'win32yank.exe -o --lf'
"			\},
"			\'cache_enabled' : 0
"			\}
"Configuration to use ctags for R with neovim
let g:tagbar_type_r = {
			\ 'ctagstype' : 'r',
			\ 'kinds' : [
				\ 'f:Functions',
				\ 'g:GlobalVariables',
				\ 'v:FunctionVariables',
				\]
				\}
"characters to enclose/surround a word
let s:surroundChar = {
			\'{':'}',
			\'[':']',
			\'(':')',
			\'$':'$',
			\'/':'/',
			\'\\':'\\',
			\'<':'>',
			\"'":"'",
			\'"':'"',
			\' ':' '
			\}
"comment character for different programming languages
let s:CommentChar = {
			\'python':'#',
			\'perl':'#',
			\'r':'#',
			\'sh':'#',
			\'fish':'#',
			\'vim':'"',
			\'sql':'--',
			\'tex':'%',
			\'c':'//',
			\'json':'//'
			\}
let g:SPELL_LANG = "en_us"|	"global spelling language
let s:verbose = 0|	"Global indicator variable for more verbose output
let g:VIMRC_DIR="/home/philipp/Developer/Vimscript/init.vim/"

let g:mapleader = '\'|			"Set the leader key to the hyphen character
let g:maplocalleader = '-'|		"Map the localleader key to a backslash
let g:trlWspPattern = '\v\s+$'|		"Search pattern for trailing whitespace
"}}}
"------------------------------ NEOVIM PROVIDER {{{
" let g:python3_host_prog="/opt/python-3.9.5/bin/python3.9"
" let g:python_host_prog="/usr/bin/python2"

" let g:ruby_version=get(systemlist("ls -l $HOME/.gem/ruby/ | tail -n +2 | rev | awk '{print $1}' | rev | sort -r | head -n 1"),0)
" perhaps it is necessary to perform a user installation with gem according to
" gem install --user neovim
" let g:ruby_host_prog=$HOME."/.gem/ruby/".g:ruby_version."/bin/neovim-ruby-host"
" let g:node_host_prog="/usr/local/lib/node_modules/neovim/bin/cli.js"
" }}}
"------------------------------ FUNCTIONS{{{
"TODO: Function that changes a word globally
"TODO: create formatter for r function arguments
"------------------------------ PlugLoaded{{{
"Check wether plugin is currently loaded
"see
"https://vi.stackexchange.com/questions/10939/how-to-see-if-a-plugin-is-active
function! PlugLoaded(name)
	return (
				\ has_key(g:plugs, a:name) &&
				\ isdirectory(g:plugs[a:name].dir) &&
				\ stridx(&rtp, g:plugs[a:name].dir) >= 0)
endfunction
"}}}
"------------------------------ RemoveSwapFile{{{
"Delete the current swap file
function! s:RemoveSwapFile()
	execute ":!rm ".swapname(bufname())
endfunction
"}}}
"------------------------------ DeleteLine{{{
function! s:DeleteLine()
	call setline(".",'')
	startinsert!
endfunction
"}}}
"------------------------------ OpenTagInNewSplit{{{
function! s:OpenTagInNewSplit(myTag)
	" Todo: quit if a tag does not exist
	execute ":ptag ".a:myTag
endfunction
"}}}
"------------------------------ ChangeSurroundingChar{{{
"change surrounding character
function! s:ChangeSurroundingChar(char)
	let s:p = [line("."),col(".")]
	echo s:p
	let s:savedReg = @"
	let s:word = expand("<cword>")
	execute "normal! byh"
	let s:oldDelimiter = @"
	let s:col_l = col(".")
	let s:cl = getline(".")
	let s:leftHandSide = strcharpart(s:cl,0,s:col_l-1)
	execute "normal! el"
	let s:col_r = col(".")
	let s:rightHandSide = strcharpart(s:cl,s:col_r,len(s:cl))
	call setline(line("."),s:leftHandSide.a:char.s:word.get(s:surroundChar,a:char,'#').s:rightHandSide)
	let @" = s:savedReg
	call cursor(s:p)
endfunction
"}}}
"------------------------------ Surround{{{
"Surround by character
"TODO: Bug identified: Surround visually selected area with leading equal sign
"on the left hand side: Equal sign is moved to the right of surrounded area.
"
function! s:Surround(char)
	let s:p = [line("."),col(".")+1]
	execute "normal! bi".a:char."\<esc>ea".get(s:surroundChar,a:char,'#')."\<esc>"
	call cursor(s:p)
endfunction
"}}}
"------------------------------ CommentLines{{{
"Function to comment "lines" according to filetype/programming language used
function! s:CommentLines()
	let c = get(s:CommentChar,&filetype,'?')
	let cl = getline('.')
	if match(cl,c) >= 0 && match(cl,c) <= 1|	"Comment sign was identified
		call setline('.',substitute(cl,'\v^'.escape(c,'%?').' (.*$)','\1',""))
	else
		"Comment sign has not been identified
		call setline('.',c.' '.cl)
	endif
endfunction
"}}}
"------------------------------ OpenOrRefreshNerdTree{{{
"Open the NERDTree if it is not visible, or refresh its working directory
"otherwise
function! s:OpenOrRefreshNerdTree()
	NERDTreeToggle
	NERDTreeRefreshRoot
endfunction
"}}}
"------------------------------ setLocalWorkDir{{{
"set local working directory
function! s:setLocalWorkDir()
	echom &buftype
	if len(&buftype) == 0	"normal buffer has empty option &buftype (see :help buftype)
		execute ":lcd " . expand("%:p:h")
	endif
endfunction
"}}}
"------------------------------ FormatAndFeedToRepl{{{
"Format and Feed to Read-Eval-Print-Loop
"This function is for Users of the statistical programming language R, that use
"the plugin Nvim-R. When the cursor is positioned within a function block and
"FormatAndFeedToRepl is called the function arguments are parsed into the REPL
"(== the R language console). As a consequence, they are loaded into the
"global namespace.
"This function is handy, if the inner code block of an R function is to be
"tested, but the function arguments are not known whithin the namespace
"outside the function
function! s:FormatAndFeedToRepl()
	let cursPos = getcurpos()
	let save_reg = @"
	execute "normal! ?function\r"
	execute "normal! /(\ryi("
	let funcArgsRaw = substitute(@",'\v[ \t\n]','','g')|	"remove newline and space characters
	let fArgs = []
	let n = 0
	let l = len(funcArgsRaw)
	let c = 0
	let p = 0
	while l > 0
		let p = match(funcArgsRaw,'(')|	"look for a function argument (starts with an opening paranthesis), that is a call for an R function
		if p >= 0
			let c = match(funcArgsRaw,',')|	"Identify position of a comma
			if c >= 0|	"A comma was found
				if( c < p )
					if(c!=0)
						call extend(fArgs,[strcharpart(funcArgsRaw,0,c)])
						let funcArgsRaw = strcharpart(funcArgsRaw,c+1,l)|	"+1 to skip ,
						let l = len(funcArgsRaw)
					else|	"remove leading comma
						let funcArgsRaw = strcharpart(funcArgsRaw,1,l)
						let l = len(l)
					endif
				else
					let pc = match(funcArgsRaw,')')
					let functionCallArg = strcharpart(funcArgsRaw,0,pc+1)
					let funcArgsRaw = strcharpart(funcArgsRaw,pc+1,l)|	"+1 to skip )
					let l = len(funcArgsRaw)
					let numNested = len(substitute(functionCallArg,'\v[^\(]','','g'))|	"count left paranethesis
					while numNested > 1|	"enter nested function argument
						let np = match(funcArgsRaw,')')
						let functionCallArg .= strcharpart(funcArgsRaw,0,np+1)
						let funcArgsRaw = strcharpart(funcArgsRaw,np+1,l)
						let l = len(funcArgsRaw)
						let numNested -= 1
					endwhile
					call extend(fArgs,[functionCallArg])
				endif
			else|	"No comma found -- Only one single argument left to be parsed
				let fArgs = extend(fArgs,[funcArgsRaw])
				let l = 0|	"exit loop
			endif
		else|	"no functions called among function arguments
			let fArgs = split(funcArgsRaw,',')
			let l = 0|	"exit loop
		endif
	endwhile
	call SendCmdToR_Buffer(join(fArgs,"\n"))
	let @" = save_reg
	call setpos('.',cursPos)
endfunction
"}}}
"------------------------------ OpenOmni{{{
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
		call <SID>Cmt("wordUntilCursor = ".g:wordUntilCursor)
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
"}}}
"------------------------------ SpellCheckToggle{{{
"Toggle spell check
function! s:SpellCheckToggle()
	if &spell
		set nospell
	else
		execute "set spell spelllang=".g:SPELL_LANG
	endif
endfunction
"}}}
"------------------------------ QuickFixToggle{{{
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
"}}}
"------------------------------ FoldColumnToggle{{{
"Function to toggle the foldcolumn
function! s:FoldColumnToggle()
	if &foldcolumn
		setlocal foldcolumn=0
	else
		setlocal foldcolumn=4
	endif
endfunction
"}}}
"------------------------------ CheckBuf{{{
"Helper function to check, whether a given buffer is listed and within contained
"within g:bufNumbrs
function! s:CheckBuf(bufNr)
	function! Local_addBuf(_bufNr)
		let g:numOfBufs += 1
		let g:bufNumbrs += [a:_bufNr]
		let g:tabBufNames += [bufname(a:_bufNr)]
		call <SID>Cmt("Buffer nr. ".a:_bufNr." with name ".bufname(a:_bufNr)." will be added")
	endfunction
	function! Local_rmBuf(_bufNr)
		let bufNumbrsInd = index(g:bufNumbrs,a:_bufNr)
		let tabBufNamesInd = index(g:tabBufNames,bufname(a:_bufNr))
		call <SID>Cmt("Buffer nr. ".a:_bufNr." with name ".bufname(a:_bufNr)." will be removed")
		call remove(g:bufNumbrs,bufNumbrsInd)
		call remove(g:tabBufNames,tabBufNamesInd)
	endfunction
	if buflisted(a:bufNr) && index(g:bufNumbrs,a:bufNr)<0
		call Local_addBuf(a:bufNr)
	else
		call <SID>Cmt("Buffer nr. ".a:bufNr." with name ".bufname(a:bufNr)." will be ignored")
	endif
endfunction
"}}}
"------------------------------ BufferCycle{{{
"Open a new window and cycle through all listed buffers (A)
function! s:BufferCycle(direction)
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
			call <SID>CheckBuf(bufNr)
		endfor
		call Local_cycleIndex(a:direction)
		call Local_openNewWindow()
		augroup startBufferCyclerAutomation
			autocmd!
			autocmd BufReadPost * call <SID>CheckBuf(bufnr())
			"autocmd BufWinEnter * execute "if index(g:bufNumbrs,bufnr())<0"."\n"."call <SID>CheckBuf(bufnr())"."\n"."echom \"Buffer checked\""."\n"."else"."\n"."echom \"Buffer already checked\""."\n"."endif"."\n"
			"autocmd BufWinEnter * execute "if index(g:bufNumbrs,bufnr())>0"."\n"."call <SID>CheckBuf(bufnr())"."\n"."echom \"Buffer checked\""."\n"."else"."\n"."echom \"Buffer already checked\""."\n"."endif"."\n"
		augroup end
	endif
endfunction
"}}}
"------------------------------ HlTrlWsp{{{
"Function that toggles highlighting trailing white-space characters
function! s:HlTrlWsp()
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
"}}}
"------------------------------ Cmt{{{
"Print a comment if boolean script variable s:verbose is set
function! s:Cmt(comment)
	if s:verbose
		echo a:comment
	endif
endfunction
"}}}
"------------------------------ GoToWinAndRefreshNerdtree{{{
"Go to a window with given window number and reload current working dir of
"NERDTree
function! s:GoToWinAndRefreshNerdtree(winNumber)
	call win_gotoid(win_getid(a:winNumber))
	if (&buftype==#'' && g:NERDTree.IsOpen()) "empty buftype option corresponds to normal buffer (see help buftype)
		"variable g:NERDTree.IsOpen may be invalid after updating NERDTree
		"NERDTreeCWD| "No need to set NERDTree working directory since
		"working directory is no more set to directory of
		"currently loaded file in buffer in autocomd
		"BufReadPost
		call win_gotoid(win_getid(a:winNumber))
	endif
endfunction
"}}}
"------------------------------ GoToNeighbourWin{{{
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
"}}}
"------------------------------ ToggleSyntax{{{
"Toggle syntax coloring
function! s:ToggleSyntax()
	if(exists("g:syntax_on"))
		syntax off
	else
		syntax enable
	endif
endfunction
"}}}
"------------------------------ GR{{{
function GR(replacementString)
	%s/{expand("<cword>")}/{a:replacementString}/gc
endfunction
"}}}
"------------------------------ RangeSearch{{{
"Perform search with "/" within visually selected range
function! s:RangeSearch(direction)
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
"}}}
"------------------------------ ResCur{{{
"Reset cursor position
function! s:ResCur()
	try
		if line("'\"") <= line("$")
			normal! g`"
			return 1
		endif
	endtry
endfunction
"}}}
"------------------------------ MaxCurWin{{{
"Maximize current window
function! s:MaxCurWin()
	let g:cursorPosition = getcurpos()
	"let g:cursorRow = g:cp[1]
	"let g:cursorCol = g:cp[4]
	if !exists("g:minMaxPairs")
		let g:minMaxPairs = {}
		let g:maxMinPairs = {}
	endif
	let g:minWinID = win_getid()
	let g:minBn = bufname(bufnr())
	call <SID>Cmt("Pvwc: Current window ID = ".g:minWinID."\tbuffer name\t".g:minBn)
	let g:maxWinID = get(g:minMaxPairs,g:minWinID,0)
	function! NewTab()
		execute ":tabedit ".g:minBn
		let g:maxWinID = win_getid()
		call extend(g:minMaxPairs,{g:minWinID:g:maxWinID})
		call extend(g:maxMinPairs,{g:maxWinID:g:minWinID})
		call setpos(".",g:cursorPosition)
		setlocal foldcolumn=0
	endfunction
	if g:maxWinID!=#0 && !empty(getwininfo(g:maxWinID))
		call <SID>Cmt("Max window does already exist. MaxWinID is\t".g:maxWinID)
		call win_gotoid(g:maxWinID)
		call setpos(".",g:cursorPosition)
	elseif g:maxWinID!=#0 && empty(getwininfo(g:maxWinID))
		call <SID>Cmt("remove invalid entries")
		call remove(g:minMaxPairs,g:minWinID)
		call remove(g:maxMinPairs,g:maxWinID)
		call NewTab()
	else
		call <SID>Cmt("Max window does not exist")
		call NewTab()
	endif
endfunction
"}}}
"------------------------------ MinCurWin{{{
"Minimize current window (Close tab and return to minimized Window)
function! s:MinCurWin()
	if exists("g:maxMinPairs")
		let g:maxWinID = win_getid()
		let g:minWinID = get(g:maxMinPairs,g:maxWinID,0)
		if g:minWinID==#0
			call <SID>Cmt("There is not minimized window that belongs to the current window. Nothing done")
		else
			call <SID>Cmt("Close maximized window and go to minimized version")
			let g:cursorPosition = getcurpos()
			execute ":tabclose"
			call win_gotoid(g:minWinID)
			call setpos(".",g:cursorPosition)
			call remove(g:maxMinPairs,g:maxWinID)
			call remove(g:minMaxPairs,g:minWinID)
		endif
	endif
endfunction
"}}}
"}}}
"------------------------------ SETTINGS{{{
"TODO:command that repeats last command
"set path to current directory ( Corresponds to output of :pwd or :echo getcwd() )
" define the currently edited file to have linefeed lineendings
" set fileformat=unix
set path=**
command! Tex :w|:!pdflatex -shell-escape %
command! RemoveSwap :call <SID>RemoveSwapFile()<cr>
command! TaggeR :!tag.R
" set nocompatible| "Required by the vim-polyglot plugin
set omnifunc=syntaxcomplete#Complete
set foldcolumn=4|
set ignorecase|		"Ignore case for vim search function / or ?
set hlsearch incsearch|	"highlight all matching search patterns while typing
set splitright|		"make new vertical splits appear to the right
set splitbelow|		"make new horizontal splits appear below
"consider command <<aboveleft>> for vertical/horizontal splits to open to the left/top of the
"current active window
" set wrap|		"let lines break, if their lengths exceed the window size
"Enable mouse for all modes (visual, insert, command-line mode, etc.)
set mouse=a
"Zwischenablage, clipboard, pasteboard, copy and paste
"Es reicht einfach das Hinterlegen des Unix-Programms
"win32yank.exe
"Dieses ist unter https://www.github.com/equalsraf/win32yank/releases
"herunterzuladen
set foldmethod=marker
" set shiftround|		"round value for indentation to multiple of shiftwidth
set number
" set laststatus=2
" set expandtab
" set shiftwidth=2
" set softtabstop=2
set autoindent
set smartindent
" don't resize other windows, when splitting a window
set noequalalways
filetype plugin on
"}}}
"------------------------------ ABBREVIATIONS{{{
iabbrev 'van\ W' van Wickevoort Crommelin
iabbrev ppp Philipp van Wickevoort Crommelin
iabbrev ~  ~<space>|    " Replace NON-BRAKE-SPACE character (Hex-Code c2a0)
" with regular space character (Hex-code a0)
"}}}
"------------------------------ MAPPINGS{{{
"------------------------------ GLOBAL{{{
"move cursor just before found character
" noremap f t
"move cursor just after found character
" noremap F T
" noremap <silent> t :call <SID>BufferCycle("up")<cr>
" noremap <silent> <s-T> :call <SID>BufferCycle("down")<cr>
"}}}
"------------------------------ NORMAL MODE{{{
"jump to tag - Don't forget to create a tag file with ctags, like
"ctags myDirectoryWithRFiles --exclude renv
"and import it in
"neovim with the command 'set tags+=/path/to/tags'
"For R language support of ctags create a .ctags file in the $HOME
"directory and fill it with:
" --langdef=R
" --langmap=r:.R.r
" --regex-R=/^[ \t]*"?([.A-Za-z][.A-Za-z0-9_]*)"?[ \t]*<-[ \t]function/\1/f,Functions/
" --regex-R=/^"?([.A-Za-z][.A-Za-z0-9_]*)"?[ \t]*<-[ \t][^f][^u][^n][^c][^t][^i][^o][^n]/\1/g,GlobalVars/
" --regex-R=/[ \t]"?([.A-Za-z][.A-Za-z0-9_]*)"?[ \t]*<-[ \t][^f][^u][^n][^c][^t][^i][^o][^n]/\1/v,FunctionVariables/
"  install module tagbar
"  and insert into init.vim the following global dictionary:
" let g:tagbar_type_r = {
"       \ 'ctagstype' : 'r',
"       \ 'kinds' : [
"       \ 'f:Functions',
"       \ 'g:GlobalVariables',
"       \ 'v:FunctionVariables',
"       \]
"       \}
"
"Jump to Tag directly
nnoremap <silent> g] :execute 'ptjump '.expand("<cword>")<cr>
nnoremap <silent> <localleader>g] :execute 'tjump '.expand("<cword>")<cr>
" nnoremap <silent> <localleader>F :execute "tag ".expand("<cword>")<cr>
nnoremap <silent> <localleader>F :call <SID>OpenTagInNewSplit(expand("<cword>"))<cr>
"Surround word by given character
nnoremap <silent> <localleader>e{ :call <SID>Surround('{')<cr>
nnoremap <silent> <localleader>e[ :call <SID>Surround('[')<cr>
nnoremap <silent> <localleader>e( :call <SID>Surround('(')<cr>
nnoremap <silent> <localleader>e$ :call <SID>Surround('$')<cr>
nnoremap <silent> <localleader>e/ :call <SID>Surround('/')<cr>
nnoremap <silent> <localleader>e\ :call <SID>Surround('\\')<cr>
nnoremap <silent> <localleader>e< :call <SID>Surround('<')<cr>
nnoremap <silent> <localleader>e' :call <SID>Surround("'")<cr>
nnoremap <silent> <localleader>e" :call <SID>Surround('"')<cr>
nnoremap <silent> <localleader>es :call <SID>Surround(' ')<cr>

"Change surrounding character
nnoremap <silent> ce{ :call <SID>ChangeSurroundingChar('{')<cr>
nnoremap <silent> ce[ :call <SID>ChangeSurroundingChar('[')<cr>
nnoremap <silent> ce( :call <SID>ChangeSurroundingChar('(')<cr>
nnoremap <silent> ce$ :call <SID>ChangeSurroundingChar('$')<cr>
nnoremap <silent> ce/ :call <SID>ChangeSurroundingChar('/')<cr>
nnoremap <silent> ce\ :call <SID>ChangeSurroundingChar('\\')<cr>
nnoremap <silent> ce< :call <SID>ChangeSurroundingChar('<')<cr>
nnoremap <silent> ce' :call <SID>ChangeSurroundingChar("'")<cr>
nnoremap <silent> ce" :call <SID>ChangeSurroundingChar('"')<cr>
nnoremap <silent> ces :call <SID>ChangeSurroundingChar(' ')<cr>
"Reindent entire file
nnoremap <silent> <localleader>i mqgg=G`q<cr>
"Read local scope R function arguments and send to R-REPL
nnoremap <silent> <localleader>u :UltiSnipsEdit<cr>
"Read local scope R function arguments and send to R-REPL
nnoremap <silent> <localleader>p :call <SID>FormatAndFeedToRepl()<cr>
"Comment the line of the cursor
"nnoremap <silent> <localleader>c :call <SID>CommentLines()<cr>
nnoremap <localleader>c :call NERDComment('n','sexy')<cr>
"toggle number option
nnoremap <silent> <localleader>N :setlocal number!<cr>
"toggle spell control
nnoremap <silent> <localleader>s :call <SID>SpellCheckToggle()<cr>
"Enter insert mode automatically after Deletion from cursor to EOL character
nnoremap <silent> D Da
"toggle quickfix window
nnoremap <localleader>q :call <SID>QuickFixToggle()<cr>
"navigate within the quickfix-window
nnoremap <silent> ä :cprevious<cr>
nnoremap <silent> ü :cnext<cr>
"Cycle through all listed buffers
" nnoremap <localleader>f :call <SID>FoldColumnToggle()<cr>
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
" nnoremap <silent> <localleader>w :call <SID>HlTrlWsp()<cr>
"Delete all trailing white space charactes before end-of-line character
" nnoremap <silent> <localleader>W :execute "normal! mq:%s/".trlWspPattern."//g\r:nohl\r`q"<cr>
"Write and close all windows in all tabs und quit vim
nnoremap <localleader>Z :execute ":wall \| :qall"<CR>
"maximize window
"nnoremap <localleader>M :tabedit %<cr>
nnoremap <silent> <localleader>M :call <SID>MaxCurWin()<cr>
"minimize window
nnoremap <silent> <localleader>m :call <SID>MinCurWin()<cr>
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
"Edit R function collection
nnoremap <silent> <localleader>er :execute ":split ".g:RFUNS."\|:lcd ".g:RFUNS_DIR<cr>
"Edit vimrc file
nnoremap <silent> <localleader>ev :execute ":split ".$MYVIMRC<cr>
"source (aka. "reload") vimrc file
nnoremap <localleader>r :source $MYVIMRC<CR>
"open terminal emulator. For automatic switch to insert mode (aka terminal mode)
"define autocomand according to autocomd termOpen * :startinsert
nnoremap <silent> <localleader>C :execute ":split\|:terminal"<cr>
"select word with space key
nnoremap <space> viw
"clear current line
nnoremap <silent> <localleader>d :call <sid>DeleteLine()<cr>
"}}}
"------------------------------ VISUAL MODE{{{
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
vnoremap <localleader>e" <esc>`<i"<esc>`>la"<esc>
"Indent with tab
vnoremap <silent> <tab> >
"Unindent with tab
vnoremap <silent> <s-tab> <
"comment visually selected lines
vnoremap <silent> <localleader>c :call <SID>CommentLines()<cr>
"go to the last printable character of current line (skip newline char)
vnoremap $ g_
"Search constrained to visually selected range.
vnoremap <silent> / :<C-U>call <SID>RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|execute '/'.g:srchstr\|endif<CR>
"Backward search constrained to visually selected range
vnoremap <silent> ? :<C-U>call <SID>RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|execute '?'.g:srchstr\|endif<CR> <lsflaksjfd>
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
"------------------------------ INSERT MODE{{{
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
"expand R pipe
inoremap <<CR> %>%<CR>
"}}}
"------------------------------ TERMINAL MODE{{{
"terminal mode: escape key --> exit insert mode
tnoremap <Esc> <C-\><C-n>
"}}}
"------------------------------ OPERATOR PENDING MODE{{{
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
"------------------------------ AUTOCOMMANDS{{{
"------------------------------ Filetype html{{{
augroup html
	autocmd!
	"Don't wrap text for html files
	autocmd BufNewFile,BufRead *.html setlocal nowrap
	autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup end
"}}}
"------------------------------ Filetype python{{{
augroup python
	autocmd!|	"Delete all comands from group first
	autocmd FileType python setlocal foldmethod=indent
	autocmd FileType python setlocal foldlevelstart=0
augroup end
"}}}
"------------------------------ Filetype r{{{
augroup r
	autocmd!
	autocmd Filetype r :setlocal colorcolumn=80|                    "Display a coloured vertical bar
	autocmd Filetype r :nnoremap <buffer> = :execute "!styler ".expand("%")<cr>
	autocmd Filetype r :nnoremap <buffer> <localleader>rt :TaggeR<cr>
	if match(&runtimepath,'Nvim-R') != -1
		autocmd Filetype r :nmap <buffer> , <Plug>RDSendLine
		"	autocmd Filetype r :remap the 'Send selection' command of Nvim-R plugin"
		autocmd Filetype r :vmap <buffer> , <Plug>RDSendSelection
		"	autocmd Filetype r :remap the 'check code before sending and then send' command of Nvim-R plugin"
		"	autocmd Filetype r :vmap ,c <Plug>RESendSelection
		autocmd Filetype r :nmap <buffer> <localleader>rw :call g:SendCmdToR("getwd()")<CR>
		autocmd Filetype r :nmap <buffer> <localleader>rs :call RAction("str")<CR>
		autocmd Filetype r :nmap <buffer> <localleader>rC :call RAction("class")<CR>
" 		autocmd Filetype r :nmap <buffer> <localleader>ri <Plug>RStop
		autocmd Filetype r :nmap <localleader>ri :RStop<CR>
		autocmd Filetype r :nmap <localleader>rh <Plug>RHelp
		autocmd Filetype r :nmap <buffer> <localleader>rH :execute ':call g:SendCmdToR("help(,'.expand("<cword>").')")'<CR>
		autocmd Filetype r :nmap <buffer> <localleader>rg :execute ':call g:SendCmdToR("tibble::glimpse('.expand("<cword>").')")'<CR>
		autocmd Filetype r :nmap <buffer> <localleader>rL :execute ':call g:SendCmdToR("length('.expand("<cword>").')")'<CR>
		autocmd Filetype r :nmap <localleader>rl :execute ':call g:SendCmdToR("library('.expand("<cword>").')")'<CR>
		autocmd Filetype r :nmap <localleader>rk :call g:SendCmdToR("quit(save='no')")<CR>
		autocmd Filetype r :nmap <localleader>rq :call g:SendCmdToR("Q")<CR>
		autocmd Filetype r :nmap <localleader>rn :call g:SendCmdToR("n")<CR>
		autocmd Filetype r :nmap <localleader>rc :call g:SendCmdToR("c")<CR>
		autocmd Filetype r :nmap <localleader>rf :call StartR("R")<CR>
		autocmd Filetype r :nmap <buffer> <localleader>aa <Plug>RSendFile
	endif
augroup end
"}}}
"------------------------------ Filetype markdown{{{
augroup markdown
	autocmd!
	autocmd FileType markdown onoremap <buffer> in@ :<c-u>execute "normal! /@\r:nohlsearch\rhviw"<cr>
	autocmd FileType markdown onoremap <buffer> ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>|	"delete markdown file heading of current section
	autocmd FileType markdown onoremap <buffer> ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_j"<cr>|	"delete around heading
augroup end
"}}}
"------------------------------ Filetype perl{{{
augroup perl
	autocmd!
	autocmd FileType perl :iabbrev '/' //<left>|"Create matching slash in regular expression environments
augroup end
"}}}
"------------------------------ Filetype vim{{{
augroup vim
	autocmd!
	autocmd FileType vim setlocal foldlevelstart=0
augroup end
"}}}
"------------------------------ Filetype sh{{{
augroup sh
	autocmd!
	autocmd FileType sh setlocal textwidth=200
augroup end
"}}}
"------------------------------ Filetype snippets{{{
augroup snippets
	autocmd!
augroup end
"}}}
"------------------------------ miscellaneous{{{
augroup miscellaneous
	autocmd!
	autocmd termOpen * :startinsert| "Automatically start terminal mode
	"	autocmd vimenter * :NERDTree|           "Display Nerdtree after vim startup
	autocmd Filetype help :setlocal number|	"show line numbers for vim documentation files
	autocmd BufWinEnter * :call <SID>ResCur()|				  "reset cursor position
	"	autocmd BufWinEnter * :execute ":setlocal scrolloff=".&lines/4|	"TODO: &lines is not adequate since it is global
augroup end
"}}}
"}}}
"}}}
"================================================= PLugin configuration{{{
"------------------------------ DEOPLETE{{{
if match(&runtimepath,'deoplete') != -1
	 let g:deoplete#enable_at_startup = 1 "enable deoplete auto completion at vim startup
	 call deoplete#custom#option({
	     \ 'ignore_case': 1,
	     \ 'camel_case' : 1,
	     \ })
" 	let the vimtex plugin use deoplete as completion engine
" 	call deoplete#custom#var('omni', 'input_patterns', {
" 	      \ 'tex': g:vimtex#re#deoplete
" 	      \})
endif
"}}}
"------------------------------ NERDCOMMENTER{{{
if match(&runtimepath,'nerdcommenter') != -1
" Create default mappings
let g:NERDCreateDefaultMappings = 1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Add your own custom formats or override the defaults
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1
endif
"}}}
"------------------------------ NERDTREE{{{
if match(&runtimepath,'nerdtree') != -1
	"try fc-cache -v -f in terminal to reset font buffer
	augroup nerdtree
		autocmd!
		autocmd FileType nerdtree set ignorecase | call <SID>Cmt("Ignorecase option set for nerdtree")
		"		autocmd FileType nerdtree nnoremap <silent> <buffer> t <c-w><c-w>
		"Trigger nerdtree file system browser automatically, when starting vim session
		"autocmd vimenter * NERDTree0
	augroup end
	set encoding=utf-8
	set guifont=hack_nerd_font:h11
	"show line numbers per default
	let NERDTreeShowLineNumbers = 1
	"show hidden files per default
	let NERDTreeShowHidden = 1
	nnoremap <localleader>n :call <SID>OpenOrRefreshNerdTree()<cr>
	"nnoremap <localleader>h :call <Plug>NERDTreeMapOpenSplit()<CR>
	let g:webdevicons_enable_nerdtree = 1
endif
"}}}
"------------------------------ NVIM-R{{{
if match(&runtimepath,'Nvim-R') != -1
	let R_auto_start = 1
	" Set R's current working directory to
	" neovim's current working directory
	" (and not to the directory of the R file
	" being opened, i.e. the default behaviour)
	let R_nvim_wd = 1
	"Disable all Nvim-R key maps (Each Nvim-R key map has to be configured manually
	"then)
	let R_user_maps_only = 1
	"Show function arguments
	" let R_show_args = 1 NOTE: Deprecated with nvimcom 0.9-113
	" let R_complete = 2 " Always include names of objects NOTE: Deprecated with nvimcom 0.9-113
	let R_hi_fun = 1 " Activated by Default: Highlight R functions that are
	" loaded into the global environment
	let R_hi_fun_paren = 1  " Highlight R functions only if followed by a (
	" let R_hi_fun_globenv = 0
	" let Rout_more_colors = 1
	let R_show_arg_help = 1
	let R_assign = 0
	"remap the 'send line' command of Nvim-R plugin"
endif
"}}}
"------------------------------ NCM2{{{
if match(&runtimepath,'ncm2') != -1
	" enable ncm2 for all buffers
	"	autocmd BufEnter * call ncm2#enable_for_buffer()

	" IMPORTANT: :help Ncm2PopupOpen for more information
	"	set completeopt=noinsert,menuone,noselect

	" NOTE: you need to install completion sources to get completions. Check
	" our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
endif
"}}}
"------------------------------ ULTISNIPS{{{
if match(&runtimepath,'ultisnips') != -1
	let g:UltiSnipsEditSplit="context"
	"dont use <Tab> key to expand snippet
	let g:UltiSnipsExpandTrigger = "<localleader><cr>"
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
endif
"}}}
"------------------------------ VIM-AIRLINE{{{
"Automatically displays all buffers when there's only one tab open.
if match(&runtimepath,'vim-airline') != -1
	let g:airline#extensions#tabline#enabled = 1
	"enable modified detection
	let g:airline_detect_modified=1
endif
"}}}
"------------------------------ FUGITIVE{{{
if match(&runtimepath,'fugitive') != -1
	"Git add file that corresponds to current buffer
	nnoremap <silent> <localleader>ga :Git add %<cr>
	"Git rebase --continue
	nnoremap <silent> <localleader>grc :Git rebase --continue<cr>
endif
"}}}
"------------------------------ VIM-ONE{{{
if match(&runtimepath,'vim-one') != -1
	"Credit joshdick
	"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
	"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
	"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
	" if (empty($TMUX))
	"   if (has("nvim"))
	"For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
	"     let $NVIM_TUI_ENABLE_TRUE_COLOR=1
	"   endif
	"   "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
	"   "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
	"   " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
	"   if (has("termguicolors"))
	"     set termguicolors
	"   endif
	" endif

" 	if (has("termguicolors"))
		set background=dark " for the dark version
		set termguicolors
" 	endif
" 	if (&termguicolors == 1)
" 	      set notermguicolors
" 	      set background=light " for the dark version
" 	endif
	colorscheme one
	set t_8b=^[[48;2;%lu;%lu;%lum
	set t_8f=^[[38;2;%lu;%lu;%lum
endif
"}}}
"------------------------------ VIM-EASYMOTION{{{
if match(&runtimepath,'vim-easymotion') != -1
	" <Leader>f{char} to move to {char}
	map  <localleader>f <Plug>(easymotion-bd-f)
	nmap <localleader>f <Plug>(easymotion-overwin-f)

	" s{char}{char} to move to {char}{char}
	" nmap s <Plug>(easymotion-overwin-f2)

	" Move to line
	" map <Leader>L <Plug>(easymotion-bd-jk)
	" nmap <Leader>L <Plug>(easymotion-overwin-line)

	" Move to word
	map  <localleader>w <Plug>(easymotion-bd-w)
	nmap <localleader>w <Plug>(easymotion-overwin-w)
endif
"}}}
"------------------------------ ALE{{{
if match(&runtimepath,'ale') != -1
	" default 0
	" let g:ale_r_lintr_lint_package = 0
	let g:ale_r_lintr_options = '
				\with_defaults(
				\    default = NULL,
				\    T_and_F_symbol_linter = lintr::T_and_F_symbol_linter,
				\    assignment_linter = lintr::assignment_linter,
				\    closed_curly_linter = lintr::closed_curly_linter(allow_single_line = FALSE),
				\    commas_linter = lintr::commas_linter,
				\    commented_code_linter = lintr::commented_code_linter,
				\    complexity_limit = lintr::cyclocomp_linter(complexity_limit = 25),
				\    object_name_linter = lintr::object_name_linter(styles = "snake_case"),
				\    object_length_linter = lintr::object_length_linter(length = 30L),
				\    equals_na_linter = lintr::equals_na_linter,
				\    function_left_parentheses_linter = lintr::function_left_parentheses_linter,
				\    infix_spaces_linter = lintr::infix_spaces_linter,
				\    no_tab_linter = lintr::no_tab_linter,
				\    object_usage_linter = lintr::object_usage_linter,
				\    open_curly_linter = lintr::open_curly_linter(allow_single_line = FALSE),
				\    paren_brace_linter = lintr::paren_brace_linter,
				\    absolute_path_linter = lintr::absolute_path_linter(lax = TRUE),
				\    nonportable_path_linter = lintr::nonportable_path_linter(lax = TRUE),
				\    pipe_continuation_linter = lintr::pipe_continuation_linter,
				\    semicolon_terminator_linter = lintr::semicolon_terminator_linter(semicolon = c("compound", "trailing")),
				\    seq_linter = lintr::seq_linter,
				\    single_quotes_linter = lintr::single_quotes_linter,
				\    spaces_inside_linter = lintr::spaces_inside_linter,
				\    spaces_left_parentheses_linter = lintr::spaces_left_parentheses_linter,
				\    undesirable_function_linter = lintr::undesirable_function_linter(fun = c(lintr::default_undesirable_functions)),
				\    undesirable_operator_linter = lintr::undesirable_operator_linter(op = list(`<<-` = NA, `->>`= NA)),
				\    unneeded_concatenation_linter = lintr::unneeded_concatenation_linter
				\  )
				\'
endif
"}}}
"------------------------------ VIM-GITGUTTER{{{
if match(&runtimepath,'git-gutter') != -1
	set updatetime=100
endif
"}}}
"}}}
"================================================= Usefull help pages{{{
"show info about displayed non-printable characters
":help digraph-table
"}}}
