## Vimtexer is a template expander, specifically for quickly writing LaTeX

Preset keywords are expanded into other literal keypresses. These expansions are filetype specifc. For example, if you using the default dictionaries, then typing 'prf' in a tex file will replace the word and expand into:

```tex
\begin{proof}
    <+++>
\end{proof}
```

After an expansion, your cursor is placed in the place of the `<+++>` and you will remain in insert mode in order to continue seamlessly typing. This expansion occurs automatically after typing a space.

These keywords and expansions are stored as dictionaries for each filetype. This program contains a few dictionaries and several mappings by default. You can override these defaults by adding a dictionary of the form `g:vimtexer_<filetype>` in your personal vim config.

Some additional features and notes:

1. Regular LaTeX and typing math in LaTeX are considered two different namespaces, `tex` and `math` respectively. That way you can set keywords that only expand while between math brackets.

2. Typing `  ` (that is, double space) is mapped to a Jump Function that jumps and replaces the next instance of `<++>` in your file with your cursor.

3. `_` will start math mode i.e. `\( <+++> \)` and will switch the filetypes for you. Double spacing with no `<++>`'s left on the line causes you to jump out of math brackets.

4. The expansion can be literal using single quotes (e.g. `'\alpha'`), or "dynamic" using double quotes, which executes the expansion as if it were directly typed. Keep in mind that in a dynamic expansion it is necessary to escape back slashes e.g. `\\`; however, non-alphanumeric keys can be represented as `\<CR>`, `\<BS>`, `\<Right>`, etc.

For a video demonstration (without relevant audio) of what it's like to use vimtexer can be seen at this youtube link:
[https://www.youtube.com/watch?v=z03-e8zCkl8](https://www.youtube.com/watch?v=z03-e8zCkl8)
