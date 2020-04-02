"Init.vim from Philipp van Wickevoort Crommelin.
"Contact me by email: philippcrommelin@googlemail.com.
"
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
Plug 'tpope/vim-surround'
"Plug 'zchee/deoplete-jedi' "
Plug 'vim-airline/vim-airline' "fancy vim status bar
"Plug 'vim-airline/vim-airline-themes' 
Plug 'jiangmiao/auto-pairs' "set matching quotation marks, braces, etc. 
Plug 'davidhalter/jedi-vim' "python go-to function and completion
Plug 'sbdchd/neoformat' "code formatting
Plug 'neomake/neomake'
Plug 'Vigemus/iron.nvim'
Plug 'tpope/vim-fugitive'
Plug 'edkolev/tmuxline.vim'
call plug#end()
"}}}
"================================================== Personal configuration ===================={{{
"------------------------------FUNCTIONS------------------------------{{{

"Go to window with window number
function! Pvwc_GoToWin(winNumb)
	call win_gotoid(win_getid(a:winNumb))
endfunction

"Go to previous window
function! Pvwc_GoToPrevWin() 
	let l = winnr()-1
	let n = winnr('$')
	if( l==0 )
		call Pvwc_GoToWin(n)
	else
		call Pvwc_GoToWin(l%n)
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
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction
"}}}
"------------------------------SETTINGS------------------------------{{{
"TODO:command that repeats last command
command! Tex :w|:!pdflatex -shell-escape % 
let g:python3_host_prog="/Users/Philipp/anaconda3/python.app/Contents/MacOS/python"
let g:python_host_prog="/usr/bin/python"
let mapleader = '\'|	"set the leader key to the hyphen character
let maplocalleader = '-'|	"map the localleader key to a backslash

