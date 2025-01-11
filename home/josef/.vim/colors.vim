vim9script
if has("gui_running") 
	color slate
	hi Comment guifg=grey60
elseif &t_Co == "256"
	color oldpeachpuff
endif

if &t_Co == "256" || has("gui_running")
	hi Visual cterm=bold ctermfg=None ctermbg=240 gui=bold guifg=NONE guibg=grey30
	hi Search cterm=reverse ctermbg=Black guibg=Black
	hi Folded ctermbg=236 ctermfg=NONE
	hi MatchParen ctermbg=39

	# Make spell highlighting more readable
	# hi SpellCap ctermbg=75 ctermfg=white
	# hi SpellBad ctermfg=darkred
	hi SpellCap ctermfg=NONE ctermbg=19
	hi SpellBad ctermfg=NONE ctermbg=52

	# Suggestion / Completion list color
	hi Pmenu ctermbg=24 ctermfg=NONE
	# Suggestion list scrollbar
	hi PmenuThumb ctermbg=248 guibg=Grey
	# Suggestion list scrollbar background
	hi PmenuSbar ctermbg=0 guibg=Black
	# Suggestion part of completion already typed
	hi PmenuMatch ctermbg=24 ctermfg=247

	# Colors for YCM hover box
	hi HoverBox ctermbg=233 ctermfg=white
	hi HoverBoxBorder cterm=bold ctermbg=232 ctermfg=blue

	# GitGutter
	hi GitGutterAdd ctermfg=green ctermbg=None
	hi GitGutterChange ctermfg=yellow ctermbg=None
	hi GitGutterDelete ctermfg=red ctermbg=None

	# Colors for WildMenu
	hi StatusLine cterm=NONE ctermbg=235 ctermfg=252
	hi StatusLineNC cterm=NONE ctermbg=238 ctermfg=white
	hi WildMenu ctermfg=235 ctermbg=117

	hi VertSplit cterm=NONE ctermfg=gray ctermbg=darkgray
	hi FoldColumn ctermbg=235 ctermfg=117

	hi ColorColumn ctermbg=234

	hi CursorLine cterm=NONE ctermbg=235
	hi CursorLineNr cterm=NONE ctermbg=3 ctermfg=235
	hi LineNrAbove ctermfg=36
	hi LineNrBelow ctermfg=36

	hi SpecialKey cterm=bold ctermfg=23
	# hi NonText cterm=bold ctermfg=240
	
	g:ycm_color_enabled = 1
	def g:UpdateYCM()
		if g:ycm_color_enabled
			g:ycm_color_enabled = 0
			hi YcmErrorSection cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
			hi YcmWarningSection cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
			echo "OK, disabled the YCM-Highlighting"
		else
			g:ycm_color_enabled = 1
			hi link YcmErrorSection Error
			hi YcmWarningSection ctermbg=75 ctermfg=white guifg=#FF0000 guibg=#DDDD00
			echo "OK, enabled the YCM-Highlighting"
		endif
	enddef
	hi link YcmErrorSection Error
	hi YcmWarningSection ctermbg=75 ctermfg=white guifg=#FF0000 guibg=#DDDD00
	hi YcmWarningSign ctermfg=0 ctermbg=75
	hi YcmErrorPopup ctermbg=16 ctermfg=203
	nnoremap <F12> :call UpdateYCM()<CR>

	# Diff colors:
	# Added lines -> brighter & bold over darkest green available
	hi DiffAdd cterm=bold ctermfg=NONE ctermbg=22
	# Changed lines -> normal over dark blue (darkest is 17)
	hi DiffChange ctermfg=NONE ctermbg=18
	# Changed characters in changed lines -> black over bright red
	hi DiffText cterm=NONE ctermfg=Black
	# Deleted lines -> dark dashes over darkest red available
	hi DiffDelete ctermfg=236 ctermbg=52

	# matched parenthesis is black for visibility
	hi MatchParen ctermfg=Black

elseif $TERM == "linux"
	# exclusive for linux kernel terminal (the one you get with Ctrl+Alt+F5)
	set t_Co=16
endif

if &t_Co < "256" && !has('gui_running')
	g:lightline = {
				'colorscheme': '16color',
				}
endif

# the gui uses undercurl, which is always preferable
function UnderlineSpell()
	hi SpellBad cterm=underline ctermul=Red ctermbg=NONE ctermfg=NONE
	hi SpellCap cterm=underline ctermul=81 ctermbg=NONE ctermfg=NONE
	hi SpellLocal cterm=underline ctermul=14 ctermbg=NONE ctermfg=NONE
	hi SpellRare cterm=underline ctermul=225 ctermbg=NONE ctermfg=NONE
endfunction

if &term =~ 'kitty'
	hi SpellBad cterm=undercurl ctermul=124 ctermbg=NONE ctermfg=NONE
	hi SpellCap cterm=undercurl ctermul=27 ctermbg=NONE ctermfg=NONE
	hi SpellLocal cterm=undercurl ctermul=24 ctermbg=NONE ctermfg=NONE
	hi SpellRare cterm=undercurl ctermul=225 ctermbg=NONE ctermfg=NONE
	#hi YcmWarningSection cterm=underline ctermul=153 ctermbg=NONE ctermfg=NONE

	# https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim

	# Underline/curl/dash with color
	&t_Ce = "\<Esc>[4:0m"
	&t_Us = "\<Esc>[4:2m"
	&t_Cs = "\<Esc>[4:3m"
	&t_ds = "\<Esc>[4:4m"
	&t_Ds = "\<Esc>[4:5m"
	&t_AU = "\<Esc>[58:5:%dm"
	&t_8u = "\<Esc>[58:2:%lu:%lu:%lum"

	# Strikethrough
	&t_Ts = "\<Esc>[9m"
	&t_Te = "\<Esc>[29m"
	# Truecolor support
	&t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
	&t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
	&t_RF = "\<Esc>]10;?\<Esc>\\"
	&t_RB = "\<Esc>]11;?\<Esc>\\"
	# Bracketed paste
	&t_BE = "\<Esc>[?2004h"
	&t_BD = "\<Esc>[?2004l"
	&t_PS = "\<Esc>[200~"
	&t_PE = "\<Esc>[201~"
	# Cursor control
	&t_RC = "\<Esc>[?12$p"
	&t_SH = "\<Esc>[%d q"
	&t_RS = "\<Esc>P$q q\<Esc>\\"
	&t_VS = "\<Esc>[?12l"
	# Focus tracking
	&t_fe = "\<Esc>[?1004h"
	&t_fd = "\<Esc>[?1004l"
	execute "set <FocusGained>=\<Esc>[I"
	execute "set <FocusLost>=\<Esc>[O"
endif

au BufReadPost *.S set syntax=gas
au BufNew *.S set syntax=gas
