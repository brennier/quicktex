" Only map these functions if inside a tex file
" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually presses the keys yourself
augroup filetype_tex
    autocmd!
    autocmd FileType tex inoremap _ <C-r>=MathStart()<CR>
    autocmd FileType tex inoremap <Space> <C-r>=ExpandWord()<CR>
augroup END

" Function that starts mathmode
function! MathStart()
    " If already in mathmode, just return a space. This is useful if you want
    " to normally type a keyword. That way, by pressing _, you can space
    " without keyword expansion
    if &ft == 'math'
        return " "
    else
        " If the last character is a space, then start math mode and go inside
        " the brackets
        if getline(".")[col(".")-2] == " "
            set filetype=math
            set syntax=tex
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
    " If there's a <++> to jump to in the line, then jump to it
	if getline('.') =~ '<++>'
        return "\<Right>\<BS>\<ESC>/<++>\<CR>cw"
    else
    " If there is no <++> on the current line, then exit math mode and jump to
    " right after \)
        set filetype=tex
        execute "normal! / \\\\)\<CR>"
        return "\<BS>\<Right>\<Right>\<Right> "
    endif
endfunction

function! ExpandWord()
    " Move left so that the cursor is over the word and then expand the word
	normal! h
	let word = expand('<cword>')

	let rhs = ''

    " If the last character was a space, then JumpFunc
    " It's -1 instead of -2 because we already moved to the left one space
    if getline('.')[col(".")-1] == " "
        return JumpFunc()
    endif
    
    " Check to see if there is a mapping for the word under that filetype
    if exists('s:'.&ft.'_'.word)
            exe 'let rhs = s:'.&ft.'_'.word
    " If there isn't, check if there's a general mapping for that word
    elseif exists('s:_'.word)
		    exe 'let rhs = s:_'.word
    endif

    " If we found a match...
    if rhs != ''
        let jumpBack = ""
    	" If the RHS contains the identifier "<+++>", then your cursor will be
        " placed there automatically after the subsitution. Notice that, in
        " general, the JumpFunc goes to "<++>" instead
    	if rhs =~ '<+++>'
            let jumpBack = "\<ESC>?<+++>\<CR>cw"
        endif
        " This is a hack for one letter keywords. It types an extra letter and
        " escapes, so now it's two letters
        let hack = "a\<ESC>"
        " Do the hack, then delete the word and go to insert mode, then type
        " out the right hand side then jump back to "<+++>"
    	return hack."ciw".rhs.jumpBack
	else
        " Remember, we moved left and are over the last character of the word,
        " so f there is no match, then move right and put the original space character. 
    	return "\<Right> "
    endif
endfunction

" Keyword mappings are of the following form. Replace what's in the []'s
" let s:[filetype]_[keyword] = "[result]"
" OR as the following
" let s:[filetype]_[keyword] = '[result]'
"
" In the first form, \'s need to be escape (i.e. "\\"), but you can use
" nonalphanumeric keypresses, like "\<CR>" for Enter or "\<BS>" for backspace
" or even "\<Right>" and "\<Left>" for arrow keys
" 
" In the second form, it's a literal substitution

"---------------------------------- Functions ----------------------------------
" Greek Letters Lowercase (g)
let s:math_ga = "\\alpha "
let s:math_gb = "\\beta "
let s:math_gg = "\\gamma "
let s:math_gd = "\\delta "
let s:math_ge = "\\epsilon "
let s:math_gz = "\\zeta "
let s:math_ge = "\\eta "
let s:math_gt = "\\theta "
let s:math_gi = "\\iota "
let s:math_gk = "\\kappa "
let s:math_gl = "\\lambda "
let s:math_gm = "\\mu "
let s:math_gn = "\\nu "
let s:math_gx = "\\xi "
let s:math_go = "\\omega "
let s:math_gp = "\\pi "
let s:math_gr = "\\rho "
let s:math_gs = "\\sigma "
let s:math_gt = "\\tau "
let s:math_gu = "\\upsilon "
let s:math_gf = "\\phi "
let s:math_phi = "\\phi "
let s:math_gc = "\\chi "
let s:math_gi = "\\psi "

