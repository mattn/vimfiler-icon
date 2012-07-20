try
    call vimproc#version()
    let s:system = function('vimproc#system')
catch
    let s:system = function('system')
endtry
let s:icon_dir = substitute(fnamemodify(expand('~/.cache/vimfiler'), ':p:8'), '\\', '/', 'g')
let s:icon_dir = substitute(s:icon_dir, '/$', '', '')
if !isdirectory(s:icon_dir)
    call mkdir(s:icon_dir, 'p')
endif
let s:sdir = fnamemodify(expand('<sfile>'), ':h')

function! s:icon_name(word)
    return isdirectory(a:word) ? "folder" : matchstr(fnamemodify(a:word, ':e'), '\w\+')
endfunction

function! s:sign_name(word)
    return "vimfiler_icon_".a:word
endfunction

function! s:sign_define_icon(file)
    let name = s:icon_name(a:file)
    let fname = s:icon_dir . '/' . name . '.ico'
    if len(name) && !filereadable(fname)
        call system(printf("%s %s %s",
        \  fnamemodify(printf("%s/fileicon", s:sdir), ':8'),
        \  shellescape(substitute(a:file, '/', '\', 'g')),
        \  fnamemodify(fname, ':p:8')))
    endif
    if len(name) && filereadable(fname)
        let exec =  ":sign define ".s:sign_name(name)." icon=".fnameescape(fname)." text=X"
        execute exec
    endif
endfunction

function! s:sign_place_icon(line, file)
    let name = s:icon_name(a:file)
    let fname = s:icon_dir . '/' . name . '.ico'
    if len(name) && filereadable(fname)
        execute ":sign place ".a:line." line=".(a:line+2)." name=".s:sign_name(name)." buffer=" . bufnr("%")
    endif
endfunction

function! s:sign_unplace_all()
    redir => ids
    silent! sign place
    redir END
    for id in map(split(ids, "\n")[2:], 'matchstr(v:val, "id=\\zs\\d\\+\\ze")')
      exe "sign" "unplace" id
    endfor
endfunction

function! s:BuildIcons()
    let dir = get(b:, 'vimfiler_icon_dir', '')
    if b:vimfiler.current_dir == dir
        return
    endif
    let b:vimfiler_icon_dir = b:vimfiler.current_dir
    call s:sign_unplace_all()
    call map(filter(map(range(len(b:vimfiler.current_files)), '{
\       "file" : b:vimfiler.current_files[v:val].action__path,
\       "line" : v:val+1
\   }'), "!empty(v:val.file)"), "s:sign_define_icon(v:val.file) || s:sign_place_icon(v:val.line, v:val.file)")
endfunction

autocmd CursorMoved <buffer> call s:BuildIcons()
