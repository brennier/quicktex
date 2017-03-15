" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Mar 15, 2017

" If the variable doesn't exist, set to its default value
let g:vimtexer_jumpfunc = get(g:, 'vimtexer_jumpfunc', 1)

" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually pressing the keys yourself
autocmd FileType * call AssignExpander()

function! AssignExpander()
    inoremap <silent> <buffer> <Space> <C-r>=<SID>ExpandWord(&ft)<CR>
endfunction

function! s:ExpandWord(ft)
    " Get the current line and the column number of the end of the last typed
    " word
    let line = getline('.')
    let end  = col('.')-2

    " If the last character was a space and jumpfunc is on, then delete the
    " space and jump to the nextinstance of <+.*+>. At the moment, jumping
    " is only available in tex files.
    if a:ft == 'tex' && line[end] == ' ' && g:vimtexer_jumpfunc == 1
        return "\<BS>\<ESC>/<+.*+>\<CR>\"_cf>"
    endif

    " Find either the first character after a space or the beginning of the
    " line, whichever is closer. This matches the first character of the last
    " typed word. Get the column number and subtract one to get where the last
    " word begins.
    let begin = searchpos('^\|\s\S', 'nbe')[1] - 1
    let word  = line[begin:end]

    " If the filetype is tex and you're in mathmode, then use that dictionary.
    " Otherwise, use the filetype dictionary. If anything fails, such as the
    " dictionary lookup, the existence of dictionaries, etc., then just put
    " the original space.
    try
        try
            if a:ft == 'tex' && s:InMathMode()
                " Use (, {, [, and " to delimit the beginning of a math keyword
                let word = split(word, '{\|(\|[\|"')[-1]
                let result = g:vimtexer_math[word]
            else
                execute 'let result = g:vimtexer_'.a:ft.'[word]'
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

" Set the asymmetric delimiters for math mode. The order of the lists don't
" matter, as it's impossible to have nested math modes. The $ $ and the $$ $$
" delimiters are handled separately, as they are symmetric.
let s:begMathModes = ['\\(', '\\[', '\\begin{equation}', '\\begin{displaymath}',
            \'\\begin{multline}', '\\begin{gather}', '\\begin{align}',
            \'\\begin{multline\*}', '\\begin{gather\*}', '\\begin{align\*}',
            \'\\begin{equation\*}']
let s:endMathModes = ['\\)', '\\]', '\\end{equation}', '\\end{displaymath}',
            \'\\end{multline}', '\\end{gather}', '\\end{align}',
            \'\\end{multline\*}', '\\end{gather\*}', '\\end{align\*}',
            \'\\end{equation\*}']

" Detects to see if the user is inside math delimiters or not
function! s:InMathMode()
    " Find the line number and column number for the last math delimiters
    let [lnum1, col1] = searchpos(join(s:begMathModes,'\|'), 'nbW')
    let [lnum2, col2] = searchpos(join(s:endMathModes,'\|'), 'nbW')

    " See if the last math mode ending delimiter occured after the last math
    " mode beginning delimiter. If not, then you're in math mode. This works
    " because you can't have math mode delimiters inside math mode delimiters.
    if (lnum1 > lnum2) || (lnum1 == lnum2 && col1 > col2)
        return 1
    endif

    " The rest of this function is for determining whether you're within $ $ or
    " $$ $$ tags. This is much more complicated, as they're symmetric and could
    " be on a previous line. I'll try my best to explain. We're trying to
    " count the number of $ signs and the number of $$ signs from the
    " beginning of the document up to the cursor position. If either one of
    " these numbers is odd, then we must be in math mode. It's impossible that
    " they both be odd, as math modes cannot be nested. If we add these two
    " numbers together, we see that if the result is odd then one of the
    " summands was odd. If the result is even, then both of the summands must
    " have been even (as they can't both be odd). Instead of counting them
    " both separately and then adding them, though, we can count both of
    " them together at the same time. This reduces our search to a single
    " pass-through instead of two pass-throughs.

    " Find the number of occurences of dollar signs and double signs in the
    " lines BEFORE the current line. For some reason, the substitution command
    " moves the cursor, even though the 'n' flag is specified, so we need to
    " save and restore the position afterwards. We remove the first character
    " of these commands so that the string starts with a number. We also make
    " sure not to count \$'s.
    let curs = getcurpos()
    let pattern      = '\$\$\|[^\\]\$\|^\$'
    let numofdollars =  execute('0,'.(line('.')-1).'s/'.pattern.'//gne')[1:]
    call setpos('.', curs)

    " Get a list of $ signs and $$ signs on the current line by getting the
    " line up to the cursor position, substituting a space for every `\$` and
    " for everything that isn't a $ sign. After all this, we split the string,
    " which by this point should be a string exclusively of spaces and $ signs.
    " The end result will look something like ['$', '$$', '$$', '$', '$$'].
    " After all this, we take the length of the list and add it to the number
    " of $'s and $$'s found in the previous lines.
    let line = substitute(getline('.')[:col('.')-1], '\\\$\|[^$]', ' ', 'g')
    let numofdollars += len(split(line))

    " If the total number of $'s and $$'s is odd, then we must be in some
    " version of math mode. Otherwise, we're not in math mode.
    return (numofdollars % 2)
endfunction