" Greek Letters Uppercase (G)
let s:math_Ga = "\\Alpha "
let s:math_Gb = "\\Beta "
let s:math_Gg = "\\Gamma "
let s:math_Gd = "\\Delta "
let s:math_Ge = "\\Epsilon "
let s:math_Gz = "\\Zeta "
let s:math_Ge = "\\Eta "
let s:math_Gt = "\\Theta "
let s:math_Gi = "\\Iota "
let s:math_Gk = "\\Kappa "
let s:math_Gl = "\\Lambda "
let s:math_Gm = "\\Mu "
let s:math_Gn = "\\Nu "
let s:math_Gx = "\\Xi "
let s:math_Go = "\\Omega "
let s:math_Gp = "\\Pi "
let s:math_Gr = "\\Rho "
let s:math_Gs = "\\Sigma "
let s:math_Gt = "\\Tau "
let s:math_Gu = "\\Upsilon "
let s:math_Gf = "\\Phi "
let s:math_Gc = "\\Chi "
let s:math_Gi = "\\Psi "

" Common Operations
let s:math_divides = "\\divides "
let s:math_to = "\\to "
let s:math_comp = "\\circ "
let s:math_pair = "( <+++> , <++> ) <++>"

" Common Sets (s)
let s:math_R = "\\mathbb{R} "
let s:math_C = "\\mathbb{C} "
let s:math_Q = "\\mathbb{Q} "
let s:math_N = "\\mathbb{N} "
let s:math_Z = "\\mathbb{Z} "
let s:math_st = "\\divides "
let s:math_in = "\\in "
let s:math_nin = "\\not\\in "
let s:math_subs = "\\subseteq "
let s:math_sub = "\<BS>_"
let s:math_empty = "\\varnothing "
let s:math_union = "\\cup "
let s:math_sect = "\\cap "
let s:math_minus = "\\setminus "

" Relations (r)
let s:math_lt = "< "
let s:math_gt = "> "
let s:math_leq = "\\leq "
let s:math_geq = "\\geq "
let s:math_eq = "= "
let s:math_nl = "\\nless "
let s:math_ng = "\\ngtr "
let s:math_nleq = "\\nleq "
let s:math_ngeq = "\\ngeq "
let s:math_neq = "\\neq "
let s:math_iso = "\\sim "
let s:math_niso = "\\nsim "
let s:math_neg = "\\neg "

" Logic (l)
let s:math_exists = "\\exists "
let s:math_nexists = "\\nexists "
let s:math_fa = "\\forall "
let s:math_leftarrow = "\\Longleftarrow "
let s:math_implies = "\\implies "
let s:math_iff = "\\iff "
let s:math_and = "\\land "
let s:math_or = "\\lor "

" Operations (o)
let s:math_add = "+ "
let s:math_min = "- "
let s:math_frac = "\\frac{ <+++> }{ <++> } <++>"
let s:math_recip = "\\frac{ 1 }{ <+++> } <++>"
let s:math_dot = "\\cdot "
let s:math_star = "* "
let s:math_exp = "\<Left>^"
let s:math_sq = "\<Left>^2 "

" Delimiters (d)
let s:math_para = "\\left( <+++> \\right) <++>"
let s:math_sb = "\\left[ <+++> \\right] <++>"
let s:math_brac = "\\left\\{ <+++> \\right\\} <++>"
let s:math_group = "{ <+++> } <++>"
let s:math_set = "\\{ <+++> \\} <++>"
let s:math_abs = "\\left| <+++> \\right| <++>"
let s:math_angle = "\\left\\langle <+++> \\right\\rangle) <++>"

"""" OTHER """"

" Common Functions (f)
let s:math_fe = "e^{ <+++> } <++>"
let s:math_fs = "\\sin{ <+++> } <++>"
let s:math_fc = "\\cos{ <+++> } <++>"
let s:math_ft = "\\tan{ <+++> } <++>"
let s:math_fn = "\\ln{ <+++> } <++>"
let s:math_fl = "\\log{ <+++> } <++>"

