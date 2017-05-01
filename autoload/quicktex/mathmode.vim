" Set the asymmetric delimiters for math mode. The order of the lists don't
" matter, as it's impossible to have nested math modes. The $ $ and the $$ $$
" delimiters are handled separately, as they are symmetric. The ending brace
" is omitted in order to match the *-variants.
let s:begMathModes = ['\\(', '\\[', '\\begin{equation', '\\begin{displaymath',
            \'\\begin{multline', '\\begin{gather', '\\begin{align', ]
let s:endMathModes = ['\\)', '\\]', '\\end{equation', '\\end{displaymath',
            \'\\end{multline', '\\end{gather', '\\end{align', ]

" Detects to see if the user is inside math delimiters or not
function! quicktex#mathmode#InMathMode()
    " Find the line number and column number for the last math delimiters
    let [lnum1, col1] = searchpos(join(s:begMathModes,'\|'), 'nbW')
    let [lnum2, col2] = searchpos(join(s:endMathModes,'\|'), 'nbW')

    " See if the last math mode ending delimiter occurred after the last math
    " mode beginning delimiter. If not, then you're in math mode. This works
    " because you can't have math mode delimiters inside math mode delimiters.
    if (lnum1 > lnum2) || (lnum1 == lnum2 && col1 > col2)
        return 1
    endif

    " One can add `let g:quicktex_dollarcheck = 0` to their .vimrc in order to
    " bypass the dollar sign math mode check. This is because tex dollar signs
    " are technically deprecated in Latex and checking for them takes up a
    " majority of the QuickTex's runtime.
    if !get(g:, 'quicktex_dollarcheck', 1)
        return 0
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

    " Find the number of occurrences of dollar signs and double dollar signs in the
    " lines BEFORE the current line. For some reason, the substitution command
    " moves the cursor, even though the 'n' flag is specified, so we need to
    " save and restore the position afterwards. We remove the first character
    " of these commands so that the string starts with a number. We also make
    " sure not to count \$'s. We check whether the user's .vimrc specifies the
    " 'gdefault' option (inverting the effect of the 'g' flag in the
    " substitution command) to ensure that we count the number of dollar and
    " double dollar signs correctly.
    let curs         = getcurpos()
    let gflag        = &gdefault ? '' : 'g'
    let numofdollars = strpart(execute('0,.-s/\\\@<!\$.//ne'.gflag), 1)
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
