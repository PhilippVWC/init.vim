"Neovim resource file from Philipp van Wickevoort Crommelin.
"Please send bug reports to philippcrommelin@googlemail.com.
"================================================= PLUGINS ==================================={{{
call plug#begin()
" Plug 'ncm2/ncm2'
" Plug 'roxma/nvim-yarp'
Plug 'jalvesaq/Nvim-R'
Plug 'preservim/tagbar'
Plug 'sheerun/vim-polyglot'
" Plug 'brooth/far.vim'
" Plug 'gaalcaras/ncm-R'
" Plug 'ncm2/ncm2-bufword'
" Plug 'ncm2/ncm2-path'
" Plug 'lervag/vimtex'
" Plug 'junegunn/vim-easy-align'
Plug 'Shougo/deoplete.nvim'
Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
" Plug 'garbas/vim-snipmate'
Plug 'preservim/nerdtree'
Plug 'ivalkeen/nerdtree-execute'
Plug  'ryanoasis/vim-devicons'
" Plug  'vim-syntastic/syntastic'
" Plug 'Lokaltog/powerline'
" Plug 'tpope/vim-surround'
" Plug 'zchee/deoplete-jedi' "
" Plug 'vim-airline/vim-airline' "fancy vim status bar
Plug 'itchyny/lightline.vim' "fancy vim status bar
" Plug 'vim-airline/vim-airline-themes'
Plug 'Raimondi/delimitMate'
Plug 'jiangmiao/auto-pairs' "set matching quotation marks, braces, etc.
" Plug 'davidhalter/jedi-vim' "python go-to function and completion
" Plug 'sbdchd/neoformat' "code formatting
" Plug 'neomake/neomake'
" Plug 'Vigemus/iron.nvim'
Plug 'tpope/vim-fugitive'
Plug 'edkolev/tmuxline.vim'
call plug#end()
"------------------------------CUSTOM PLUGINS
" execute ":source ".'~/developer/init.vim/grep-operator.vim'
"}}}
"================================================= Personal configuration ===================={{{
"------------------------------GLOBAL VARIABLES------------------------------{{{
"clipboard, pasteboard, copy and paste, Zwischenablage
"Clipboard interaction Windows and WSL
"It would suffice, to deposit win32yank.exe into the search path
"The unix command line tool win32yank.exe 
"is available at https://www.github.com/equalsraf/win32yank/releases
"The following global variable defines a more explicit way 
"to control the behaviour of the copy and paste mechanism
let g:clipboard = {
                  \'name' : 'win32yank-wsl',
                  \'copy' : {
                  \'+' : 'win32yank.exe -i --crlf',
                  \'*' : 'win32yank.exe -i --crlf'
                  \},
                  \'paste' : {
                  \'+' : 'win32yank.exe -o --lf',
                  \'*' : 'win32yank.exe -o --lf'
                  \},
                  \'cache_enabled' : 0
                  \}
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
			\'vim':'"',
			\'sql':'--',
			\'tex':'%',
			\'c':'//'
      \}
let g:SPELL_LANG = "en_us"|	"global spelling language
let s:verbose = 0|	"Global indicator variable for more verbose output
let g:VIMRC_DIR="/home/philipp/Developer/Vimscript/init.vim/"
let g:RFUNS_DIR="/home/philipp/Developer/R/"
let g:RFUNS="/home/philipp/Developer/R/nuetzlicheFunktionen.R"
let g:python3_host_prog="/usr/bin/python3"
let g:python_host_prog="/usr/bin/python2"
let g:mapleader = '\'|			"Set the leader key to the hyphen character
let g:maplocalleader = '-'|		"Map the localleader key to a backslash
let g:trlWspPattern = '\v\s+$'|		"Search pattern for trailing whitespace
"}}}
"------------------------------FUNCTIONS------------------------------{{{
"TODO: Function that changes a word globally
"TODO: create formatter for r function arguments
"------------------------------RemoveSwapFile{{{
"Delete the current swap file
function! s:RemoveSwapFile()
eexecute ":!rm ".swapname(bufname())
endfunction
"}}}
"------------------------------DeleteLine{{{
function! s:DeleteLine()
  call setline(".",'')
  startinsert!
