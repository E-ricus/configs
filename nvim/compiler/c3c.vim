" Vim compiler file
" Compiler: C3 Compiler (c3c)

if exists('current_compiler')
  finish
endif
let current_compiler = 'c3c'

let s:save_cpo = &cpo
set cpo&vim

CompilerSet makeprg=c3c\ $*

" c3c diagnostics:
"   (path/file.c3:LINE:COL) Error: message
"   (path/file.c3:LINE:COL) Warning: message
" Note lines (e.g. 'Inlined from here.') belong to the preceding Error
" and cannot be folded into it via errorformat, so they are dropped
" along with source-context and caret lines via -G.
CompilerSet errorformat=
      \%.%#(%f:%l:%c)\ %trror:\ %m,
      \%.%#(%f:%l:%c)\ %tarning:\ %m,
      \%-G%.%#

let &cpo = s:save_cpo
unlet s:save_cpo
