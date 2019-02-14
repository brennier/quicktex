" Set the asymmetric delimiters for math mode. The $ $ and the $$ $$ delimiters
" are handled separately, as they are symmetric. The ending braces are omitted
" in order to match the *-variants.
let s:mathModes = [['\(',                 '\)'               ],
                  \['\[',                 '\]'               ],
                  \['\begin{equation',    '\end{equation'    ],
                  \['\begin{displaymath', '\end{displaymath' ],
                  \['\begin{multline',    '\end{multline'    ],
                  \['\begin{gather',      '\end{gather'      ],
                  \['\begin{align',       '\end{align'       ]]

" Detects to see if the user is inside math delimiters or not
function! quicktex#mathmode#InMathMode()
    " Get the buffer up to the cursor position as a string
    let lines     = getline(0, '.')
    let lines[-1] = strpart(lines[-1], 0, col('.')-1)
    let lines     = join(lines, '')
    " Remove escaped backslashes to avoid something line \\(
    let lines     = substitute(lines, '\\\\', '', 'g')

    for [begin, end] in s:mathModes
        " Remove the part of the string up to the ending delimiter
        let lines = strpart(lines, strridx(lines, end)+1)
        " Check if a corresponding beginning delimiter is left in the string
        if stridx(lines, begin)+1
            return 1
        endif
    endfor

    " Remove escaped dollar signs and replace double dollar signs with single
    " dollar signs. Then, compare string lengths before and after removing
    " all dollar signs. This will be the total number of dollar signs. If this
    " total is odd, you're in math mode. Otherwise, you're not.
    let lines        = substitute(lines, '\\\$', '', 'g')
    let lines        = substitute(lines, '\$\$', '$', 'g')
    let beforelength = strlen(lines)
    let afterlength  = strlen(substitute(lines, '\$', '', 'g'))
    return (beforelength - afterlength) % 2
endfunction
