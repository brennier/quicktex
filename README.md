## Vimtexer is a template expander for quickly writing LaTeX

Basically, Vimtexer allows you to set keywords to activate arbitrary Vim code whenever they are typed in insert mode. These expansions are filetype specifc. For example, if you using the default dictionaries, then typing 'prf' in a tex file will expand into:

```tex
\begin{proof}
    *
\end{proof}
```

After an expansion, your cursor is placed in the place of the `*` and you will remain in insert mode so that you can continue to seamlessly type. All expansions are triggered automatically after typing a space.

## Configuration

Once you have added vimtexer to your vim plugins (either through vundle, vim-plug, pathogen, or even just copying the files manually), then you need to make a dictionary for each filetype you want to use vimtexer with. There are default dictionaries available for tex files, but I highly recommend that you create your own as these dictionaries may be changed as I try to figure out what works best.

When you make a dictionary, the variable name should be `g:vimtexer_<filetype>`. There is one expection to this rule: the dictionary `g:vimtexer_math`. This dictionary is used instead of `g:vimtexer_tex` when you are inbetween math delimiters.

Keywords can be any string without whitespace. Expansions can either be a literal string (using single quotes) or a string with keypress expansions (using double quotes). Keypress expansions are things like `\<CR>`, `\<BS>`, or `\<Right>` that one would find in vim remappings. Keep in mind that `\`'s need to be escaped (i.e. `\\`) when using double quoted strings.

If the expansion string has a `<+++>` in it, then your cursor will be placed there after the expansion. This plugin also features a jump function support (only for latex files at the moment). That is, every time you hit double space, you will jump to the next `<++>` (note that this is different from `<+++>`). This feature can be turned off by adding `let g:vimtexer_jumpfunc = 0` in your vimrc. Thus, you can add `<++>`'s to keyword expansions in order to easily jump around afterwards.

An example dictionary:
```vim
let g:vimtexer_tex = {
    \'alpha' : '\(\alpha\) ',
    \'prf'   : "\\begin{proof}\<CR><+++>\<CR>\\end{proof}"
    \'frac'  : "\\(\\frac{<+++>}{<++>}\\) <++>"
\}
```
This dictionary would expand `alpha` as `\(\alpha\)` and would expand `prf` in the manner shown in the first section of this readme. `frac` would be expanded as `\(\frac{*}{<++>} <++>\)` (where `*` is your cursor position), allowing you to easily jump to the next argument and then jump out of math mode altogether. As you can see, this can significantly speed up your Latex typing speed. Keep in mind that you need backslashs at the beginning of each line when you do muiti-line definitions in Vimscript.

For more information, see the heavily documented source code.

## Why should I use Vimtexer instead of another plugin?

1. Vimtexer has a separate namespace for math mode expansions. This truly is the best feature. It will help you type math in Latex faster than you ever thought possible.

2. Vimtexer is small and simple. There are literally only two functions in the entire source. Altogether, the source code a little over 100 lines, well over half of which are just comments and blank lines. If you have any experience with writing a vim plugin, then you'll probably understand this plugin. Setting new keywords is as easy as making a dictionary in your vimrc.

3. Vimtexer is FAST. Since the code is so small and written completely in Vimscript, Vimtexer expands keywords instanteously. Programming similar functionality into a snippets plugin would be significantly slower, especially when you include the context dependence for math mode.

For a video demonstration of what it's like to use vimtexer, click the image below:
[![https://www.youtube.com/watch?v=z03-e8zCkl8](https://img.youtube.com/vi/z03-e8zCkl8/0.jpg)](https://www.youtube.com/watch?v=z03-e8zCkl8)

