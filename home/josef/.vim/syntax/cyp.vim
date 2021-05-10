" Vim syntax file
"   Language: Check Your Proof
"   Maintainer: HE7086 <https://github.com/HE7086>
"
" Last Modified: Tue 26 Nov 2019 06:32:14 PM CET
"   Version: 0.1.2

if exists("b:current_syntax")
    finish
endif

syntax sync fromstart

syntax keyword cypKeyword       Proof Case QED Assumption
syntax keyword cypKeyword       on with
syntax keyword cypIfThEls       if then else
syntax keyword cypTheory        axiom goal data declare_sym
syntax match   cypTheory        /\(\s*\)\@\<\=IH.\{-}\(:\)\@\=/
syntax match   cypProof         /by induction/
syntax match   cypProof         /by computation induction/
syntax match   cypProof         /by extensionality/
syntax match   cypProof         /by case analysis/
syntax match   cypProof         /by cheating/
syntax keyword cypLemma         Lemma
syntax keyword cypBool          True False
syntax match cypToShow          /To show\(\s*:\)\@\=/

syntax match cypComment         /^\s*--.*/

syntax keyword cypTypes         Int Integer Bool Char String List


if !exists("g:cyp_syntax_referbrace")
	syntax match cypReference       /(\(by .\{-}\)\@\=/
	syntax match cypProof           /\((\)\@\<\=by \(def \)\?\(.\{-}\)\@\>/
	syntax match cypReference       /\((by \(def \)\?\)\@\<\=.\{-})/
else
    syntax match cypReference       /\((\s*\)\@\<\=by .\{-}\(\s*)\)\@\=/
endif
syntax match cypEqualEtc        /\.=\./
syntax match cypEqualEtc        /</
syntax match cypEqualEtc        />/
syntax match cypEqualEtc        /<=/
syntax match cypEqualEtc        />=/
syntax match cypArrow           /==>/
syntax match cypArrow           /<==/
syntax match cypCusLemma        /\(Lemma\)\@\<\=.\{-}\(:\)\@\=/


" syntax region cypProofs         start="Proof" end="QED" skip="Case"

if version < 508
    command -nargs=+ HiLink hi link <args>
else
    command -nargs=+ HiLink hi def link <args>
endif

if !exists("g:cyp_syntax_colorscheme")
    HiLink cypKeyword       Statement
    HiLink cypToShow        Statement
    HiLink cypTheory        Identifier
    HiLink cypProof         Type
    HiLink cypLemma         Include
    HiLink cypCusLemma      Keyword
    HiLink cypEqualEtc      Operator
    HiLink cypReference     Identifier
    HiLink cypBool          Boolean
    HiLink cypArrow         Conditional
    HiLink cypComment       Comment
    HiLink cypTypes         Statement
    HiLink cypIfThEls       Conditional
else
    HiLink cypKeyword       Keyword
    HiLink cypToShow        Keyword
    HiLink cypTheory        Identifier
    HiLink cypProof         Type
    HiLink cypLemma         Include
    HiLink cypCusLemma      Include
    HiLink cypEqualEtc      Operator
    HiLink cypReference     Function
    HiLink cypBool          Boolean
    HiLink cypArrow         Conditional
    HiLink cypComment       Comment
    HiLink cypTypes         Type
    HiLink cypIfThEls       Conditional
endif

delcommand HiLink

syntax include @HASKELL syntax/haskell.vim
try
	syntax include @HASKELL after/syntax/haskell.vim
catch
endtry

syntax region haskellCode start=/\(To\sshow\(\s\)*:\)\@\<\= / end=/\n/ contains=@HASKELL
syntax region haskellCode start=/\(IH\(\s\)*:\)\@\<\= / end=/\n/ contains=@HASKELL
syntax region haskellCode start=/\(Lemma\(\s\)*:\)\@\<\= / end=/\n/ contains=@HASKELL
syntax region haskellCode start=/\(Case\)\@\<\= / end=/\n/ contains=@HASKELL
syntax region haskellCode start=/\(^\(\s\)*axiom\)\@\<\= / end=/\n/ contains=@HASKELL
syntax region haskellCode start=/\(^\(\s\)*goal\)\@\<\= / end=/\n/ contains=@HASKELL
syntax region haskellCode start=/\(\.=\.\)\@\<\=/ end=/\n/ contains=@HASKELL
syntax region haskellCode start=/\[/ end=/\n/ contains=@HASKELL
syntax region haskellCode start=/[^\.]\@\<\==/ end=/\n/ contains=@HASKELL
syntax region haskellCode start=/([^b]/ end=/\n/ contains=@HASKELL
syntax region haskellCode start=/++[^)]/ end=/\n/ contains=@HASKELL
hi link haskellCode SpecialComment

let b:current_syntax = "cyp"
