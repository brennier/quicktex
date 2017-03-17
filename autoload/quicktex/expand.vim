function! quicktex#expand#ExpandWord()
    " Get the current line up to the cursor position
    let line = getline('.')[:col('.')-2]

    " If the last character was a space, then return a space as the keyword.
    " The colon is necessary when indexing with negative numbers. Otherwise,
    " part the string at the last space. This will be the last word typed.
    " Note that if there is no space, strridx returns -1, which all works out.
    let word = (line[-1:] == ' ') ? ' ' : strpart(line, strridx(line, ' ')+1)

    " If the filetype is tex and you're in mathmode, then use that dictionary.
    " Otherwise, use the filetype dictionary. If there is no entry, just set
    " result to 1.
    if &ft == 'tex' && quicktex#mathmode#InMathMode()
        " Use (, {, [, and " to delimit the beginning of a math keyword
        let word   = split(word, '{\|(\|[\|"')[-1]
        let result = get(g:quicktex_math, word, '')
    else
        execute 'let result = get(g:quicktex_'.&ft.', word, '''')'
    endif

    " If the dictionary lookup failed, then result is 1, which means that it's
    " true. Otherwise, result is a string, which is always false.
    if result == ''
        return ' '
    endif

    " String of backspaces to delete the last word. We also set a string for
    " jumping back to the identifier "<+++>" if it exists.
    let delword  = repeat("\<BS>", strlen(word))
    let jumpBack = stridx(result,'<+++>')+1 ? "\<ESC>?<+++>\<CR>\"_cf>" : ''

    " Delete the original word, replace it with the result of the dictionary,
    " and jump back if needed.
    return delword.result.jumpBack
endfunction
