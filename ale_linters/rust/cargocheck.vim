if !exists('g:ale_rust_cargocheck_options')
    let g:ale_rust_cargocheck_options = ''
endif

let s:ale_rust_cargocheck_handle_py = expand("<sfile>:h") . "/ale_rust_cargocheck_handle.py"

function! ale_linters#rust#cargocheck#Handle(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        execute 'pyfile' s:ale_rust_cargocheck_handle_py

        if exists('l:ale_rust_cargocheck_handle_py_result')
            call add(l:output, {
                \ 'bufnr': a:buffer,
                \ 'lnum': l:ale_rust_cargocheck_handle_py_result.lnum,
                \ 'vcol': 0,
                \ 'col': l:ale_rust_cargocheck_handle_py_result.col,
                \ 'text': l:ale_rust_cargocheck_handle_py_result.text,
                \ 'type': l:ale_rust_cargocheck_handle_py_result.type,
                \ 'nr': -1,
                \ })
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('rust', {
\ 'name': 'cargocheck',
\ 'output_stream': 'stdout',
\ 'executable': 'cargo',
\ 'command': 'cargo check --message-format json ' . g:ale_rust_cargocheck_options,
\ 'callback': 'ale_linters#rust#cargocheck#Handle'
\ })