" Special Constants (c)
let s:math_aleph = "\\aleph"
let s:math_inf = "\\infty"
    
" Very Important Functions
let s:math_inv = "\<BS>^{-1} "
let s:math_text = "\\text{ <+++> } <++>"
let s:math_math = "\<CR>\\[\<CR><+++>\<CR>\\] <++>"
let s:math_dfunc = "<+++> : <++> \\to <++>"
let s:math_func = "<+++> ( <++> ) <++>"

" LaTeX Commands
" Sections
let s:tex_exe = "\\begin{exercise}{ <+++> }\<CR><++>\<CR>\\end{exercise}\<CR><++>"
let s:tex_prf = "\\begin{proof}\<CR><+++>\<CR>\\end{proof}\<CR><++>"
let s:tex_thm = "\\begin{theorem}\<CR><+++>\<CR>\\end{theorem}\<CR><++>"
let s:tex_lem = "\\begin{lemma}\<CR><+++>\<CR>\\end{lemma}\<CR><++>"
let s:tex_que = "\\begin{question}\<CR><+++>\<CR>\\end{question}\<CR><++>"
let s:tex_cor = "\\begin{corollary}\<CR><+++>\<CR>\\end{corollary}\<CR><++>"
let s:tex_lst = "\\begin{enumerate}[a)]\<CR>\\item <+++>\<CR>\\end{enumerate}\<CR><++>"
let s:tex_itm = "\\item "
let s:tex_cd = "$$\<CR>\\begin{tikzcd}\<CR><+++>\<CR>\\end{tikzcd}\<CR>$$\<CR><++>"
let s:tex_todo = "% TODO: <+++>"
let s:tex_today = "\\section{ \<c-r>=strftime('%B %d %Y')\<cr> }\<CR>\<CR>"
let s:tex_arrow = "\\arrow[ <+++> ]"
let s:tex_diagram = "\\begin{tikz-cd}\<CR>\t<+++>\<CR>\<BS>\\end{tikz-cd}\<CR><++>"
let s:tex_comment = "% "

" Expressions (e)
let s:math_int = "\\int^{<+++>}_{<++>}{<++>} <++>"
let s:math_dev = "\\frac{d}{d<+++>} <++>"
let s:math_lim = "\\lim_{<+++>} <++>"
let s:math_sum = "\\sum_{<+++>}^{<++>} <++>"
let s:math_prd = "\\prod_{<+++>}^{<++>} <++>"

let s:math_dots = "\\dots "
let s:math_one = "1 "
let s:math_zero = "0 "
let s:math_two = "2 "
let s:math_sqrt = "\\sqrt{ <+++> } <++>"
let s:math_cross = "\\times "

