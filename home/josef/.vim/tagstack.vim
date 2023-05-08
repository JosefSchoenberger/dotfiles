" https://gitlab.com/egzvor/vimfiles/-/blob/8b64d2e8b095aa50637cd928089e84fbfe6e00c5/autoload/tagstack.vim

function! tagstack#push() abort
    call settagstack(
\       winnr(),
\       #{items: [#{
\           bufnr: bufnr(),
\           from: [0, line('.'), col('.'), 0],
\           matchnr: 1,
\           tagname: expand('<cword>')
\       }]},
\       't'
\)
endfunction

function! tagstack#jump_to_current() abort
    let ts = gettagstack()
    let current = get(ts['items'], ts['curidx'] - 1, {})
    if current == {}
        return
    endif

    let tagname = get(current, 'tagname', '')
    call search('\<' .. tagname .. '\>', 'cw')
    if expand('<cword>') !=# tagname
        echoerr 'Token under cursor changed, cannot jump to definition'
        return
    endif

    call settagstack(winnr(), #{curidx: ts['curidx'] + 1}, 'r')
    exe 'buffer ' .. current['bufnr']
    call cursor(current['from'][1], current['from'][2])
    return
endfunction

function! tagstack#setqf()
    call setqflist(
\        map(
\            gettagstack()['items'],
\            {_, tag_entry -> #{
\                bufnr: tag_entry['bufnr'],
\                lnum: tag_entry['from'][1],
\                col: tag_entry['from'][2],
\                text: tag_entry['tagname']}
\            }
\        ),
\        'r',
\)
endfunction

