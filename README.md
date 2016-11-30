## Vimtexer is a template expander for quickly writing LaTeX

Preset keywords are expanded into other literal keypresses. These expansions are filetype specifc. For example, if you using the default dictionaries, then typing 'prf' in a tex file will replace the word and expand into:

```tex
\begin{proof}
    <+++>
\end{proof}
```

After an expansion, your cursor is placed in the place of the `<+++>` and you will remain in insert mode in order to continue seamlessly typing. This expansion occurs automatically after typing a space.

These keywords and expansions are stored as dictionaries for each filetype. This program contains a few dictionaries and several mappings by default. You can override these defaults by adding a dictionary of the form `g:vimtexer_<filetype>` in your personal vim config.

The expansion can be literal using single quotes (e.g. `'\alpha'`), or "dynamic" using double quotes, which executes the expansion as if it were directly typed. Keep in mind that in a dynamic expansion it is necessary to escape back slashes e.g. `\\`; however, non-alphanumeric keys can be represented as `\<CR>`, `\<BS>`, `\<Right>`, etc.

For more information, see the source code, which is heavily documented.

## Why should I use Vimtexer instead of another plugin?

1. Vimtexer is made for LaTeX. In fact, it doesn't even load on any other filetype, so you can be sure that it won't slow you down when you're not typing LaTeX. Setting `g:vimtexer_mathkeyword` (by default `_`) will allow you to set a keyword which expands into math mode i.e. `\( <+++> \) <++>`.

2. Vimtexer is small and simple. There are literally only two functions in the entire source. Together, they take up around 80 lines of code, over half of which are just comments and blank lines. Seriously, if you have ever messed around with writing a vim plugin, then you'll probably understand this plugin. Setting new keywords is as easy as making a dictionary in your vimrc. Also, my usual tendency to over-comment code seems to be perfect and neccessary when it comes to vimscript. To me, simple and heavily-documented code is the only way to go!

3. Vimtexer has context-dependence for math mode. It knows whether or not you're typing math, and you can set keywords for the different namespaces. This makes typing math WAY easier.

4. Vimtexter has built-in jump function capabilites. You can set jump points in your expansions to quickly get around!

5. Vimtexer is FAST. Since the code is so small and written completely in Vimscript, vimtexer can expand very quickly. Vimtexer is much faster than programming similar functionality into a Snippets program, especially when you include the context dependence.

For a video demonstration (without relevant audio) of what it's like to use vimtexer, click the image below:
[![https://www.youtube.com/watch?v=z03-e8zCkl8](https://img.youtube.com/vi/z03-e8zCkl8/0.jpg)](https://www.youtube.com/watch?v=z03-e8zCkl8)

