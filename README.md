vimtexer.vim is a template expander, specifically for quickly writing LateX.

Preset keywords are expanded into other literal keypresses. These expansions filetype specifc. For an example, if you use the default dictionaries and in a tex file you type 'prf' this will expand into:

\begin{proof}
  <+++>
\end{proof}

Where <+++> is where the cursor is placed after expansion. This expansion occurs automatically after typing a space. After the expansion you remain in insert mode to seamlessly continue typing.

These keywords and expansions are stored as dictionaries for each filetype. This program contains a few dictionaries and several mappings by default. You can override these defaults by adding a dictionary of the form "let g:vimtexer_<filetype>" in your personal vim config.

Some additional features and notes:
1. Regular LaTeX and typing math in LaTeX are considered two different filetypes, "tex" and "math" respectively. That way you can set keywords that only expand while in math mode and vice versa.
2. <Space><Space> is mapped to a Jump Function that jumps and replaces the next instance of "<+Whatever+>" in your file
3. '_' will start math mode i.e. "\( <+++> \)" and will switch the filetypes for you. Double spacing with no "<++>"'s left on the line causes you to jump out of math mode and switches the filetype back to LaTeX.
4. The expansion can be literal e.g. '\alpha ', using single quotes, or "dynamic", using double quotes, which executes the expansion as if it were directly typed. Keep in mind that in a dynamic expansion it is necessary to escape back slashes e.g. "\\". Also, non-alphanumeric keys are represented as "\<CR>", "\<BS>", "\<Right>", etc.
