" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Mar 15, 2017

" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually pressing the keys yourself
inoremap <silent> <buffer> <Space> <C-r>=<SID>ExpandWord()<CR>

function! s:ExpandWord()
    " Get the current line and the column number of the end of the last typed
    " word
    let line = getline('.')
    let end  = col('.')-2

    " If the last character was a space, then return a space as the keyword.
    " Otherwise, find either the first character after a space or the beginning
    " of the line, whichever is closer. This matches the first character of the
    " last typed word. Get the column number and subtract one to get where the
    " last word begins.
    if line[end] == ' '
        let word = ' '
    else
        let begin = searchpos('^\|\s\S', 'nbe')[1] - 1
        let word  = line[begin:end]
    endif

    " If the filetype is tex and you're in mathmode, then use that dictionary.
    " Otherwise, use the filetype dictionary. If anything fails, such as the
    " dictionary lookup, the existence of dictionaries, etc., then just put
    " the original space.
    try
        try
            if &ft == 'tex' && vimtexer#mathmode#InMathMode()
                " Use (, {, [, and " to delimit the beginning of a math keyword
                let word = split(word, '{\|(\|[\|"')[-1]
                let result = g:vimtexer_math[word]
            else
                execute 'let result = g:vimtexer_'.&ft.'[word]'
            endif
        catch
            let result = g:vimtexer_default[word]
        endtry
    catch
        return ' '
    endtry

    " String of backspaces to delete word
    let delword = substitute(word, '.', "\<BS>", 'g')
    " If the result contains the identifier "<+++>", then your cursor will be
    " placed there automatically after the subsitution.
    if result =~ '<+++>'
        let jumpBack = "\<ESC>?<+++>\<CR>\"_cf>"
    else
        let jumpBack = ''
    endif

    " Delete the original word, replace it with the result of the dictionary,
    " and jump back if needed.
    return delword.result.jumpBack
endfunction
