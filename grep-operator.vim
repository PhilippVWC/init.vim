nnoremap <localleader>g :set operatorfunc=GrepOperator<cr>g@
function! GrepOperator(type)
	echom a:type
endfunction
vnoremap <localleader>g :<c-u>call GrepOperator(visualmode())<cr>
"some minor comment
