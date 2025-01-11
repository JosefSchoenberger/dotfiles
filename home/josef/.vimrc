vim9script
set nocompatible
filetype off  # required for Vundle

# to install Vundle, run:
# $ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
# Once in vim, enter: `:PluginInstall'
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
# ------------------ PUT PLUGINS HERE -------------------------
Plugin 'VundleVim/Vundle.vim' # necessary: Vundle itself for updates

Plugin 'itchyny/lightline.vim' # for the beautiful line, my favourite

if get(g:, "no_ycm", 0) == 0
	Plugin 'ycm-core/YouCompleteMe' # for semantic completion; _not_ lightweight!
endif
# Before installing, make sure you actually want this. It can sometimes be 
# slow. Next, decide which language you want to be supported and install the
# necessary dependencies (packages in Debian's repository):
# 	- General dependencies: cmake, build-essential, python3-dev
# 	- C/C++:  Clangd (package: clangd)
# 	- C#:     Mono (package: mono-devel)
# 			  -> UNTESTED
# 	- Go:     Go (package: golang-go), curl or wget
# 	- Java:   JDK-8 (package: openjdk-8-jdk)
# 			  found working with later headless JREs like openjdk-14-jre-headless
# 	- Java-/TypeScript: Node.js (nodejs), NPM (npm)
# 	- Python: Always enabled, no additional dependencies
# 	- Rust:   installs dependencies itself into the ycmd-dir in .vim using rustup
# After :PluginInstall, run:
# $ python3 ~/.vim/bundle/YouCompleteMe/install.py <flags>
# where <flags> consists of a combination of the following:
# 	- for C/C++:            --clangd-completer (not --clang-completer!)
# 	- for C#:               --cs-completer
# 	- for Go:               --go-completer
# 	- for Java:             --java-completer
# 	- for Java-/TypeScript: --ts-completer
# 	- for Rust:             --rust-completer
# Note: install.py might claim that no semantic completion for C/C++/ObjC
# will be available. That's normal, because you dont need libclang, however,
# semantic analysis will still be available using clangd...
#
# My personal command by the way:
# python3 ~/.vim/bundle/YouCompleteMe/install.py --clangd-completer --go-completer --java-completer --ts-completer --rust-completer

Plugin 'SirVer/ultisnips' # for some nice snippets
Plugin 'honza/vim-snippets'

Plugin 'fatih/vim-go' # for Go

Plugin 'rhysd/vim-clang-format' # for :ClangFormat
# Well, you better have clang-format installed here... :-P

Plugin 'iamcco/markdown-preview.nvim' # for instant Markdown Preview in browser
# to install, run in vim: `:call mkdp#util#install()'
# To use, run `:MarkdownPreview'

Plugin 'cespare/vim-toml' # for TOML-files syntax (i.e. Cargo.toml for Rust)

Plugin 'junegunn/fzf.vim'
Plugin 'junegunn/fzf' # Testing it out, looks cool, will require configuration;
					  # requires fzf?

Plugin 'airblade/vim-gitgutter' # git status on the left

# ------------------END OF PLUGINS ----------------------------
call vundle#end()
filetype plugin indent on

# YCM
g:ycm_clangd_binary_path = "/usr/bin/clangd"
g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
g:ycm_clangd_args = ['--background-index', '--clang-tidy']
g:ycm_confirm_extra_conf = 0
# g:ycm_log_level='debug'
if file_readable($HOME .. "/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer")
	g:ycm_rust_toolchain_root = $HOME .. "/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/"
elseif file_readable($HOME .. "/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/rust-analyzer")
	g:ycm_rust_toolchain_root = $HOME .. "/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/"
endif
# g:ycm_gopls_binary_path='gopls'
nnoremap <S-F12> :YcmForceCompileAndDiagnostics<CR>

