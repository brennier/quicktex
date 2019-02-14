" File: quicktex.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Jan 16, 2018

" Call the assignment function after the filetype of the file has been
" determined.
autocmd FileType * call AssignExpander()

if !exists('g:quicktex_excludechar')
    let g:quicktex_excludechar = ['{', '(', '[']
endif

function! AssignExpander()
    " If the trigger is a special character, then translate it for the
    " mapping. The default value of the trigger is '<Space>'.
    if exists('g:quicktex_trigger')
        let trigger = get({' ': '<Space>', '	' : '<Tab>'},
                    \g:quicktex_trigger, g:quicktex_trigger)
    else
        let trigger = '<Space>'
    endif

    " If a dictionary for the filetype exists, then map the ExpandWord
    " function to the trigger.
    if exists('g:quicktex_'.&ft)
        execute('inoremap <silent> <buffer> '.trigger.
                    \' <C-r>=quicktex#expand#ExpandWord("'.&ft.'")<CR>')
    endif
endfunction
