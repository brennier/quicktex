" File: quicktex.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Mar 15, 2017

" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually pressing the keys yourself
autocmd FileType * call AssignExpander()

function! AssignExpander()
    if exists('g:quicktex_'.&ft)
        inoremap <silent> <buffer> <Space> <C-r>=quicktex#expand#ExpandWord()<CR>
    endif
endfunction
