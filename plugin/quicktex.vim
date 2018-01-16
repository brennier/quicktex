" File: quicktex.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Mar 15, 2017

" Call the assignment function after the filetype of the file has been
" determined.
autocmd FileType * call AssignExpander()

let s:begMathModes = ['\\(', '\\[', '\\begin{equation', '\\begin{displaymath',
            \'\\begin{multline', '\\begin{gather', '\\begin{align', ]
let s:endMathModes = ['\\)', '\\]', '\\end{equation', '\\end{displaymath',
            \'\\end{multline', '\\end{gather', '\\end{align', ]
let s:tex_mode = ['tex', 'math', s:begMathModes, s:endMathModes]

if !exists('g:quicktex_modes')
    let g:quicktex_modes = [s:tex_mode]
else
    call add(g:quicktex_modes, s:tex_mode)
endif

function! AssignExpander()
    " Trigger on a non-word character
    if exists('g:quicktex_'.&ft)
        autocmd InsertCharPre * if v:char =~ '\W' | call quicktex#expand#ExpandWord(&ft, v:char) | endif
    endif
endfunction
