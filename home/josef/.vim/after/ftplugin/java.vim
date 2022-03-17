
inoremap <buffer> {<CR> {<CR>}<ESC>O
inoremap <buffer> {;<CR> {<CR>};<ESC>O
inoremap <buffer> /*<Space> /*  */<left><left><left>
inoremap <buffer> /*<CR> /*<CR><CR><BS>/<UP><Space>
inoremap <buffer> /**<CR> /**<CR><CR><BS>/<UP><Space>

silent! /\/\*\n\s\*\s\(©\|(C)\)/;/\*\//fold