endfunction
"}}}
"------------------------------OpenTagInNewSplit{{{
function! s:OpenTagInNewSplit(myTag)
      " Todo: quit if a tag does not exist
      execute ":ptag ".a:myTag
endfunction
"}}}
"------------------------------ChangeSurroundingChar{{{
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
"------------------------------Surround{{{
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
"------------------------------CommentLines{{{
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
"------------------------------OpenOrRefreshNerdTree{{{
"Open the NERDTree if it is not visible, or refresh its working directory
"otherwise
function! s:OpenOrRefreshNerdTree()
	NERDTreeToggle
  NERDTreeRefreshRoot
endfunction
"}}}
"------------------------------setLocalWorkDir{{{
"set local working directory
function! s:setLocalWorkDir()
	echom &buftype
	if len(&buftype) == 0	"normal buffer has empty option &buftype (see :help buftype)
		execute ":lcd " . expand("%:p:h")
	endif
endfunction
"}}}
"------------------------------FormatAndFeedToRepl{{{
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
"------------------------------OpenOmni{{{
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
"------------------------------SpellCheckToggle{{{
"Toggle spell check
function! s:SpellCheckToggle()
	if &spell
		set nospell
	else
		execute "set spell spelllang=".g:SPELL_LANG
	endif
endfunction
"}}}
"------------------------------QuickFixToggle{{{
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
"------------------------------FoldColumnToggle{{{
"Function to toggle the foldcolumn
function! s:FoldColumnToggle()
	if &foldcolumn
		setlocal foldcolumn=0
	else
		setlocal foldcolumn=4
	endif
endfunction
"}}}
"------------------------------CheckBuf{{{
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
"------------------------------BufferCycle{{{
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
"------------------------------HlTrlWsp{{{
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
"------------------------------Cmt{{{
"Print a comment if boolean script variable s:verbose is set
function! s:Cmt(comment)
	if s:verbose
		echo a:comment
	endif
endfunction
"}}}
"------------------------------GoToWinAndRefreshNerdtree{{{
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
"------------------------------GoToNeighbourWin{{{
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
"------------------------------ToggleSyntax{{{
"Toggle syntax coloring
function! s:ToggleSyntax()
	if(exists("g:syntax_on"))
		syntax off
	else
		syntax enable
	endif
endfunction
"}}}
"------------------------------GR{{{
function GR(replacementString)
	%s/{expand("<cword>")}/{a:replacementString}/gc
