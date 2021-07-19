set nocompatible
filetype off  " required for Vundle

" to install Vundle, run:
" $ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" Once in vim, enter: `:PluginInstall'
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" ------------------ PUT PLUGINS HERE -------------------------
Plugin 'VundleVim/Vundle.vim' " necessary: Vundle itself for updates

Plugin 'itchyny/lightline.vim' " for the beautiful line, my favourite

Plugin 'ycm-core/YouCompleteMe' " for semantic completion; _not_ lightweight!
" Before installing, make sure you actually want this. It can sometimes be 
" slow. Next, decide which language you want to be supported and install the
" necessary dependencies (packages in Debian's repository):
" 	- General dependencies: cmake, build-essential, python3-dev
" 	- C/C++:  Clangd (package: clangd)
" 	- C#:     Mono (package: mono-devel)
" 			  -> UNTESTED
" 	- Go:     Go (package: golang-go), curl or wget
" 	- Java:   JDK-8 (package: openjdk-8-jdk)
" 			  found working with later headless JREs like openjdk-14-jre-headless
" 	- Java-/TypeScript: Node.js (nodejs), NPM (npm)
" 	- Python: Always enabled, no additional dependencies
" 	- Rust:   installs dependencies itself into the ycmd-dir in .vim using rustup
" After :PluginInstall, run:
" $ python3 ~/.vim/bundle/YouCompleteMe/install.py <flags>
" where <flags> consists of a combination of the following:
" 	- for C/C++:            --clangd-completer (not --clang-completer!)
" 	- for C#:               --cs-completer
" 	- for Go:               --go-completer
" 	- for Java:             --java-completer
" 	- for Java-/TypeScript: --ts-completer
" 	- for Rust:             --rust-completer
" Note: install.py might claim that no semantic completion for C/C++/ObjC
" will be available. That's normal, because you dont need libclang, however,
" semantic analysis will still be available using clangd...

Plugin 'rhysd/vim-clang-format' " for :ClangFormat
" Well, you better have clang-format installed here... :-P

Plugin 'iamcco/markdown-preview.nvim' " for instant Markdown Preview in browser
" to install, run in vim: `:call mkdp#util#install()'
" To use, run `:MarkdownPreview'

Plugin 'cespare/vim-toml' " for TOML-files syntax (i.e. Cargo.toml for Rust)

Plugin 'junegunn/fzf.vim'
Plugin 'junegunn/fzf' " Testing it out, looks cool, will require configuration;
					  " requires fzf?
" ------------------END OF PLUGINS ----------------------------
call vundle#end()
filetype plugin indent on

" YCM
" let g:ycm_clangd_binary_path = "/usr/bin/clangd-11"
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
" let g_ycm_log_level='debug'
nnoremap <S-F12> :YcmForceCompileAndDiagnostics<CR>

" Markdown Preview
let g:mkdp_open_to_the_world = 1
let g:mkdp_open_ip = system('var=$(ip -f inet addr show eth0 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -n 1); printf ${var:-"127.0.0.1"}')

" lightline
set laststatus=2 " start in NORMAL
set noshowmode " Hide unnecessary '--INSERT--'
set showcmd " ...but show keys pressed on the bottom right
let g:lightline = {
	\ 'colorscheme' : 'wombat',
	\ }
set wildmenu " show suggestions in line
set wildmode=longest:full,full

if file_readable($HOME."/.vim/clang-format-style.vim")
	autocmd BufNewFile,BufRead *.c,*.cpp,*.h,*.hpp source $HOME/.vim/clang-format-style.vim
endif

" CYP-Syntax. You may remove this if you don't even know what CYP is.
" Or, for the curious: github.com/noschinl/cyp
if file_readable($HOME."/.vim/syntax/cyp.vim")
	autocmd BufNewFile,BufRead *.cprf,*cthy setfiletype cyp
endif

" Kaitai Struct files

" Kaitai Struct files
autocmd BufNewFile,BufRead *.ksy setfiletype yaml

" Highlight search
set hlsearch
set incsearch

" open new split windows on the right / below instead of on the left / above
set splitright
set splitbelow

" indent automatically;
" Note: when pasting, you may want to use paste. See :h paste
set autoindent

syntax on
set number
" Break a line with a hook right arrow
set linebreak
set encoding=utf-8
scriptencoding utf-8
set showbreak=↪
set colorcolumn=121

set fillchars+=vert:┃

" Tab is 4 lines wide
set tabstop=4
set shiftwidth=4

" Import color settings
if file_readable($HOME."/.vim/colors.vim")
	source $HOME/.vim/colors.vim
elseif
	echo "Error: Could not find/read colors file."
	echo "Please create ~/.vim/colors.vim"
endif

set mouse=a " enable mouse
set ttymouse=sgr " with support for more than 220 columns in Windows Terminal

" Scroll early to always keep 2 lines above/below cursor if available
set so=2

" cause I'm an idiot
cmap sudow w !sudo tee > /dev/null %
" move line(s) up and down using Ctrl+j and Ctrl+k
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" tnoremap <esc><esc> <C-w>N
tnoremap <C-q> <C-w>N

" Enable spellcheck in demand. Use `:set nospell' to disable again
" requires German language pack to be downloaded manually:
" wget -P ~/.vim/spell/ http://ftp.vim.org/vim/runtime/spell/de.utf-8.spl
" wget -P ~/.vim/spell/ http://ftp.vim.org/vim/runtime/spell/de.utf-8.sug
function Deutsch()
	setlocal spell spelllang=de
endfunction

function English()
	setlocal spell spelllang=en
endfunction

function Denglisch() " use both German and English
	setlocal spell spelllang=de,en
endfunction

" Cursor shape
" 0 & 1 -> Block blinking (1 -> default)
" 2 -> Block
" 3 -> Underline blinking
" 4 -> Underline
" 5 -> Bar blinking
" 6 -> Bar
if &term =~ '^xterm'
	" normal mode
	let &t_EI .= "\<Esc>[1 q"
	" insert mode
	let &t_SI .= "\<Esc>[5 q"
	" replace mode
	let &t_SR .= "\<Esc>[3 q"

	" set the appropriate cursor at the beginning and upon leaving
	" autocmd VimEnter * silent !echo -ne "\e[1 q"
	autocmd VimLeave * silent !echo -ne "\e[1 q"
endif

" Windows terminal doesn't support BCE, so disable it:
set t_ut=""

" C-specific flags:
let c_gnu=1 " C-source is GNU-C
let c_space_errors=1 " highlight trailing spaces/tabs and spaces before tabs
					 " It is understandable if one wants to disable this, it
					 " can be annoying sometimes.
let g:load_doxygen_syntax=1 " enably doxygen highlighting for C, C++, C# and IDL

" only fold from the 10th level on initially
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
