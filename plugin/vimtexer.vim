" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Nov 30, 2016

if exists('g:vimtexer_usedefault') && g:vimtexer_usedefault == 1
    " Do nothing. The default_keywords.vim file will load a dictionaries.
elseif !exists('g:vimtexer_'.&ft)
    " Otherwise, if no dictionary exists for the filetype, don't load the
    " plugin
    finish
endif

" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually presses the keys yourself
inoremap <silent> <Space> <C-r>=ExpandWord()<CR>

" Detects to see if the user is inside math delimiters or not
function! InMathMode()
    " Find the line number and column number for the last \( and \) (or \[ and \])
    let [lnum1, col1] = searchpos('\\(\|\\[','nbW')
    let [lnum2, col2] = searchpos('\\)\|\\]','nbW')

    " See if the last \) (or \]) occured after the last \( (or \[), if it did,
    " then you're in math mode, as the \( or \[ hasn't been closed yet.
    if lnum1 > lnum2
        return 1
    elseif lnum1 == lnum2 && col1 > col2
        return 1
    else
        return 0
    endif
endfunction

" If JumpFunc is on, then delete the last character and then jump to the next
" instance of <+.*+>
function! JumpFunc()
    if exists('g:vimtexer_jumpfunc') && g:vimtexer_jumpfunc == 1
        return "\<BS>\<ESC>/<+.*+>\<CR>cf>"
    else
        return ' '
    endif
endfunc

function! ExpandWord()
    " Get the current line and the column number of the last character
    let line = getline('.')
    let column = col('.')-2

    " If the last character was a space, then delete it and jump to the next
    " instance of <+.*+>
    if line[column] == ' '
        return JumpFunc()
    endif

    " If the last character doesn't exist (i.e. you are at the beginning of
    " the line), then just insert a space. Otherwise, go to the beginning of
    " the last space-delimited word
    if column == -1
        return ' '
    else
        normal! B
    endif

    " Get the word inbetween the new cursor position and the saved position
    let word = line[col('.')-1:column]

    " String of "Rights" for going foward
    let gofwd = substitute(word, '.', "\<Right>", 'g')

    " If the filetype is tex, there's a mathmode dictionary available, and
    " you're in mathmode, then use that dictionary. Otherwise, use the
    " filetype dictionary. This must exists because of the check at the top of
    " the program. If the dictionary doesn't have the keyword, then set it to
    " the empty string, that is ''
    if &ft == 'tex' && exists('g:vimtexer_math') && InMathMode()
        let result = get(g:vimtexer_math, word, '')
    else
        execute 'let result = get(g:vimtexer_'.&ft.', word, "")'
    endif

    " If the dictionary has no match
    if result == ''
        return gofwd.' '
    endif

    " String of backspaces to delete word
    let delword = substitute(word, '.', "\<BS>", 'g')
    " If the result contains the identifier "<+++>", then your cursor will be
    " placed there automatically after the subsitution.
    if result =~ '<+++>'
        let jumpBack = "\<ESC>?<+++>\<CR>cf>"
    else
        let jumpBack = ''
    endif
    " Go forward, delete the original word, replace it with the result of
    " the dictionary, and then jump back if needed
    return gofwd.delword.result.jumpBack
endfunction