endfunction
"}}}
"------------------------------RangeSearch{{{
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
"------------------------------ResCur{{{
"Reset cursor position
function! ResCur()
	try
		if line("'\"") <= line("$")
			normal! g`"
			return 1
		endif
	endtry
endfunction
"}}}
"------------------------------MaxCurWin{{{
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
"------------------------------MinCurWin{{{
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
	"------------------------------SETTINGS------------------------------{{{
	"TODO:command that repeats last command
" 	set path to current directory ( Corresponds to output of :pwd or :echo getcwd() )
	set path=**
	command! Tex :w|:!pdflatex -shell-escape %
	command! RemoveSwap :call <SID>RemoveSwapFile()<cr>
  set nocompatible| "Required by the vim-polyglot plugin
  colorscheme koehler
"   colorscheme pablo
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
  "Enable mouse for all modes (visual, insert, command-line mode, etc.)
	set mouse=a
" 	set ttymouse=xterm2|  "when used inside tmux
"Zwischenablage, clipboard, pasteboard, copy and paste
"Es reicht einfach das Hinterlegen des Unix-Programms
"win32yank.exe
"Dieses ist unter https://www.github.com/equalsraf/win32yank/releases
"herunterzuladen
  set clipboard=unnamedplus
	set shiftround|		"round value for indentation to multiple of shiftwidth
	set number
	set laststatus=2
	set expandtab
        set shiftwidth=2
        set softtabstop=2
	set autoindent
	set smartindent
	"set autowriteall 	"automatically write buffers when required
	filetype plugin indent on
	"}}}
"------------------------------ABBREVIATIONS------------------------------{{{
iabbrev 'van\ W' van Wickevoort Crommelin
iabbrev ppp Philipp van Wickevoort Crommelin
iabbrev ~  ~<space>|    " Replace NON-BRAKE-SPACE character (Hex-Code c2a0)
                        " with regular space character (Hex-code a0)
"}}}
"------------------------------MAPPINGS------------------------------{{{
"------------------------------GLOBAL{{{
"move cursor just before found character
noremap f t
"move cursor just after found character
noremap F T
"}}}
"------------------------------NORMAL MODE{{{
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
"Now jump to a tag with :tag /pattern or use the following mapping
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
nnoremap <silent> <localleader>c :call <SID>CommentLines()<cr>
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
nnoremap <localleader>f :call <SID>FoldColumnToggle()<cr>
noremap <silent> t :call <SID>BufferCycle("up")<cr>
noremap <silent> <s-T> :call <SID>BufferCycle("down")<cr>
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
nnoremap <silent> <localleader>w :call <SID>HlTrlWsp()<cr>
"Delete all trailing white space charactes before end-of-line character
nnoremap <silent> <localleader>W :execute "normal! mq:%s/".trlWspPattern."//g\r:nohl\r`q"<cr>
"Write and close all windows in all tabs und quit vim
nnoremap <localleader>Z :wqall<cr>
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
nnoremap <silent> <localleader>ev :execute ":split ".$MYVIMRC."\|:lcd ".g:VIMRC_DIR<cr>
"source (aka. "reload") vimrc file
nnoremap <localleader>r :source $MYVIMRC<CR>
"open terminal emulator
nnoremap <silent> <localleader>C :<c-u>execute "split term://bash"<cr>:startinsert<cr>
"select word with space key
nnoremap <space> viw
"clear current line
nnoremap <silent> <localleader>d :call <sid>DeleteLine()<cr>
"Increase tabstop
noremap <silent> <localleader>ll :let &tabstop += (&tabstop < 10) ? 1 : 0 <CR>
"Decrease tabsto
noremap <silent> <localleader>hh :let &tabstop -= (&tabstop < 2) ? 0 : 1 <CR>
"}}}
"------------------------------VISUAL MODE{{{
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
"expand R pipe 
inoremap <<CR> %>%<CR>
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
augroup end
"}}}
"------------------------------Filetype python{{{
augroup python
	autocmd!|	"Delete all comands from group first
	autocmd FileType python :iabbrev iff if:<left>
	autocmd FileType python :iabbrev fnn def ()<left><left>
	autocmd FileType python setlocal foldmethod=indent
	autocmd FileType python setlocal foldlevelstart=0
augroup end
"}}}
"------------------------------Filetype r{{{
augroup r
	autocmd!
	autocmd FileType r :iabbrev iff if()<left>
" 	autocmd FileType r :call StartR("R")
	autocmd FileType r :iabbrev fnn = function()<left><left><left><left><left><left><left><left><left><left><left><left><left><left>
        autocmd Filetype r :setlocal colorcolumn=81|                    "Display a coloured vertical bar
        autocmd Filetype r :setlocal foldmethod=marker|                    "Display a coloured vertical bar
"         autocmd Filetype r :setlocal syntax=r|                          "Syntax is sometimes not set automatically when file is opened with NERDtree. That is why it needs to be set explicitly here.
augroup end
"}}}
"------------------------------Filetype html{{{
augroup markdown
	autocmd!
	autocmd FileType markdown onoremap <buffer> in@ :<c-u>execute "normal! /@\r:nohlsearch\rhviw"<cr>
 	autocmd FileType markdown onoremap <buffer> ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>|	"delete markdown file heading of current section
	autocmd FileType markdown onoremap <buffer> ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_j"<cr>|	"delete around heading
augroup end
"}}}

augroup perl
      autocmd!
      autocmd FileType perl :iabbrev '/' //<left>|"Create matching slash in regular expression environments
