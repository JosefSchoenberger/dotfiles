if has("gui_running") 
	color slate
	hi Comment guifg=grey60
elseif &t_Co == 256
	color peachpuff
endif

if &t_Co == 256 || has("gui_running")
	hi Visual cterm=bold ctermbg=239 gui=bold guifg=NONE guibg=grey30
	hi Search cterm=reverse ctermbg=Black guibg=Black
	hi Folded ctermbg=darkgray ctermfg=NONE

	" Make spell highlighting more readable
	hi SpellCap ctermbg=75 ctermfg=white
	hi SpellBad ctermfg=darkred

	" Suggestion / Completion list color
	hi Pmenu ctermbg=24 ctermfg=white
	" Suggestion list scrollbar
	hi PmenuThumb ctermbg=248 guibg=Grey
	" Suggestion list scrollbar background
	hi PmenuSbar ctermbg=0 guibg=Black

	" Colors for WildMenu
	hi StatusLine cterm=NONE ctermbg=235 ctermfg=252
	hi StatusLineNC cterm=NONE ctermbg=238 ctermfg=white
	hi WildMenu ctermfg=235 ctermbg=117

	hi VertSplit cterm=NONE ctermbg=NONE ctermfg=white
	hi FoldColumn ctermbg=235 ctermfg=117

	hi ColorColumn ctermbg=234
	
	let s:ycm_color_enabled=1
	function UpdateYCM() 
		if s:ycm_color_enabled
			let s:ycm_color_enabled=0
			hi YcmErrorSection cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
			hi YcmWarningSection cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
			echo "OK, disabled the YCM-Highlighting"
		else
			let s:ycm_color_enabled=1
			hi link YcmErrorSection Error
			" copy instead of link for UnderlineSpell()
			hi YcmWarningSection ctermbg=75 ctermfg=white guifg=#FF0000 guibg=#DDDD00
			echo "OK, enabled the YCM-Highlighting"
		endif
	endfunction
	hi link YcmErrorSection Error
	hi YcmWarningSection ctermbg=75 ctermfg=white guifg=#FF0000 guibg=#DDDD00
	nnoremap <F12> :call UpdateYCM()<CR>

	" Diff colors:
	" Added lines -> brighter & bold over darkest green available
	hi DiffAdd cterm=bold ctermfg=NONE ctermbg=22
	" Changed lines -> normal over dark blue (darkest is 17)
	hi DiffChange ctermfg=NONE ctermbg=18
	" Changed characters in changed lines -> black over bright red
	hi DiffText cterm=NONE ctermfg=Black
	" Deleted lines -> dark dashes over darkest red available
	hi DiffDelete ctermfg=236 ctermbg=52

	" matched parenthesis is black for visibility
	hi MatchParen ctermfg=Black

elseif $TERM == "linux"
	" exclusive for linux kernel terminal (the one you get with Ctrl+Alt+F5)
	set t_Co=16
endif

if &t_Co < 256 && !has('gui_running')
	let g:lightline = {
				\ 'colorscheme' : '16color',
				\ }
endif

function UnderlineSpell()
	" the gui uses undercurl, which is always preferable
	hi SpellBad cterm=underline ctermul=Red ctermbg=NONE ctermfg=NONE
	hi SpellCap cterm=underline ctermul=81 ctermbg=NONE ctermfg=NONE
	hi SpellLocal cterm=underline ctermul=14 ctermbg=NONE ctermfg=NONE
	hi SpellRare cterm=underline ctermul=225 ctermbg=NONE ctermfg=NONE
endfunction

if &term =~ 'kitty'
	call UnderlineSpell()
endif

au BufReadPost *.S set syntax=gas
