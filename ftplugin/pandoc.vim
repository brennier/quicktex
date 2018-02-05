" Set g:quicktex_pandoc_enable = 0 if you don't want the math dictionary to be
" enabled in pandoc files
if !get(g:, 'quicktex_pandoc_enable', 1)
    finish
endif

if exists('g:quicktex_pandoc') && !exists('g:quicktex_math')
    let g:quicktex_math = {}
elseif !exists('g:quicktex_pandoc') && exists('g:quicktex_math')
    let g:quicktex_pandoc = {}
endif
