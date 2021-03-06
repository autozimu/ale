" Author: w0rp <devw0rp@gmail.com>
" Description: Linter registration and lazy-loading
"   Retrieves linters as requested by the engine, loading them if needed.

let s:linters = {}

" Default filetype aliaes.
" The user defined aliases will be merged with this Dictionary.
let s:default_ale_linter_aliases = {
\   'zsh': 'sh',
\   'csh': 'sh',
\   'plaintex': 'tex',
\   'systemverilog': 'verilog',
\}

" Default linters to run for particular filetypes.
" The user defined linter selections will be merged with this Dictionary.
"
" No linters are used for plaintext files by default.
let s:default_ale_linters = {
\   'zsh': ['shell'],
\   'csh': ['shell'],
\   'text': [],
\}

" Testing/debugging helper to unload all linters.
function! ale#linter#Reset() abort
    let s:linters = {}
endfunction

function! s:IsCallback(value) abort
    return type(a:value) == type('') || type(a:value) == type(function('type'))
endfunction

function! ale#linter#PreProcess(linter) abort
    if type(a:linter) != type({})
        throw 'The linter object must be a Dictionary'
    endif

    let l:obj = {
    \   'name': get(a:linter, 'name'),
    \   'callback': get(a:linter, 'callback'),
    \}

    if type(l:obj.name) != type('')
        throw '`name` must be defined to name the linter'
    endif

    if !s:IsCallback(l:obj.callback)
        throw '`callback` must be defined with a callback to accept output'
    endif

    if has_key(a:linter, 'executable_callback')
        let l:obj.executable_callback = a:linter.executable_callback

        if !s:IsCallback(l:obj.executable_callback)
            throw '`executable_callback` must be a callback if defined'
        endif
    elseif has_key(a:linter, 'executable')
        let l:obj.executable = a:linter.executable

        if type(l:obj.executable) != type('')
            throw '`executable` must be a string if defined'
        endif
    else
        throw 'Either `executable` or `executable_callback` must be defined'
    endif

    if has_key(a:linter, 'command_callback')
        let l:obj.command_callback = a:linter.command_callback

        if !s:IsCallback(l:obj.command_callback)
            throw '`command_callback` must be a callback if defined'
        endif
    elseif has_key(a:linter, 'command')
        let l:obj.command = a:linter.command

        if type(l:obj.command) != type('')
            throw '`command` must be a string if defined'
        endif
    else
        throw 'Either `command`, `executable_callback`, `command_chain` '
        \   . 'must be defined'
    endif

    let l:obj.output_stream = get(a:linter, 'output_stream', 'stdout')

    if type(l:obj.output_stream) != type('')
    \|| index(['stdout', 'stderr', 'both'], l:obj.output_stream) < 0
        throw "`output_stream` must be 'stdout', 'stderr', or 'both'"
    endif

    return l:obj
endfunction

function! ale#linter#Define(filetype, linter) abort
    if !has_key(s:linters, a:filetype)
        let s:linters[a:filetype] = []
    endif

    let l:new_linter = ale#linter#PreProcess(a:linter)

    call add(s:linters[a:filetype], l:new_linter)
endfunction

function! s:LoadLinters(filetype) abort
    if a:filetype ==# ''
        " Empty filetype? Nothing to be done about that.
        return []
    endif

    if has_key(s:linters, a:filetype)
        " We already loaded the linter files for this filetype, so stop here.
        return s:linters[a:filetype]
    endif

    " Load all linters for a given filetype.
    execute 'silent! runtime! ale_linters/' . a:filetype . '/*.vim'

    if !has_key(s:linters, a:filetype)
        " If we couldn't load any linters, let everyone know.
        let s:linters[a:filetype] = []
    endif

    return s:linters[a:filetype]
endfunction

function! ale#linter#Get(original_filetypes) abort
    let l:combined_linters = []

    " Handle dot-seperated filetypes.
    for l:original_filetype in split(a:original_filetypes, '\.')
        " Try and get an aliased file type either from the user's Dictionary, or
        " our default Dictionary, otherwise use the filetype as-is.
        let l:filetype = get(
        \   g:ale_linter_aliases,
        \   l:original_filetype,
        \   get(
        \       s:default_ale_linter_aliases,
        \       l:original_filetype,
        \       l:original_filetype
        \   )
        \)

        " Try and get a list of linters to run, using the original file type,
        " not the aliased filetype. We have some linters to limit by default,
        " and users may define their own list of linters to run.
        let l:linter_names = get(
        \   g:ale_linters,
        \   l:original_filetype,
        \   get(
        \       s:default_ale_linters,
        \       l:original_filetype,
        \       'all'
        \   )
        \)

        let l:all_linters = s:LoadLinters(l:filetype)
        let l:filetype_linters = []

        if type(l:linter_names) == type('') && l:linter_names ==# 'all'
            let l:filetype_linters = l:all_linters
        elseif type(l:linter_names) == type([])
            " Select only the linters we or the user has specified.
            for l:linter in l:all_linters
                if index(l:linter_names, l:linter.name) >= 0
                    call add(l:filetype_linters, l:linter)
                endif
            endfor
        endif

        call extend(l:combined_linters, l:filetype_linters)
    endfor

    return l:combined_linters
endfunction