g:ycm_autoclose_preview_window_after_completion = 1
g:ycm_key_list_select_completion = ['<Down>']
g:ycm_key_list_previous_completion = ['<Up>']
g:ycm_echo_current_diagnostic = 'virtual-text'
g:ycm_language_server = [
	{
		'name': 'bash',
		'cmdline': [ '/opt/bash-language-server/vscode-client/node_modules/.bin/bash-language-server', 'start' ],
		'filetypes': [ 'sh' ],
	},
	{
		'name': 'html',
		'cmdline': [ '/opt/vscode-langservers-extracted/bin/vscode-html-language-server', '--stdio' ],
		'filetypes': [ 'html' ],
	},
	{
		'name': 'css',
		'cmdline': [ '/opt/vscode-langservers-extracted/bin/vscode-css-language-server', '--stdio' ],
		'filetypes': [ 'css' ],
	},
	{
		'name': 'json',
		'cmdline': [ '/opt/vscode-langservers-extracted/bin/vscode-json-language-server', '--stdio' ],
		'filetypes': [ 'json' ],
	},
	{
		'name': 'markdown',
		'cmdline': [ '/opt/vscode-langservers-extracted/bin/vscode-markdown-language-server', '--stdio' ],
		'filetypes': [ 'markdown' ],
	},
]

augroup YcmSetHoverSyntax
	autocmd!
	autocmd FileType * b:ycm_hover = {
				\   'command': 'GetDoc',
				\   'syntax': &filetype,
				\   'popup_params': {
				\     'dragall': 1,
				\     'resize': 1,
				\     'maxwidth': 96,
				\     'wrap': 1,
				\     'border': [],
				\     'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
				\     'highlight': 'HoverBox',
				\     'borderhighlight': ['HoverBoxBorder'],
				\     'title': '─┤  Info  ├',
				\   },
				\ }
augroup END

# UltiSnips
g:UltiSnipsJumpForwardTrigger = "<tab>"
g:UltiSnipsJumpBackwardTrigger = "<S-tab>"

# Markdown Preview
g:mkdp_open_to_the_world = 1
g:mkdp_open_ip = system('var=$(ip -f inet addr show eth0 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -n 1); printf ${var:-"127.0.0.1"}')

# lightline
set laststatus=2 # start in NORMAL
set noshowmode # Hide unnecessary '--INSERT--'
set showcmd # ...but show keys pressed on the bottom right
g:lightline = {
	'colorscheme': 'wombat',
	'active': {
		'left': [['mode', 'paste'], ['readonly', 'relativepath', 'modified'], ['cmd']],
		'right': [['lineinfo'], ['percent'], ['YCM', 'fileformat', 'fileencoding', 'filetype']]
	},
	'component': {
		'filename': '%{%mode()=="t"?"%f":"%t"%}',
		'cmd': '%S',
		'YCM': get(g:, "no_ycm", 0) ? '' : '%{%youcompleteme#GetErrorCount() ? youcompleteme#GetErrorCount() .. " Errors, " .. youcompleteme#GetWarningCount() .. " Warnings" : youcompleteme#GetWarningCount() ? youcompleteme#GetWarningCount() .. " Warnings" : ""%}',
		'readonly': '%(%H-%)%R',
		'fileformat': '%<%{&ff}',
	},
}
set showcmdloc=statusline
set wildmenu # show suggestions in line
set wildmode=longest:full,full

if file_readable($HOME .. "/.vim/clang-format-style.vim")
	autocmd BufNewFile,BufRead *.c,*.cpp,*.h,*.hpp source $HOME/.vim/clang-format-style.vim
endif

# CYP-Syntax. You may remove this if you don't even know what CYP is.
# Or, for the curious: github.com/noschinl/cyp
if file_readable($HOME .. "/.vim/syntax/cyp.vim")
	autocmd BufNewFile,BufRead *.cprf,*cthy setfiletype cyp
endif

autocmd FileType c,cpp,java,rust,go,html,bash,python setlocal foldmethod=syntax
autocmd FileType rust setlocal colorcolumn=101
autocmd FileType vim setlocal foldmethod=manual

autocmd BufNewFile,BufRead kea-*.conf set ft=json
autocmd BufNewFile,BufRead kea-*.conf syntax match Comment +#.\+$+

# Highlight search
set hlsearch
set incsearch