augroup end
"------------------------------Filetype vim{{{
augroup vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
	autocmd FileType vim setlocal foldlevelstart=0
augroup end
"}}}
"------------------------------miscellaneous{{{
augroup miscellaneous
	autocmd!
"   autocmd vimenter * :NERDTree|           "Display Nerdtree after vim startup
	autocmd Filetype help :setlocal number|	"show line numbers for vim documentation files
" 	autocmd FileType tex :setlocal spell spelllang=de|	"check spelling automatically for tex files
	autocmd BufWinEnter * :call ResCur()|			          "reset cursor position
	autocmd BufWinEnter * :execute ":setlocal scrolloff=".&lines/4|	"TODO: &lines is not adequate since it is global
" 	autocmd BufReadPost * call <SID>setLocalWorkDir()|	"Set working directory local to buffer
augroup end
"}}}
"}}}
"}}}
"================================================= PLugin configuration ======================{{{
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
	autocmd FileType nerdtree set ignorecase | call <SID>Cmt("Ignorecase option set for nerdtree")
	autocmd FileType nerdtree nnoremap <silent> <buffer> t <c-w><c-w>
	"Trigger nerdtree file system browser automatically, when starting vim session
	"autocmd vimenter * NERDTree0
augroup end
set guifont=hack_nerd_font:h11
set encoding=utf-8
"show line numbers per default
let NERDTreeShowLineNumbers = 1
"show hidden files per default
let NERDTreeShowHidden = 1
nnoremap <localleader>n :call <SID>OpenOrRefreshNerdTree()<cr>
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
" Set R's current working directory to 
" neovim's current working directory
" (and not to the directory of the R file
" being opened, i.e. the default behaviour)
let R_nvim_wd = 1
"Disable all Nvim-R key maps (Each Nvim-R key map has to be configured manually
"then)
let R_user_maps_only = 1
"Show function arguments
let R_show_args = 1
let R_complete = 2 " Always include names of objects
let R_hi_fun = 1 " Activated by Default: Highlight R functions that are
                 " loaded into the global environment
let R_hi_fun_paren = 1  " Highlight R functions only if followed by a (
" let R_hi_fun_globenv = 0
" let Rout_more_colors = 1
let R_show_arg_help = 1
let R_assign = 0
function! s:NvimRconf()
"remap the 'send line' command of Nvim-R plugin"
nmap <buffer> , <Plug>RDSendLine
"remap the 'Send selection' command of Nvim-R plugin"
vmap <buffer> , <Plug>RDSendSelection
"remap the 'check code before sending and then send' command of Nvim-R plugin"
"vmap ,c <Plug>RESendSelection
nmap <buffer> <localleader>rw :call g:SendCmdToR("getwd()")<CR>
nmap <buffer> <localleader>rs :call RAction("str")<CR>
nmap <buffer> <localleader>rh <Plug>RHelp
" nmap <buffer> <localleader>rg :call RAction("glimpse")<CR>
nmap <buffer> <localleader>rg call RAction("glimpse")<CR>
nmap <buffer> <localleader>rl :call RAction("length")<CR>
nmap <buffer> <localleader>rq :call g:SendCmdToR("quit(save='no')")<CR>
nmap <buffer> <localleader>rf :call StartR("R")<CR>
nmap <buffer> <localleader>aa <Plug>RSendFile
nmap <buffer> <localleader>rc call RAction("class")<CR>
endfunction
augroup NvimR
      autocmd!
      autocmd filetype r :call s:NvimRconf()
augroup end
"}}}
"------------------------------ULTISNIPS CONFIGURATION------------------------------{{{
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
"------------------------------LIGHTLINE CONFIGURATION------------------------------{{{
		let g:lightline = {
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
			\ },
			\ 'component_function': {
			\   'gitbranch': 'FugitiveHead'
			\ },
			\ }
"}}}
"------------------------------FUGITIVE CONFIGURATION------------------------------{{{
"Git add file that corresponds to current buffer
nnoremap <silent> <localleader>ga :Git add %<cr>
"Git rebase --continue
nnoremap <silent> <localleader>grc :Git rebase --continue<cr>
"}}}
