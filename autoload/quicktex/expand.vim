function! quicktex#expand#ExpandWord(ft)
    " Get the current line up to the cursor position
    let line = strpart(getline('.'), 0, col('.')-1)

    " If the last character was a space, then return a space as the keyword.
    " The colon is necessary when indexing with negative numbers. Otherwise,
    " part the string at the last space. This will be the last word typed.
    " Note that if there is no space, strridx returns -1, which all works out.
    let word = (line[-1:] == ' ') ? ' ' : split(line, '\s', 1)[-1]

    " Cuts the word so that it only contains valid keyword characters.
    " Non-valid keyword characters are defined by g:quicktex_excludechar.
    " Default value: ['(','{','[']
    let word = split(word, join(g:quicktex_excludechar, '\|'), 1)[-1]

    " If the filetype is tex and you're in mathmode, then use that dictionary.
    " Otherwise, use the filetype dictionary. If there is no entry, just set
    " result to ''.
    if (a:ft == 'tex' || a:ft == 'pandoc') && quicktex#mathmode#InMathMode()
        let result = get(g:quicktex_math, word, '')
    else
        execute('let result = get(g:quicktex_'.a:ft.', word, "")')
    endif

    " If there is no result found in the dictionary, then return the original
    " trigger key.
    if result == ''
        return get(g:, 'quicktex_trigger', ' ')
    endif

    " Create a string of backspaces to delete the last word, and also create a
    " string for jumping back to the identifier "<+++>" if it exists.
    let delword  = repeat("\<BS>", strlen(word))
    let jumpBack = stridx(result,'<+++>')+1 ? "\<ESC>:call search('<+++>', 'b')\<CR>\"_cf>" : ''

    " Delete the original word, replace it with the result of the dictionary,
    " and jump back if needed.
    return "\<C-g>u".delword.result.jumpBack
endfunction