# open new split windows on the right / below instead of on the left / above
set splitright
set splitbelow

# indent automatically;
# Note: when pasting, you may want to use paste. See :h paste
set autoindent

syntax on
set number
set signcolumn=number # Show YCM errors and warnings in numberbar
# Break a line with a hook right arrow
set linebreak
set encoding=utf-8
scriptencoding utf-8
set showbreak=↪
set breakindent
set breakindentopt=shift:2
set smoothscroll
set colorcolumn=121

set formatoptions+=j
autocmd BufNewFile,BufRead *.md set formatoptions+=n # indent following a enumeration with '1.'

set fillchars+=vert:┃

# Tab is 4 lines wide
set tabstop=4
set shiftwidth=4

# Import color settings
if file_readable($HOME .. "/.vim/colors.vim")
	source $HOME/.vim/colors.vim
else
	echo "Error: Could not find/read colors file."
	echo "Please create ~/.vim/colors.vim"
endif

set ttimeoutlen=10 # ESC basically immediately
set mouse=a # enable mouse
set ttymouse=sgr # with support for more than 220 columns in Windows Terminal
set listchars=tab:-->,space:␣,leadmultispace:···⍿,multispace:·,nbsp:━,trail:⦚ #,eol:↵
nmap <F1> :Files<CR>
nnoremap <F3> :set spell!<CR>
nnoremap <F2> :set relativenumber!<CR>
autocmd VimEnter * GitGutterDisable
nnoremap <S-F2> :GitGutterToggle<CR>
nnoremap <F4> :set list!<CR>

set cursorline
set cursorlineopt=number

# Scroll early to always keep 2 lines above/below cursor if available
set so=2
set siso=5 # 5 column on each side (when not wrapping)

if !isdirectory($HOME .. "/.vim/undo-dir")
	call mkdir($HOME .. "/.vim/undo-dir", "", 0700)
endif
set undodir=~/.vim/undo-dir
set undofile

set autoread # when file changes and there are no changes in VIM's buffer, reload automatically

# cause I'm an idiot
cmap sudow w !sudo tee > /dev/null %
# move line(s) up and down using Ctrl+j and Ctrl+k
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

# tnoremap <esc><esc> <C-w>N
tnoremap <C-q> <C-w>N
# Use TerminalWinOpen event instead to not interfere with fzf
# See https://github.com/junegunn/fzf.vim/issues/503.
autocmd TerminalWinOpen * setlocal nonumber norelativenumber
#autocmd TerminalOpen * setlocal nonumber norelativenumber

# Enable spellcheck in demand. Use `:set nospell' to disable again
# requires German language pack to be downloaded manually:
# wget -P ~/.vim/spell/ http://ftp.vim.org/vim/runtime/spell/de.utf-8.spl
# wget -P ~/.vim/spell/ http://ftp.vim.org/vim/runtime/spell/de.utf-8.sug
function g:Deutsch()
	setlocal spell spelllang=de
endfunction

function g:English()
	setlocal spell spelllang=en
endfunction

function g:Denglisch() # use both German and English
	setlocal spell spelllang=de,en
endfunction

# Cursor shape
# 0 & 1 -> Block blinking (1 -> default)
# 2 -> Block
# 3 -> Underline blinking
# 4 -> Underline
# 5 -> Bar blinking
# 6 -> Bar
if &term =~ '^xterm'
	# normal mode
	&t_EI = "\<Esc>[1 q"
	# insert mode
	&t_SI = "\<Esc>[5 q"
	# replace mode
	&t_SR = "\<Esc>[3 q"

	# set the appropriate cursor at the beginning and upon leaving
	# autocmd VimEnter * silent !echo -ne "\e[1 q"
	autocmd VimLeave * silent !echo -ne "\e[1 q"
endif

# Windows terminal doesn't support BCE, so disable it:
set t_ut=""

# C-specific flags:
const c_gnu = 1 # C-source is GNU-C
const c_space_errors = 1 # highlight trailing spaces/tabs and spaces before tabs
					 # It is understandable if one wants to disable this, it
					 # can be annoying sometimes.
