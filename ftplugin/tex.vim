" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Maps keywords into other words, functions, keypresses, etc.
" while in insert mode. The main purpose is for writing LaTeX faster. Also
" includes different namespaces for inside and outside of math mode.
" Last Edit: Oct 23, 2016

if !exists('g:vimtexer_mathkeyword')
    let g:vimtexer_mathkeyword='_'
endif

if !exists('g:vimtexer_mathobjects')
    let g:vimtexer_mathobjects = 1
endif

if g:vimtexer_mathobjects
    onoremap am :<c-u>execute "normal! /\\\\)\\\\|\\\\]\rlv?\\\\(\\\\|\\\\[\r"<CR>
    onoremap im :<c-u>execute "normal! /\\\\)\\\\|\\\\]\rhv?\\\\(\\\\|\\\\[\r2l"<CR>
    onoremap ap :<c-u>execute "normal! /\\\\right)\rf)v?\\\\left(\r"<CR>
    onoremap ip :<c-u>execute "normal! /\\\\right)\rhv?\\\\left(\r6l"<CR>
    onoremap is :<c-u>execute "normal! ?\\\\section\rjV/\\\\section\rk"<CR>
    onoremap as :<c-u>execute "normal! ?\\\\section\rV/\\\\section\rk"<CR>
endif

" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually presses the keys yourself
inoremap <silent> <Space> <C-r>=ExpandWord()<CR>

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

function! ExpandWord()
    " Get the current line and the column number of the last character
    let line = getline('.')
    let column = col('.')-2

    " If the last character was a space, then delete it and jump to the next
    " instance of <+.*+>
    if line[column] == ' '
        return "\<BS>\<ESC>/<+.*+>\<CR>cf>"
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

    " Checks it see if your in mathmode, if so, use the math dictionary. If
    " not, check if a dictionary exists for the given filetype. If the
    " dictionary doesn't exist, then put the original space.
    if InMathMode()
        let dictionary = g:vimtexer_math
    elseif exists('g:vimtexer_'.&ft)
        execute 'let dictionary = g:vimtexer_'.&ft
    else
        return gofwd.' '
    endif

    " Get the result of the keyword. If the keyword doesn't exist in the
    " dictonary, return the empty string ''
    let rhs = get(dictionary, word,'')

    " If we found a match in the dictionary
    if rhs != ''
        " String of backspaces to delete word
        let delword = substitute(word, '.', "\<BS>", 'g')
        " If the RHS contains the identifier "<+++>", then your cursor will be
        " placed there automatically after the subsitution.
        if rhs =~ '<+++>'
            let jumpBack = "\<ESC>?<+++>\<CR>cf>"
        else
            let jumpBack = ''
        endif
        " Go forward, delete the original word, replace it with the result of
        " the dictionary, and then jump back if needed
        return gofwd.delword.rhs.jumpBack
    else
        " If the dictionary doesn't exist, go forward and put the original
        " space
        return gofwd.' '
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
    \'ga'      : '\alpha ',
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
    \'bf'    : '\mathbb{F} ',
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
    \'exp'   : "\<BS>^{<+++>} <++>",
    \'pow'   : "\<BS>^{<+++>} <++>",
    \'sq'    : "\<BS>^2 ",
    \'cubed' : "\<BS>^3 ",
    \'inv'   : "\<BS>^{-1} ",
    \'cross' : '\times ',
    \
\'Section: Delimiters' : 'COMMENT',
    \'para'  : '\left( <+++> \right) <++>',
    \'sb'    : '\left[ <+++> \right] <++>',
    \'brac'  : '\left\{ <+++> \right\} <++>',
    \'group' : '{<+++>} <++>',
    \'angle' : '\angle{<+++>} <++>',
    \'abs'   : '\abs{<+++>} <++>',
    \
\'Section: Group Theory' : 'COMMENT',
    \'ord'   : '\ord{ <+++> } <++>',
    \'iso'   : '\iso ',
    \'sdp'   : '\rtimes ',
    \'niso'  : '\niso ',
    \'subg'  : '\leq ',
    \'nsubg' : '\trianglelefteq ',
    \'mod'   : '/ ',
    \'aut'   : '\aut ',
    \'hom'   : '\hom ',
    \
\'Section: Functions' : 'COMMENT',
    \'to'     : '\to ',
    \'mapsto' : '\mapsto ',
    \'comp'   : '\circ ',
    \'of'     : "\<BS>(<+++>) <++>",
    \'sin'    : '\sin{ <+++> } <++>',
    \'cos'    : '\cos{ <+++> } <++>',
    \'tan'    : '\tan{ <+++> } <++>',
    \'gcd'    : '\gcd( <+++> , <++> ) <++>',
    \'ln'     : '\ln{ <+++> } <++>',
    \'log'    : '\log{ <+++> } <++>',
    \'dfunc'  : '<+++> : <++> \to <++>',
    \'sqrt'   : '\sqrt{ <+++> } <++>',
    \'img'    : '\img ',
    \'ker'    : '\ker ',
    \'case'   : '\begin{cases} <+++> \end{cases} <++>',
    \
\'Section: LaTeX commands' : 'COMMENT',
    \'big'    : "<+++>\<ESC>/\\\\)\<CR>lr]a\<CR>\<ESC>?\\\\(\<CR>lr[",
    \'sub'    : "\<BS>_{<+++>} <++>",
    \'sone'   : "\<BS>_1 ",
    \'stwo'   : "\<BS>_2 ",
    \'sthree' : "\<BS>_3 ",
    \'sfour'  : "\<BS>_4 ",
    \'ud'     : "\<BS>_{<+++>}^{<++>} <++>",
    \'text'   : '\text{<+++>} <++>',
    \
