" File: vimtexer.vim
" Author: Bennett Rennier <barennier AT gmail.com>
" Website: brennier.com
" Description: Used to map keywords into other words, functions, keypresses,
" etc. while in insert mode. The main purpose is for writing LaTeX faster.
" Also includes different namespaces for inside and outside of math mode.
" Last Edit: Sept 17, 2016
 

" TODO: {{{
" " Use VIM dictionaries
" " Add . $ functions (perhaps as . and ')
" " " Transform them after jumping out of math mode
" " Add undo and redo keywords
" " Add del keyword
" " Improve command to change to \[ \]
" " Add search keywords?
" " Visually Select when JumpFuncing
" " Allow comments inside <+ +>
" " Fix Bug where special characters around <++> are replaced
" " Map infimum
" " Fix mod keyword
" " sq = squared or \mathbb{Q} ?
" }}}
 
" Special Key Assignment {{{
" Only map these functions if inside a tex file
" <C-r>=[function]() means to call a function and type what it returns as
" if you were actually presses the keys yourself
augroup filetype_tex
    autocmd!
    autocmd FileType tex inoremap _ <C-r>=MathStart()<CR>
    autocmd FileType tex inoremap <Space> <C-r>=ExpandWord()<CR>
augroup END
" }}}

" Main Functions {{{
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
" }}}

" Keywords {{{

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

" Math Mode Keywords {{{

"---------- Lowercase Greek Letters ----------

let s:math_alpha = '\alpha '
let s:math_beta = '\beta '
let s:math_gamma = '\gamma '
let s:math_delta = '\delta '
let s:math_epsilon = '\epsilon '
" typing 'ge' is faster than typing 'epsilon' for me
let s:math_ge = '\varepsilon '
let s:math_zeta = '\zeta '
let s:math_eta = '\eta '
let s:math_theta = '\theta '
let s:math_iota = '\iota '
let s:math_kappa = '\kappa '
let s:math_lambda = '\lambda '
" typing 'gl' is faster than typing 'lambda' for me
let s:math_gl = '\lambda '
let s:math_mu = '\mu '
let s:math_nu = '\nu '
let s:math_xi = '\xi '
let s:math_omega = '\omega '
let s:math_pi = '\pi '
let s:math_rho = '\rho '
let s:math_sigma = '\sigma '
let s:math_tau = '\tau '
let s:math_upsilon = '\upsilon '
" typing 'gu' is faster than typing 'upsilon' for me
let s:math_gu = '\upsilon '
let s:math_phi = '\varphi '
let s:math_chi = '\chi '
let s:math_psi = '\psi '

"---------- Uppercase Greek Letters ----------

let s:math_Alpha = '\Alpha '
let s:math_Beta = '\Beta '
let s:math_Gamma = '\Gamma '
let s:math_Delta = '\Delta '
let s:math_Epsilon = '\Epsilon '
let s:math_Zeta = '\Zeta '
let s:math_Eta = '\Eta '
let s:math_Theta = '\Theta '
let s:math_Iota = '\Iota '
let s:math_Kappa = '\Kappa '
let s:math_Lambda = '\Lambda '
let s:math_Mu = '\Mu '
let s:math_Nu = '\Nu '
let s:math_Xi = '\Xi '
let s:math_Omega = '\Omega '
let s:math_Pi = '\Pi '
let s:math_Rho = '\Rho '
let s:math_Sigma = '\Sigma '
let s:math_Tau = '\Tau '
let s:math_Upsilon = '\Upsilon '
let s:math_Phi = '\Phi '
let s:math_Chi = '\Chi '
let s:math_Psi = '\Psi '

"---------- Set Theory ----------

let s:math_sr = "\\mathbb{R} "
let s:math_sc = "\\mathbb{C} "
let s:math_Q = "\\mathbb{Q} "
let s:math_sn = "\\mathbb{N} "
let s:math_sz = "\\mathbb{Z} "
let s:math_subs = "\\subseteq "
let s:math_in = "\\in "
let s:math_nin = "\\not\\in "
let s:math_cup = "\\cup "
let s:math_cap = "\\cap "
let s:math_union = "\\cup "
let s:math_sect = "\\cap "
let s:math_smin = "\\setminus "
let s:math_set = "\\{ <+++> \\} <++>"
let s:math_card = "\\card{ <+++> } <++>"
let s:math_empty = "\\varnothing "
let s:math_pair = "( <+++> , <++> ) <++>"
let s:math_dots = "\\dots "

"---------- Logic ----------

let s:math_st = "\\divides "
let s:math_exists = "\\exists "
let s:math_nexists = "\\nexists "
let s:math_forall = "\\forall "
let s:math_implies = "\\implies "
let s:math_iff = "\\iff "
let s:math_and = "\\land "
let s:math_or = "\\lor "

"---------- Relations ----------

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
let s:math_neg = "\\neg "
let s:math_uarrow = "\\uparrow "
let s:math_darrow = "\\downarrow "

"---------- Operations ----------

let s:math_add = "+ "
let s:math_divides = "\\divides "
let s:math_min = "- "
let s:math_frac = "\\frac{ <+++> }{ <++> } <++>"
let s:math_recip = "\\frac{ 1 }{ <+++> } <++>"
let s:math_dot = "\\cdot "
let s:math_mult = "* "
let s:math_exp = "\<Left>^"
let s:math_pow = "\<Left>^"
let s:math_sq = "\<Left>^2 "
let s:math_inv = "\<BS>^{-1} "
let s:math_cross = "\\times "

"---------- Delimiters ----------

let s:math_para = "\\left( <+++> \\right) <++>"
let s:math_sb = "\\left[ <+++> \\right] <++>"
let s:math_brac = "\\left\\{ <+++> \\right\\} <++>"
let s:math_group = "{ <+++> } <++>"
let s:math_angle = "\\angle{ <+++> } <++>"
let s:math_abs = "\\abs{ <+++> } <++>"

"---------- Group Theory ----------

let s:math_iso = "\\sim "
let s:math_niso = "\\nsim "
let s:math_subg = "\\leq "
let s:math_nsubg = "\\trianglelefteq "
let s:math_mod = '/ '
let s:math_aut = '\aut '

"---------- Functions ----------

let s:math_to = "\\to "
let s:math_comp = "\\circ "
let s:math_of = "\\left( <+++> \\right) <++>"
let s:math_sin = "\\sin{ <+++> } <++>"
let s:math_cos = "\\cos{ <+++> } <++>"
let s:math_tan = "\\tan{ <+++> } <++>"
let s:math_ln = "\\ln{ <+++> } <++>"
let s:math_log = "\\log{ <+++> } <++>"
let s:math_dfunc = "<+++> : <++> \\to <++>"
let s:math_sqrt = "\\sqrt{ <+++> } <++>"
let s:math_img = '\img '
let s:math_ker = '\ker '
let s:math_case = "\\begin{cases} <+++> \\end{cases} <++>"

"---------- LaTeX commands ----------

let s:math_big = "è\<ESC>/\\\\)\<CR>lr]?\\\\(\<CR>lr[llcw"
let s:math_sub = "\<BS>_"
let s:math_ud = "\<BS>_{ <+++> }^{ <++> } "
let s:math_text = "\\text{ <+++> } <++>"

"---------- Fancy Variables ----------

let s:math_fa = "\\mathcal{A} "
let s:math_fn = "\\mathcal{N} "
let s:math_fp = "\\mathcal{P} "
let s:math_fc = "\\mathcal{C} "
let s:math_fm = "\\mathcal{M} "
let s:math_ff = "\\mathcal{F} "
let s:math_fb = "\\mathcal{B} "

"---------- Encapsulating keywords ----------

let s:math_bar = "\<ESC>F a\\bar{\<ESC>f i} "
let s:math_hat = "\<ESC>F a\\hat{\<ESC>f i} "
let s:math_star = "\<ESC>F a\\star{\<ESC>f i} "
let s:math_vec = "\<ESC>F a\\vec{\<ESC>f i} "

"---------- Linear Algebra ----------

let s:math_dim = '\dim '
let s:math_det = '\det '
let s:math_com = "\<BS>^c "

"---------- Constants ----------

let s:math_aleph = '\aleph '
let s:math_inf = '\infty '
let s:math_one = '1 '
let s:math_zero = '0 '
let s:math_two = '2 '
let s:math_three = '3 '
let s:math_four = '4 '

"---------- Operators ----------

let s:math_int = "\\int^{ <+++> } <++>"
let s:math_dev = "\\frac{d}{d<+++> } <++>"
let s:math_lim = "\\lim_{ <+++> } <++>"
let s:math_sum = "\\sum_{ <+++> }^{ <++> } <++>"
let s:math_prd = "\\prod_{ <+++> }^{ <++> } <++>"
let s:math_limsup = "\\limsup "
let s:math_liminf = "\\liminf "
let s:math_sup = "\\sup "
" let s:math_inf = "\\inf "

" }}}


" LaTeX Mode Keywords {{{

"---------- Environments ----------
let s:tex_exe = "\\begin{exercise}{ <+++> }\<CR><++>\<CR>\\end{exercise}\<CR><++>"
let s:tex_prf = "\\begin{proof}\<CR><+++>\<CR>\\end{proof}\<CR><++>"
let s:tex_thm = "\\begin{theorem}\<CR><+++>\<CR>\\end{theorem}\<CR><++>"
let s:tex_lem = "\\begin{lemma}\<CR><+++>\<CR>\\end{lemma}\<CR><++>"
let s:tex_que = "\\begin{question}\<CR><+++>\<CR>\\end{question}\<CR><++>"
let s:tex_cor = "\\begin{corollary}\<CR><+++>\<CR>\\end{corollary}\<CR><++>"
let s:tex_lst = "\\begin{enumerate}[a)]\<CR>\\item <+++>\<CR>\\end{enumerate}\<CR><++>"
let s:tex_cd = "$$\<CR>\\begin{tikzcd}\<CR><+++>\<CR>\\end{tikzcd}\<CR>$$\<CR><++>"

"---------- Simple Aliases ----------
let s:tex_st = "such that "
let s:tex_homo = "homomorphism "
let s:tex_iso = "isomorphism "
let s:tex_iff = "if and only if "
let s:tex_wlog = "without loss of generality "
let s:tex_Wlog = "Without loss of generality, "
let s:tex_siga = "\\(\\sigma\\)-algebra "
let s:tex_gset = "\\(G\\)-set "

"---------- Other Commands ----------
let s:tex_itm = "\\item "
let s:tex_todo = "\\textcolor{red}{TODO: <+++>} <++>"
let s:tex_arrow = "\\arrow[ <+++> ] <++>"
let s:tex_sect = "\\section*{ <+++> }"
let s:tex_qt = " ``<++>'' <++>"

" }}}
" }}}
