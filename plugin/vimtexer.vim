" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Dec 01, 2016

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
" instance of <+.*+>. At the moment, jumping is only available in tex files
function! JumpFunc()
    if exists('g:vimtexer_jumpfunc') && g:vimtexer_jumpfunc == 1 && &ft == 'tex'
        return "\<BS>\<ESC>/<+.*+>\<CR>cf>"
    else
        return ' '
    endif
endfunc

function! ExpandWord()
    " Get the current line and the column number of the end of the last typed
    " word
    let line = getline('.')
    let end = col('.')-2

    " If the last character was a space, then delete it and jump to the next
    " instance of <+.*+>
    if line[end] == ' '
        return JumpFunc()
    endif

    " If a dictionary for this filetype doesn't exist, don't do anything.
    if !exists('g:vimtexer_'.&ft)
        return ' '
    endif

    " Find either the first character after a space or the beginning of the
    " line, whichever is closer. This matches the first character of the last
    " typed word. Get the column number and subtract one to get where the last
    " word begins.
    let begin = searchpos('\s\zs\|^', 'nbW')[1] - 1

    let word = line[begin:end]

    " If the filetype is tex, there's a mathmode dictionary available, and
    " you're in mathmode, then use that dictionary. Otherwise, use the
    " filetype dictionary. This must exists because of the previous check in
    " this function. If the dictionary doesn't have the keyword, then set it to
    " the empty string, that is ''
    if &ft == 'tex' && exists('g:vimtexer_math') && InMathMode()
        let result = get(g:vimtexer_math, word, '')
    else
        execute 'let result = get(g:vimtexer_'.&ft.', word, "")'
    endif

    " If the dictionary has no match
    if result == ''
        return ' '
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
    return delword.result.jumpBack
endfunction
