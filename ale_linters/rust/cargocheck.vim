if !exists('g:ale_rust_cargocheck_options')
    let g:ale_rust_cargocheck_options = ''
endif

function! ale_linters#rust#cargocheck#Handle(buffer, lines) abort
    let l:AleLintersRustCargoCheckHandleOutput = []
    call AleLintersRustCargoCheckHandle(a:lines)
    return l:AleLintersRustCargoCheckHandleOutput
endfunction

call ale#linter#Define('rust', {
\ 'name': 'cargocheck',
\ 'output_stream': 'stdout',
\ 'executable': 'cargo',
\ 'command': 'cargo clippy --message-format json ' . g:ale_rust_cargocheck_options,
\ 'callback': 'ale_linters#rust#cargocheck#Handle'
\ })
