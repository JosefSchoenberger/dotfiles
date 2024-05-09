let s:cpo_save = &cpo
set cpo&vim

" The global python.vim syntax file checks if current_syntax is already set.
" So unset it here and re-set it in the end.
unlet b:current_syntax

syn include @PYTHON syntax/python.vim
syn region pythonCode start=/^\s*python\>\@<=\s*$/ end=/\<end\>\s*$\&/ contains=@PYTHON

let b:current_syntax = "gdb"

let &cpo = s:cpo_save
unlet s:cpo_save