\'Section: Fancy Variables' : 'COMMENT',
    \'fa' : '\mathcal{A} ',
    \'fn' : '\mathcal{N} ',
    \'fp' : '\mathcal{P} ',
    \'ft' : '\mathcal{T} ',
    \'fc' : '\mathcal{C} ',
    \'fm' : '\mathcal{M} ',
    \'ff' : '\mathcal{F} ',
    \'fb' : '\mathcal{B} ',
    \'fl' : '\mathcal{L} ',
    \
\'Section: Encapsulating keywords' : 'COMMENT',
    \'bar'  : "\<ESC>F a\\bar{\<ESC>f i} ",
    \'hat'  : "\<ESC>F a\\hat{\<ESC>f i} ",
    \'star' : "\<BS>^* ",
    \'vec'  : "\<ESC>F a\\vec{\<ESC>f i} ",
    \
\'Section: Linear Algebra' : 'COMMENT',
    \'dim'    : '\dim ',
    \'det'    : '\det ',
    \'GL'     : '\text{GL} ',
    \'SL'     : '\text{SL} ',
    \'com'    : "\<BS>^c ",
    \'matrix' : "\<CR>\\begin{bmatrix}\<CR><+++>\<CR>\\end{bmatrix}\<CR><++>",
    \'vdots'  : '\vdots & ',
    \'ddots'  : '\ddots & ',
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
    \'int'    : '\int\! <+++> \mathop{d <++>} <++>',
    \'dev'    : '\frac{d}{d<+++> } <++>',
    \'lim'    : '\lim_{ <+++> } <++>',
    \'sum'    : '\sum_{ <+++> }^{ <++> } <++>',
    \'prd'    : '\prod_{ <+++> }^{ <++> } <++>',
    \'limsup' : '\limsup ',
    \'liminf' : '\liminf ',
    \'sup'    : '\sup ',
    \'sinf'   : '\inf ',
    \
\'Section: Diagrams' : 'COMMENT',
    \'arrow' : '\arrow[<+++>] <++>',
    \
\}
endif

" }}}

" LaTeX Mode Keywords {{{

if !exists('g:vimtexer_tex')
let g:vimtexer_tex = {
    \g:vimtexer_mathkeyword : '\( <+++> \) <++>',
\'Section: Environments' : 'COMMENT',
    \'exe' : "\\begin{exercise}{<+++>}\<CR><++>\<CR>\\end{exercise}",
    \'prf' : "\\begin{proof}\<CR><+++>\<CR>\\end{proof}",
    \'thm' : "\\begin{theorem}\<CR><+++>\<CR>\\end{theorem}",
    \'lem' : "\\begin{lemma}\<CR><+++>\<CR>\\end{lemma}",
    \'que' : "\\begin{question}\<CR><+++>\<CR>\\end{question}",
    \'cor' : "\\begin{corollary}\<CR><+++>\<CR>\\end{corollary}",
    \'lst' : "\\begin{enumerate}[a)]\<CR>\\item <+++>\<CR>\\end{enumerate}",
    \'cd'  : "\\[\\begin{tikzcd}\<CR><+++>\<CR>\\end{tikzcd}\\]\<CR><++>",
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
    \'ac'   : 'Axiom of Choice ',
    \'ae'   : 'almost everywhere ',
    \'bd'   : 'boundary ',
    \'card' : 'cardinality ',
    \'char' : 'characteristic ',
    \'ker'  : 'kernel ',
    \'im'   : 'image ',
    \'def'  : 'define ',
    \'deg'  : 'degree ',
    \'det'  : 'determinant ',
    \'dim'  : 'dimension ',
    \'eqn'  : 'equation ',
    \'tfdc' : 'the following diagram commute: ',
    \'gal'  : 'Galois group ',
    \'gcd'  : 'greatest common divisor ',
    \'inf'  : 'infimum ',
    \'int'  : 'interior ',
    \'ext'  : 'exterior ',
    \'lcm'  : 'least common multiple ',
    \'lhs'  : 'left-hand side ',
    \'lim'  : 'limit ',
    \'sup'  : 'supremum ',
    \'mx'   : 'matrix ',
    \'pf'   : 'proof ',
    \'qed'  : 'This proves the statement. ',
    \'resp' : 'respectively ',
    \'rhs'  : 'right-hand side ',
    \'rtp'  : 'required to prove ',
    \'soln' : 'solution ',
    \'sp'   : 'span ',
    \'cbpbsa' : 'can be proved by similar argument ',
    \'tfae' : 'the following are equivalent ',
    \'wd'   : 'well-defined ',
    \'wma'  : 'we may assume ',
    \'wrt'  : 'with respect to ',
    \'wtp'  : 'want to prove ',
    \'wts'  : 'want to show ',
    \'vp'   : 'vector space ',
    \'fd'   : 'finite-dimensional ',
    \'mble' : 'measurable ',
    \'fa' : 'for all ',
    \'fs' : 'for some ',
    \
\'Section: Other Commands' : 'COMMENT',
    \'itm'   : '\item ',
    \'todo'  : '\textcolor{red}{TODO: <+++>} <++>',
    \'sect'  : "\\section*{<+++>}\<CR><++>",
    \'para'  : '(<+++>) <++>',
    \'qt'    : " ``<+++>'' <++>",
    \'gtg'   : '\textcolor{purple}{<+++>}',
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