set wrap|	"let lines break, if their lengths exceed the window size
set mouse=a
set shiftround|	"round value for indentation to multiple of shiftwidth
set number
set laststatus=2
set autoindent
set smartindent
"set autowriteall "automatically write buffers when required
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
nnoremap Z ZZ|	"write and close
"map redo to capital u
nnoremap U <c-r>
"go to next window
nnoremap t <c-w><c-w>
"go to previous window
nnoremap <S-t> :call Pvwc_GoToPrevWin()<esc>
"go to next tab
nnoremap <localleader>t :tabnext<cr>
"go to previous tab
nnoremap <localleader><S-t> :tabprevious<cr>
"Edit vimrc file
nnoremap <localleader>ev :split $MYVIMRC<CR>
"source (aka. "reload") ""vimrc file
nnoremap <localleader>r :source $MYVIMRC<CR>
"open terminal emulator
nnoremap <localleader>C :split term://zsh<CR>
"select word with space key
nnoremap <space> viw	
"clear current line
nnoremap <localleader>d ddO
"Increase tabstop
noremap <localleader>ll :let &tabstop += (&tabstop < 10) ? 1 : 0 <CR>
"Decrease tabstop
noremap <localleader>hh :let &tabstop -= (&tabstop < 2) ? 0 : 1 <CR>
"Search within visually selected ranges
"Capitalize word
"nnoremap <c-u> viwgU
"}}}
"------------------------------VISUAL MODE{{{
vnoremap $ g_|	"go to the last printable character of current line (skip newline char)
"surround selection by double quotes
vnoremap <localleader>" di"<esc>pa"<esc>
vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>
vnoremap p i(|	"constrain selection to content of paranthesis
"}}}
"------------------------------INSERT MODE{{{
"Capitalize word, place cursor behind word, and enter instert mode
inoremap <c-u>  <esc>viwgUea	
"Escape sequence
"inoremap jk <esc>
"inoremap <esc> <nop>
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
onoremap pp :<c-u>normal! F)vi(<cr>|	"next paranethesis environment
onoremap np :<c-u>normal! f(vi(<cr>|	"last paranthesis environment
onoremap b :<c-u>normal! vi{<cr>|	"inner brace environment
onoremap nb :<c-u>normal! f{vi{<cr>|	"next brace environment
onoremap pb :<c-u>normal! F}vi{<cr>|	"last brace environment
"}}} 
"}}}
"------------------------------AUTOCOMMANDS	{{{
"autocmd BufWinEnter * :write|echom("PVWC\tFile saved.")
"TODO: autocmd BufWinenter *.R "deactivate iron-vim plugin"
"	or alternatively 
"	autocmd FileType r "deactivate iron-vim plugin"
"Comment a line specific to its filetype
augroup filetype_html
    autocmd!
    autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END
augroup python
	autocmd!|	"Delete all comands from group first
	autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>
	autocmd FileType python :iabbrev iff if:<left>
	autocmd FileType python :iabbrev fnn def ()<left><left>
augroup END
augroup r
	autocmd!
	autocmd FileType r nnoremap <buffer> <localleader>c I#<esc>
	autocmd FileType r :iabbrev iff if()<left>
	autocmd FileType r :iabbrev fnn = function()<left><left><left><left><left><left><left><left><left><left><left><left><left><left>
augroup END
augroup markdown
	autocmd!
	autocmd FileType markdown onoremap <buffer> in@ :<c-u>execute "normal! /@\r:nohlsearch\rhviw"<cr>
 	autocmd FileType markdown onoremap <buffer> ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>|	"delete markdown file heading of current section
	autocmd FileType markdown onoremap <buffer> ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_j"<cr>|	"delete around heading
augroup END
augroup several
	autocmd!
	autocmd FileType vim nnoremap <buffer> <localleader>c I"<esc>
	"Don't wrap text for html files
	autocmd BufNewFile,BufRead *.html setlocal nowrap
	"check spelling automatically for tex files
	autocmd FileType plaintex :setlocal spell spelllang=de
	autocmd BufWinEnter * call ResCur()
	"autocmd ButT
augroup END
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
"enable the <tab> and shift <tab> to cycle through completion pop up menu
"execture expression pumvisible, when pressing tap
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"}}}
"------------------------------NERDTREE CONFIGURATION------------------------------{{{
"try fc-cache -v -f in terminal to reset font buffer
set guifont=hack_nerd_font:h11
set encoding=utf-8
"show line numbers per default
let NERDTreeShowLineNumbers = 0
"show hidden files per default
let NERDTreeShowHidden = 1
"Trigger nerdtree file system browser automatically, when starting vim session
"autocmd vimenter * NERDTree 
nnoremap <localleader>n :NERDTreeToggle<CR>
"nnoremap <localleader>h :call <Plug>NERDTreeMapOpenSplit()<CR>
let g:webdevicons_enable_nerdtree = 1
"}}}
"------------------------------IRON CONFIGURATION------------------------------{{{
"send visually selected code fragment in visual mode
vnoremap , <Plug>(iron-visual-send)<Esc><CR>
"nmap <localleader>t    <Plug>(iron-send-motion)
"nmap <localleader>r    <Plug>(iron-repeat-cmd)
"send line in normal mode - TODO: move cursor to next line afterwards
nnoremap , <Plug>(iron-send-line)<CR>
"nmap <localleader><CR> <Plug>(iron-cr)
"nmap <localleader>i    <plug>(iron-interrupt)
"nmap <localleader>q    <Plug>(iron-exit)
"nmap <localleader>c    <Plug>(iron-clear)
"}}}
"------------------------------NVIM-R CONFIGURATION------------------------------{{{
let R_assign = 0
"remap the 'send line' command of Nvim-R plugin"
nnoremap , <Plug>RDSendLine
"remap the 'Send selection' command of Nvim-R plugin"
vnoremap , <Plug>RDSendSelection
"remap the 'check code before sending and then send' command of Nvim-R plugin"
"vmap ,c <Plug>RESendSelection
"}}}
"------------------------------ULTISNIPS CONFIGURATION------------------------------{{{
let g:UltiSnipsEditSplit="context"
"dont use <Tab> key to expand snippet
""""""""     let g:UltiSnipsExpandTrigger = "<nop>"
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
