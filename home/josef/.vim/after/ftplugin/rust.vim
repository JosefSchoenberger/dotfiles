setlocal expandtab
setlocal softtabstop=4
" inoremap <buffer> " ""<left>
" inoremap <buffer> "" ""
" inoremap <buffer> "<BS> "<BS>
" inoremap <buffer> "<left> "<left>
" inoremap <buffer> "<up> "<up>
" inoremap <buffer> "<down> "<down>
" inoremap <buffer> "<right> "<right>
" inoremap <buffer> ( ()<left>
" inoremap <buffer> () ()
" inoremap <buffer> (<BS> (<BS>
" inoremap <buffer> [ []<left>
" inoremap <buffer> [] []
" inoremap <buffer> [<BS> [<BS>
" inoremap <buffer> { {}<left>
" inoremap <buffer> {} {}
" inoremap <buffer> {<BS> {<BS>
inoremap <buffer> {<CR> {<CR>}<ESC>O
inoremap <buffer> {;<CR> {<CR>};<ESC>O
inoremap <buffer> /*<Space> /*  */<left><left><left>
inoremap <buffer> /*<CR> /*<CR><CR><BS>/<UP><Space>
inoremap <buffer> /**<CR> /**<CR><CR><BS>/<UP><Space>

silent! keeppatterns /\/\*\n\s\*\s\(©\|(C)\)/;/\*\//fold