# let g:load_doxygen_syntax=1 # enably doxygen highlighting for C, C++, C# and IDL


g:markdown_fenced_languages = ['c', 'cpp', 'python', 'bash', 'sh', 'java', 'rust', 'go']

# only fold from the 10th level on initially
set foldlevel=10

set tags=./tags,tags;
map <C-M-RightMouse> :tn<CR>
map <C-M-LeftMouse> :tp<CR>

function Noarrow()
	noremap <Up> <nop>
	noremap <Down> <nop>
	noremap <Left> <nop>
	noremap <Right> <nop>
	noremap <PageUp> <nop>
	noremap <PageDown> <nop>
endfunction

# Enclose in parentheses
vnoremap ;( c()<Esc>Pg;h
vnoremap ;{ c{}<Esc>Pg;h
vnoremap ;[ c[]<Esc>Pg;h

# Map <C-W> commands to a more comfortable position for NEOQWERTZ
nnoremap _& <C-W><C-P>
nnoremap _? <C-W>h
nnoremap _( <C-W>j
nnoremap _) <C-W>k
nnoremap _- <C-W>l


nnoremap <silent> <F5> <Plug>(YCMToggleInlayHints)
nnoremap <S-F5> :YcmCompleter GetType<CR>
nnoremap <C-F5> :YcmShowDetailedDiagnostic popup<CR>
# nnoremap <F6> gewve"ny:YcmCompleter RefactorRename <c-r>n
nnoremap <F6> viw"ny:YcmCompleter RefactorRename <c-r>n
nnoremap <S-F6> :YcmCompleter FixIt<CR>
# For more advanced refactoring commands
nnoremap <C-F6> :YcmCompleter Refactor
nnoremap <M-F6> :YcmCompleter Format<CR>
g:ycm_auto_hover = ''
nnoremap <F7> <plug>(YCMHover)
inoremap <F7> <Esc><plug>(YCMHover)a
nnoremap <S-F7> :YcmCompleter GetDoc<CR>
if file_readable($HOME .. "/.vim/tagstack.vim")
	source $HOME/.vim/tagstack.vim
	nnoremap <F8> :call tagstack#push()<CR>:YcmCompleter GoTo<CR>
	nnoremap <S-F8> :call tagstack#push()<CR>:YcmCompleter GoToImplementation<CR>
	nnoremap <C-F8> :call tagstack#push()<CR>:YcmCompleter GoToDeclaration<CR>
	nnoremap <M-F8> :call tagstack#push()<CR>:YcmCompleter GoToCallers<CR>
	nnoremap <M-C-F8> :call tagstack#push()<CR>:YcmCompleter GoToReferences<CR>
	nnoremap <F9> :call tagstack#push()<CR><Plug>(YCMFindSymbolInWorkspace)
	nnoremap <S-F9> :call tagstack#push()<CR><Plug>(YCMFindSymbolInDocument)
	nnoremap <C-F9> :call tagstack#push()<CR>:YcmCompleter GoToDocumentOutline<CR>
	nnoremap <F10> :call tagstack#push()<CR>viw"ny:Rg <c-r>n<CR>
else
	nnoremap <F8> :YcmCompleter GoTo<CR>
	nnoremap <S-F8> :YcmCompleter GoToImplementation<CR>
	nnoremap <C-F8> :YcmCompleter GoToDeclaration<CR>
	nnoremap <M-F8> :YcmCompleter GoToCallers<CR>
	nnoremap <M-C-F8> :YcmCompleter GoToReferences<CR>
	nnoremap <F9> <Plug>(YCMFindSymbolInWorkspace)
	nnoremap <S-F9> <Plug>(YCMFindSymbolInDocument)
	nnoremap <C-F9> :YcmCompleter GoToDocumentOutline<CR>
	nnoremap <F10> viw"ny:Rg <c-r>n<CR>
endif

nnoremap gö :tabe<CR>
nnoremap gÖ :tabc<CR>

function Expandtab(t)
	set expandtab
endfunction