"    " Encapsulate last character (')
"    au VimEnter * call IMAP("'m "," \<Esc>F a$\<Esc>lf i$ ",'tex')
"    au VimEnter * call IMAP("'b "," \<Esc>F a\\bf{\<Esc>f i} ",'tex')
"    au VimEnter * call IMAP("'h "," \<Esc>F a\\^{\<Esc>f i} ",'tex')
"    au VimEnter * call IMAP("'a "," \<Esc>F a\\overrightarrow{\<Esc>f i} ",'tex')
"    au VimEnter * call IMAP("'l "," \<Esc>F a\\bar{\<Esc>f i} ",'tex')
"    au VimEnter * call IMAP("'i "," \<Esc>F a{\<Esc>lf i}^{-1} ",'tex')
"    au VimEnter * call IMAP("'2 "," \<Esc>F a{\<Esc>lf i}^{2} ",'tex')
"    au VimEnter * call IMAP("'p "," \<Esc>F a(\<Esc>lf i) ",'tex')
"    au VimEnter * call IMAP("'l "," \<Esc>F a|\<Esc>lf i| ",'tex')
"    au VimEnter * call IMAP("'r "," \<Esc>F a\\sqrt{\<Esc>lf i} ",'tex')
"    au VimEnter * call IMAP("'P "," \<Esc>F a{\<Esc>lf i}^{<++>} <++>",'tex')
"    au VimEnter * call IMAP("'L "," \<Esc>F{i\\bar\<Esc>f}a ",'tex')
"    au VimEnter * call IMAP("}m ","}\<Esc>%r$\<C-o>r$a ",'tex')
"    au VimEnter * call IMAP("}p ","}\<Esc>%r(\<C-o>r)a ",'tex')
"    au VimEnter * call IMAP("}sin ","}\<Esc>%xi\\sin(\<Esc>f}r)a ",'tex')
"    au VimEnter * call IMAP("{ ","{ <++> }<++>",'tex')
"    au VimEnter * call IMAP("}m2 ","}\<Esc>%xi\\left[\\begin{matrix}\<Esc>f,r&f,r\\lr\\f,r&f}xi\\\\ \\end{bmatrix} \\right] ",'tex')
"   " au VimEnter * call IMAP("}m2,m ","}\<Esc>%xi$\\left[\\begin{matrix}\<Esc>f,r&f,r\\lr\\f,r&f}xi\\\\ \\end{bmatrix} \\right]$ ",'tex')
"    au VimEnter * call IMAP(",m ","\<Esc>F{i$ \<Esc>f}Ea<++> $ <++>",'tex')

    " Encapsulate last character AND in math quotes ('m)
"    au VimEnter * call IMAP("'b'm "," \<Esc>F a$\\bf{\<Esc>f i}$ ",'tex')
"    au VimEnter * call IMAP("'h'm "," \<Esc>F a$\\^{\<Esc>f i}$ ",'tex')
"    au VimEnter * call IMAP("'a'm "," \<Esc>F a$\\overrightarrow{\<Esc>f i}$ ",'tex')
"    au VimEnter * call IMAP("'l'm "," \<Esc>F a$\\bar{\<Esc>f i}$ ",'tex')
"    au VimEnter * call IMAP("'i'm "," \<Esc>F a${\<Esc>lf i}^{-1}$ ",'tex')
"    au VimEnter * call IMAP("'2'm "," \<Esc>F a${\<Esc>lf i}^{2}$ ",'tex')
"    au VimEnter * call IMAP("'p'm "," \<Esc>F a$(\<Esc>lf i)$ ",'tex')
"    au VimEnter * call IMAP("'l'm "," \<Esc>F a$|\<Esc>lf i|$ ",'tex')
"
    
"inoremap _ <C-r>=CheckInMathMode()<CR>
"" let g:inMathMode = "0"
"
"" Checks if one is between \( .. \)
"" If so, then InMathMode is executed
"" If not, then NotInMathMode is executed
"function! CheckInMathMode()
"    let line = getline('.')
"    if line =~ "\(.*\)"
"        let currentcolumn = virtcol('.')
"        execute "normal! ?\\\\(\<CR>"
"        let begincolumn = virtcol('.')
"        execute "normal! /\\\\)\<CR>"
"        let endcolumn = virtcol('.')
"        let returnpos = "\<ESC>".currentcolumn."|a"
"        if currentcolumn < endcolumn && currentcolumn > begincolumn
"            return returnpos.InMathMode()
"        else
"            return returnpos.NotInMathMode()
"        endif
"    else
"        return NotInMathMode()
"    endif
"endfunction
"
"function! InMathMode()
"    if getline(".")[col(".")-2] == " "
"        return Jump()
"    else
"        return ""
"    endif
"endfunction
"
"function! NotInMathMode()
"    if getline(".")[col(".")-2] == " "
"        return "\<BS>\\(  \\) \<Left>\<Left>\<Left>\<Left>"
"    else
        " Encapsulate last word into math mode
"    return "\<ESC>ciw\\(\<ESC>pa\\) "
"endfunction
"
"function! Jump()
"	if getline('.') =~ '<++>'
"        return "\<ESC>x/<++>\<CR>cw"
"    else
"        execute "normal! /\\\\)\<CR>"
"        return "\<Right>\<Right> "
"    endif
"endfunction
