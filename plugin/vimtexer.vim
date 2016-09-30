" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Sept 19, 2016


" TODO: {{{
" " Only load relevent dictionaries
" " Add . $ functions (perhaps as . and ')
" " " Transform them after jumping out of math mode
" " Add undo and redo keywords
" " Add del keyword
" " Improve command to change to \[ \]
" " Add search keywords?
" " Visually Select when JumpFuncing
" " Map infimum
" " Fix JumpFunc for multiline math mode
" }}}

" Special Key Assignment {{{
" Only map these functions if inside a tex file
" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually presses the keys yourself
augroup filetype_tex
    autocmd!
    autocmd FileType tex inoremap <silent> _ <C-r>=MathStart()<CR>
    autocmd FileType tex inoremap <silent> <Space> <C-r>=ExpandWord()<CR>
augroup END
" }}}

" Main Functions {{{
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
    
" Function that starts mathmode
function! MathStart()
    " If already in mathmode, just return a space. This is useful if you want
    " to normally type a keyword. That way, by pressing _, you can space
    " without keyword expansion
    if InMathMode()
        return " "
    else
        " If the last character is a space, then start math mode and go inside
        " the brackets
        if getline(".")[col(".")-2] == " "
            return "\\(  \\) \<Left>\<Left>\<Left>\<Left>"
        " Otherwise, replace the last word with \(word\)
        else
            return "\<ESC>ciw\\(\<ESC>pa\\) "
        endif
    endif
endfunction

" Function for jumping around
" This function is only used in ExpandWord
function! JumpFunc()
    if InMathMode()
        " If there's a <++> to jump to in the line, then jump to it
        if getline('.') =~ '<++>'
            return "\<Right>\<BS>\<ESC>/<++>\<CR>cf>"
        else
        " If there is no <++> on the current line, then exit math mode and jump to
        " right after \)
            execute "normal! / \\\\)\<CR>x"
            return "\<Right>\<Right>\<Right>"
        endif
    else
        return "\<Right>\<BS>\<ESC>/<+.*+>\<CR>cf>"
    endif
endfunction

function! ExpandWord()
    " Move left so that the cursor is over the word and then expand the word
    normal! h
    let word = expand('<cword>')

    " If the last character was a space, then JumpFunc
    " It's -1 instead of -2 because we already moved to the left one space
    if getline('.')[col(".")-1] == " "
        return JumpFunc()
    endif

    " Checks it see if your in mathmode, if so, use the math dictionary. If
    " not, check if a dictionary exists for the given filetype. If the
    " dictionary doesn't exist, remember, we moved left and are over the last
    " character of the word, so move right and put the original space
    if InMathMode()
        let dictionary = g:vimtexer_math
    elseif exists('g:vimtexer_'.&ft)
        execute "let dictionary = g:vimtexer_".&ft
    else
        return "\<Right> "
    endif

    " Get the result of the keyword. If the keyword doesn't exist in the
    " dictonary, return the empty string ''
    let rhs = get(dictionary, word,'')

    " If we found a match in the dictionary
    if rhs != ''
        let jumpBack = ""
        " If the RHS contains the identifier "<+++>", then your cursor will be
        " placed there automatically after the subsitution. Notice that, in
        " general, the JumpFunc goes to "<++>" instead
        if rhs =~ '<+++>'
            let jumpBack = "\<ESC>?<+++>\<CR>cf>"
        endif
        " This is a hack for one letter keywords. It types an extra letter and
        " escapes, so now it's two letters
        let hack = "a\<ESC>"
        " Do the hack, then delete the word and go to insert mode, then type
        " out the right hand side then jump back to "<+++>"
        return hack."ciw".rhs.jumpBack
    else
        " If the dictionary doesn't exist, remember, we moved left and are over
        " the last character of the word, so move right and put the original space
        return "\<Right> "
    endif
endfunction
" }}}

" Keywords {{{

" Keyword mappings are simply a dictionary. Dictionaries are of the form
" "vimtexer_" and then the filetype. The result of a keyword is either a
" literal string or a double quoted string, depending on what you want.
"
" In a literal string, the result is just a simple literal substitution
"
" In a double quoted string, \'s need to be escape (i.e. "\\"), however, you
" can use nonalphanumberical keypresses, like "\<CR>", "\<BS>", or "\<Right>"
"
" Unfortunately, comments are not allowed inside multiline vim dictionaries.
" Thus, sections and comments must be included as entries themselves. Make
" sure that the comment more than one word, that way it could never be called
" by the ExpandWord function

" Math Mode Keywords {{{

if !exists('g:vimtexer_math')
let g:vimtexer_math = {
\'Section: Lowercase Greek Letters' : 'COMMENT',
    \'alpha'   : '\alpha ',
    \'beta'    : '\beta ',
    \'gamma'   : '\gamma ',
    \'delta'   : '\delta ',
    \'epsilon' : '\epsilon ',
    \'ge'      : '\varepsilon ',
    \'zeta'    : '\zeta ',
    \'eta'     : '\eta ',
    \'theta'   : '\theta ',
    \'iota'    : '\iota ',
    \'kappa'   : '\kappa ',
    \'lambda'  : '\lambda ',
    \'gl'      : '\lambda ',
    \'mu'      : '\mu ',
    \'nu'      : '\nu ',
    \'xi'      : '\xi ',
    \'omega'   : '\omega ',
    \'pi'      : '\pi ',
    \'rho'     : '\rho ',
    \'sigma'   : '\sigma ',
    \'tau'     : '\tau ',
    \'upsilon' : '\upsilon ',
    \'gu'      : '\upsilon ',
    \'phi'     : '\varphi ',
    \'chi'     : '\chi ',
    \'psi'     : '\psi ',
    \
\'Section: Uppercase Greek Letters' : 'COMMENT',
    \'Alpha'   : '\Alpha ',
    \'Beta'    : '\Beta ',
    \'Gamma'   : '\Gamma ',
    \'Delta'   : '\Delta ',
    \'Epsilon' : '\Epsilon ',
    \'Zeta'    : '\Zeta ',
    \'Eta'     : '\Eta ',
    \'Theta'   : '\Theta ',
    \'Iota'    : '\Iota ',
    \'Kappa'   : '\Kappa ',
    \'Lambda'  : '\Lambda ',
    \'Mu'      : '\Mu ',
    \'Nu'      : '\Nu ',
    \'Xi'      : '\Xi ',
    \'Omega'   : '\Omega ',
    \'Pi'      : '\Pi ',
    \'Rho'     : '\Rho ',
    \'Sigma'   : '\Sigma ',
    \'Tau'     : '\Tau ',
    \'Upsilon' : '\Upsilon ',
    \'Phi'     : '\Phi ',
    \'Chi'     : '\Chi ',
    \'Psi'     : '\Psi ',
    \
\'Section: Set Theory' : 'COMMENT',
    \'br'    : '\mathbb{R} ',
    \'bc'    : '\mathbb{C} ',
    \'bq'    : '\mathbb{Q} ',
    \'bn'    : '\mathbb{N} ',
    \'bz'    : '\mathbb{Z} ',
    \'subs'  : '\subseteq ',
    \'in'    : '\in ',
    \'nin'   : '\not\in ',
    \'cup'   : '\cup ',
    \'cap'   : '\cap ',
    \'union' : '\cup ',
    \'sect'  : '\cap ',
    \'smin'  : '\setminus ',
    \'set'   : '\{ <+++> \} <++>',
    \'card'  : '\card{ <+++> } <++>',
    \'empty' : '\varnothing ',
    \'pair'  : '( <+++> , <++> ) <++>',
    \'dots'  : '\dots ',
    \
\'Section: Logic' : 'COMMENT',
    \'st'      : '\st ',
    \'exists'  : '\exists ',
    \'nexists' : '\nexists ',
    \'forall'  : '\forall ',
    \'implies' : '\implies ',
    \'iff'     : '\iff ',
    \'and'     : '\land ',
    \'or'      : '\lor ',
    \
\'Section: Relations' : 'COMMENT',
    \'lt'      : '< ',
    \'gt'      : '> ',
    \'leq'     : '\leq ',
    \'geq'     : '\geq ',
    \'eq'      : '= ',
    \'nl'      : '\nless ',
    \'ng'      : '\ngtr ',
    \'nleq'    : '\nleq ',
    \'ngeq'    : '\ngeq ',
    \'neq'     : '\neq ',
    \'neg'     : '\neg ',
    \'uarrow'  : '\uparrow ',
    \'darrow'  : '\downarrow ',
    \'divides' : '\divides ',
    \
\'Section: Operations' : 'COMMENT',
    \'add'   : '+ ',
    \'min'   : '- ',
    \'frac'  : '\frac{ <+++> }{ <++> } <++>',
    \'recip' : '\frac{ 1 }{ <+++> } <++>',
    \'dot'   : '\cdot ',
    \'mult'  : '* ',
    \'exp'   : "\<BS>^",
    \'pow'   : "\<BS>^",
    \'sq'    : "\<BS>^2 ",
    \'inv'   : "\<BS>^{-1} ",
    \'cross' : '\times ',
    \
\'Section: Delimiters' : 'COMMENT',
    \'para'  : '\left( <+++> \right) <++>',
    \'sb'    : '\left[ <+++> \right] <++>',
    \'brac'  : '\left\{ <+++> \right\} <++>',
    \'group' : '{ <+++> } <++>',
    \'angle' : '\angle{ <+++> } <++>',
    \'abs'   : '\abs{ <+++> } <++>',
    \
\'Section: Group Theory' : 'COMMENT',
    \'ord'   : '\ord{ <+++> } <++>',
    \'iso'   : '\iso ',
    \'niso'  : '\niso ',
    \'subg'  : '\leq ',
    \'nsubg' : '\trianglelefteq ',
    \'mod'   : '/ ',
    \'aut'   : '\aut ',
    \
\'Section: Functions' : 'COMMENT',
    \'to'    : '\to ',
    \'comp'  : '\circ ',
    \'of'    : '\left( <+++> \right) <++>',
    \'sin'   : '\sin{ <+++> } <++>',
    \'cos'   : '\cos{ <+++> } <++>',
    \'tan'   : '\tan{ <+++> } <++>',
    \'ln'    : '\ln{ <+++> } <++>',
    \'log'   : '\log{ <+++> } <++>',
    \'dfunc' : '<+++> : <++> \to <++>',
    \'sqrt'  : '\sqrt{ <+++> } <++>',
    \'img'   : '\img ',
    \'ker'   : '\ker ',
    \'case'  : '\begin{cases} <+++> \end{cases} <++>',
    \
\'Section: LaTeX commands' : 'COMMENT',
    \'big'    : "è\<ESC>/\\\\)\<CR>lr]?\\\\(\<CR>lr[llcw",
    \'sub'    : "\<BS>_",
    \'sone'   : "\<BS>_1 ",
    \'stwo'   : "\<BS>_2 ",
    \'sthree' : "\<BS>_3 ",
    \'sfour'  : "\<BS>_4 ",
    \'ud'     : "\<BS>_{ <+++> }^{ <++> } <++>",
    \'text'   : '\text{ <+++> } <++>',
    \
\'Section: Fancy Variables' : 'COMMENT',
    \'fa' : '\mathcal{A} ',
    \'fn' : '\mathcal{N} ',
    \'fp' : '\mathcal{P} ',
    \'fc' : '\mathcal{C} ',
    \'fm' : '\mathcal{M} ',
    \'ff' : '\mathcal{F} ',
    \'fb' : '\mathcal{B} ',
    \
\'Section: Encapsulating keywords' : 'COMMENT',
    \'bar'  : "\<ESC>F a\\bar{\<ESC>f i} ",
    \'hat'  : "\<ESC>F a\\hat{\<ESC>f i} ",
    \'star' : "\<BS>^* ",
    \'vec'  : "\<ESC>F a\\vec{\<ESC>f i} ",
    \
\'Section: Linear Algebra' : 'COMMENT',
    \'dim' : '\dim ',
    \'det' : '\det ',
    \'com' : "\<BS>^c ",
    \'matrix' : "\<CR>\\begin{bmatrix}\<CR><+++>\<CR>\\end{bmatrix}\<CR><++>",
    \'vdots' : '\vdots & ',
    \'ddots' : '\ddots & ',
    \
\'Section: Constants' : 'COMMENT',
    \'aleph' : '\aleph ',
    \'inf'   : '\infty ',
    \'one'   : '1 ',
    \'zero'  : '0 ',
    \'two'   : '2 ',
    \'three' : '3 ',
    \'four'  : '4 ',
    \
\'Section: Operators' : 'COMMENT',
    \'int'    : '\int^{ <+++> } <++>',
    \'dev'    : '\frac{d}{d<+++> } <++>',
    \'lim'    : '\lim_{ <+++> } <++>',
    \'sum'    : '\sum_{ <+++> }^{ <++> } <++>',
    \'prd'    : '\prod_{ <+++> }^{ <++> } <++>',
    \'limsup' : '\limsup ',
    \'liminf' : '\liminf ',
    \'sup'    : '\sup ',
\}
endif

" }}}


" LaTeX Mode Keywords {{{

if !exists('g:vimtexer_tex')
let g:vimtexer_tex = {
\'Section: Environments' : 'COMMENT',
    \'exe' : "\\begin{exercise}{<+++>}\<CR><++>\<CR>\\end{exercise}",
    \'prf' : "\\begin{proof}\<CR><+++>\<CR>\\end{proof}",
    \'thm' : "\\begin{theorem}\<CR><+++>\<CR>\\end{theorem}",
    \'lem' : "\\begin{lemma}\<CR><+++>\<CR>\\end{lemma}",
    \'que' : "\\begin{question}\<CR><+++>\<CR>\\end{question}",
    \'cor' : "\\begin{corollary}\<CR><+++>\<CR>\\end{corollary}",
    \'lst' : "\\begin{enumerate}[a)]\<CR>\\item <+++>\<CR>\\end{enumerate}",
    \'cd'  : "$$\<CR>\\begin{tikzcd}\<CR><+++>\<CR>\\end{tikzcd}\<CR>$$\<CR><++>",
    \
\'Section: Simple Aliases' : 'COMMENT',
    \'st'   : 'such that ',
    \'homo' : 'homomorphism ',
    \'iso'  : 'isomorphism ',
    \'iff'  : 'if and only if ',
    \'wlog' : 'without loss of generality ',
    \'Wlog' : 'Without loss of generality, ',
    \'siga' : '\(\sigma\)-algebra ',
    \'gset' : '\(G\)-set ',
    \
\'Section: Other Commands' : 'COMMENT',
    \'itm'   : '\item ',
    \'todo'  : '\textcolor{red}{TODO: <+++>} <++>',
    \'arrow' : '\arrow[ <+++> ] <++>',
    \'sect'  : '\section*{ <+++> }',
    \'qt'    : " ``<++>'' <++>",
    \'gtg'   : '\textcolor{purple}{ <+++> }',
    \
\'Section: Greek Letters' : 'COMMENT',
    \'alpha'   : '\(\alpha\) ',
    \'beta'    : '\(\beta\) ',
    \'gamma'   : '\(\gamma\) ',
    \'delta'   : '\(\delta\) ',
    \'epsilon' : '\(\varepsilon\) ',
    \'ge'      : '\(\varepsilon\) ',
    \'zeta'    : '\(\zeta\) ',
    \'eta'     : '\(\eta\) ',
    \'theta'   : '\(\theta\) ',
    \'iota'    : '\(\iota\) ',
    \'kappa'   : '\(\kappa\) ',
    \'lambda'  : '\(\lambda\) ',
    \'gl'      : '\(\lambda\) ',
    \'mu'      : '\(\mu\) ',
    \'nu'      : '\(\nu\) ',
    \'xi'      : '\(\xi\) ',
    \'omega'   : '\(\omega\) ',
    \'pi'      : '\(\pi\) ',
    \'rho'     : '\(\rho\) ',
    \'sigma'   : '\(\sigma\) ',
    \'tau'     : '\(\tau\) ',
    \'upsilon' : '\(\upsilon\) ',
    \'gu'      : '\(\upsilon\) ',
    \'phi'     : '\(\varphi\) ',
    \'chi'     : '\(\chi\) ',
    \'psi'     : '\(\psi\) ',
    \
\'Section: Single Lowercase Letters' : 'COMMENT',
    \'b'   : '\(b\) ',
    \'c'   : '\(c\) ',
    \'d'   : '\(d\) ',
    \'e'   : '\(e\) ',
    \'f'   : '\(f\) ',
    \'g'   : '\(g\) ',
    \'h'   : '\(h\) ',
    \'i'   : '\(i\) ',
    \'j'   : '\(j\) ',
    \'k'   : '\(k\) ',
    \'l'   : '\(l\) ',
    \'m'   : '\(m\) ',
    \'n'   : '\(n\) ',
    \'o'   : '\(o\) ',
    \'p'   : '\(p\) ',
    \'q'   : '\(q\) ',
    \'r'   : '\(r\) ',
    \'t'   : '\(t\) ',
    \'u'   : '\(u\) ',
    \'v'   : '\(v\) ',
    \'w'   : '\(w\) ',
    \'x'   : '\(x\) ',
    \'y'   : '\(y\) ',
    \'z'   : '\(z\) ',
    \
\'Section: Single Uppercase Letters' : 'COMMENT',
    \'B'   : '\(B\) ',
    \'C'   : '\(C\) ',
    \'D'   : '\(D\) ',
    \'E'   : '\(E\) ',
    \'F'   : '\(F\) ',
    \'G'   : '\(G\) ',
    \'H'   : '\(H\) ',
    \'J'   : '\(J\) ',
    \'K'   : '\(K\) ',
    \'L'   : '\(L\) ',
    \'M'   : '\(M\) ',
    \'N'   : '\(N\) ',
    \'O'   : '\(O\) ',
    \'P'   : '\(P\) ',
    \'Q'   : '\(Q\) ',
    \'R'   : '\(R\) ',
    \'S'   : '\(S\) ',
    \'T'   : '\(T\) ',
    \'U'   : '\(U\) ',
    \'V'   : '\(V\) ',
    \'W'   : '\(W\) ',
    \'X'   : '\(X\) ',
    \'Y'   : '\(Y\) ',
    \'Z'   : '\(Z\) ',
    \
\}
endif

" }}}
" }}}
