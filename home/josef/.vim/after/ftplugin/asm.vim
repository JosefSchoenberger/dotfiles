inoremap <buffer> /*<Space> /*  */<left><left><left>
inoremap <buffer> /*<CR>    /*<CR><Space>*<CR>*/<UP><Space>
inoremap <buffer> /**<CR>   /**<CR><Space>*<CR>*/<UP><Space>

silent! keeppatterns /\/\*\n\s\*\s\(©\|(C)\)/;/\*\/[\n ]*/fold
