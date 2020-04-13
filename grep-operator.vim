nnoremap <localleader>g :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <localleader>g :<c-u>call <SID>GrepOperator(visualmode())<cr>
function! s:GrepOperator(type)
	let unnamed_reg = @@
	if a:type ==# 'v'
		normal! `<v`>y
	elseif a:type ==# 'char'
		normal! `[y`]
	else
		return
	endif
	silent execute "grep ".shellescape(@@)." *.txt"
	copen
	let @@ = unnamed_reg
endfunction
