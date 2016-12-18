if !exists('g:ale_rust_cargocheck_options')
    let g:ale_rust_cargocheck_options = ''
endif

let s:ale_rust_cargocheck_handle_py = expand("<sfile>:h") . "/ale_rust_cargocheck_handle.py"

function! AleRustCargoCheckHandle(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        execute 'pyfile' s:ale_rust_cargocheck_handle_py

        call add(l:output, {
        \ 'bufnr': a:buffer,
        \ 'lnum': l:result.lnum,
        \ 'vcol': 0,
        \ 'col': l:result.col,
        \ 'text': l:result.text,
        \ 'type': l:result.type,
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
