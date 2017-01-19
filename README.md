## Vimtexer is a template expander for quickly writing LaTeX

Preset keywords are expanded into other literal keypresses. These expansions are filetype specifc. For example, if you using the default dictionaries, then typing 'prf' in a tex file will replace the word and expand into:

```tex
\begin{proof}
    <+++>
\end{proof}
```

After an expansion, your cursor is placed in the place of the `<+++>` and you will remain in insert mode in order to continue seamlessly typing. This expansion occurs automatically after typing a space.

## Configuration

Once you have added vimtexer to your vim plugins (either through vundle, vim-plug, pathogen, or even just copying the files manually), then you need to make a dictionary for each filetype you want to use vimtexer with. There are default dictionaries for tex files, but these can be changed at any point, so it's highly recommended that you create your own. The dictionaries should be named `g:vimtexer_<filetype>`, with one expection: the dictionary `g:vimtexer_math`, which represents expansions that should only occur when in math mode in latex files. The keywords can be any string without whitespace and resulting values can be either literal strings (using single quotes) or a string with keypress expansions (using double quotes). Keypress expansions are things like `\<CR>`, `\<BS>`, or `\<Right>` that one would find in vim remappings. Keep in mind that `\`'s need to be escaped (i.e. `\\`) when using double quoted strings.

If the resulting value has a `<+++>` in it, that is where your cursor will be placed after the expansion. This plugin also has jump function support (only for latex files at the moment). That is, if you set `let g:vimtexer_jumpfunc = 1` in your vimrc, every time you hit double space, you will jump to the next `<++>` (note that this is different from `<+++>`). Thus, you can put `<++>`'s in the result of a dictionary keyword in order to easily jump around the expanded result.

An example dictionary:
```vim
let g:vimtexer_tex = {
    \'alpha' : '\alpha ',
    \'prf' : "\\begin{proof}\<CR><++>\<CR>\\end{proof}"
/}
```
This dictionary would expand `alpha` as `\(\alpha\)` and would expand `prf` in the manner shown in the first section of this readme. Keep in mind that you need a backslashs at the beginning of the lines in muitiline defitinitions in vimscript.

For more information, see the source code, which is heavily documented and always up-to-date.

## Why should I use Vimtexer instead of another plugin?

1. Vimtexer is made for LaTeX. In fact, it doesn't even load on any other filetype, so you can be sure that it won't slow you down when you're not typing LaTeX. Setting `g:vimtexer_mathkeyword` (by default `_`) will allow you to set a keyword which expands into math mode i.e. `\( <+++> \) <++>`.

2. Vimtexer is small and simple. There are literally only two functions in the entire source. Together, they take up around 80 lines of code, over half of which are just comments and blank lines. Seriously, if you have ever messed around with writing a vim plugin, then you'll probably understand this plugin. Setting new keywords is as easy as making a dictionary in your vimrc. Also, my usual tendency to over-comment code seems to be perfect and neccessary when it comes to vimscript. To me, simple and heavily-documented code is the only way to go!

3. Vimtexer has context-dependence for math mode. It knows whether or not you're typing math, and you can set keywords for the different namespaces. This makes typing math WAY easier.

4. Vimtexter has built-in jump function capabilites. You can set jump points in your expansions to quickly get around!

5. Vimtexer is FAST. Since the code is so small and written completely in vimscript, vimtexer can expand very quickly. Vimtexer is much faster than programming similar functionality into a snippets plugin, especially when you include the context dependence.

For a video demonstration (without audio) of what it's like to use vimtexer, click the image below:
[![https://www.youtube.com/watch?v=z03-e8zCkl8](https://img.youtube.com/vi/z03-e8zCkl8/0.jpg)](https://www.youtube.com/watch?v=z03-e8zCkl8)

