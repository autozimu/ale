if !exists('g:ale_rust_cargocheck_options')
    let g:ale_rust_cargocheck_options = ''
endif

function! AleRustCargoCheckHandle(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        if l:line ==# ''
            continue
        endif

        let l:msg = json_decode(l:line)
        let l:lnum = 0
        let l:col = 0
        if len(l:msg.message.spans) > 0
            let l:lnum = l:msg.message.spans[0].line_start
            let l:col = l:msg.message.spans[0].column_start
        endif

        let l:text = l:msg.message.message . ': '
        for l:child in l:msg.message.children
            let l:text .= l:child.message . ','
        endfor

        call add(l:output, {
        \ 'bufnr': a:buffer,
        \ 'lnum': l:lnum,
        \ 'vcol': 0,
        \ 'col': l:col,
        \ 'text': l:text,
        \ 'type': l:msg.message.level ==# 'error' ? 'E' : 'W',
        \ 'nr': -1,
        \ })
    endfor

    return l:output
endfunction

call ale#linter#Define('rust', {
\ 'name': 'cargocheck',
\ 'output_stream': 'stdout',
\ 'executable': 'cargo',
\ 'command': 'cargo check --message-format json ' . g:ale_rust_cargocheck_options,
\ 'callback': 'AleRustCargoCheckHandle'
\ })
