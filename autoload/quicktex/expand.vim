function! quicktex#expand#ExpandWord(ft)
    " Get the current line up to the cursor position
    let line = strpart(getline('.'), 0, col('.')-1)

    " If the last character was a space, then return a space as the keyword.
    " The colon is necessary when indexing with negative numbers. Otherwise,
    " part the string at the last space. This will be the last word typed.
    " Note that if there is no space, strridx returns -1, which all works out.
    let word = (line[-1:] == ' ') ? ' ' : split(line, '\s', 1)[-1]

    " Use (, {, and [ to delimit the beginning of a math keyword
    let word = split(word, '{\|(\|[', 1)[-1]

    " If the filetype is tex and you're in mathmode, then use that dictionary.
    " Otherwise, use the filetype dictionary. If there is no entry, just set
    " result to ''.
    let dictionary = ''
    for mode in g:quicktex_modes
        if a:ft == mode[0]
            let [row1, col1] = searchpos(join(mode[2],'\|'), 'nbW')
            let [row2, col2] = searchpos(join(mode[3],'\|'), 'nbW')

            if (row1 > row2) || (row1 == row2 && col1 > col2)
                let dictionary = mode[1]
                break
            endif
        endif
    endfor

    if dictionary == ''
        if a:ft == 'tex' && g:quicktex_dollarcheck && s:InMathMode()
            let dictionary = 'math'
        else
            let dictionary = a:ft
        endif
    endif

    execute('let result = get(g:quicktex_'.dictionary.', word, "")')

    " If there is no result found in the dictionary, then return the original
    " trigger key.
    if result == ''
        return get(g:, 'quicktex_trigger', ' ')
    endif

    " Create a string of backspaces to delete the last word, and also create a
    " string for jumping back to the identifier "<+++>" if it exists.
    let delword  = repeat("\<BS>", strlen(word))
    let jumpBack = stridx(result,'<+++>')+1 ? "\<ESC>?<+++>\<CR>\"_cf>" : ''

    " Delete the original word, replace it with the result of the dictionary,
    " and jump back if needed.
    return delword.result.jumpBack
endfunction

function! s:InMathMode()
    let curs         = getcurpos()
    let gflag        = &gdefault ? '' : 'g'
    let numofdollars = strpart(execute('0,.-s/\\\@<!\$.\?//ne'.gflag), 1)
    call setpos('.', curs)

    " Count the number of $ and $$ signs on the current line by getting the
    " line up to the cursor position, substituting a space for every `\$`,
    " splitting at every $ and $$ sign, and then counting the number of splits
    " there are. We add all of this to the number of dollars we found in the
    " previous lines.
    let line = substitute(strpart(getline('.'), 0, col('.')-1), '\\\$', ' ', 'g')
    let numofdollars += len(split(line, '\$.', 1))-1

    " If the total number of $'s and $$'s is odd, then we must be in some
    " version of math mode. Otherwise, we're not in math mode.
    return (numofdollars % 2)
endfunction
