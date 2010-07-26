" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" Utilities {{{

function! s:has_idx(list, idx) "{{{
    let idx = a:idx
    return 0 <= idx && idx < len(a:list)
endfunction "}}}

function! s:args(args, ...) "{{{
    let ret_args = []
    let i = 0

    while i < len(a:000)
        call add(
        \   ret_args,
        \   s:has_idx(a:args, i) ?
        \       a:args[i]
        \       : a:000[i]
        \)
        let i += 1
    endwhile

    return ret_args
endfunction "}}}

" }}}



" Interface {{{

function! ucw#load() "{{{
    " dummy function to load this script file.
endfunction "}}}



function! ucw#add_history(...) "{{{
    let [bufname, bufnr] = s:args(a:000, expand('%'), bufnr('%'))
    call s:ucw.add_history(bufname, bufnr)
endfunction "}}}

function! ucw#restore_window(n) "{{{
    return s:ucw.restore_window(a:n)
endfunction "}}}

" }}}

" Implementation {{{

let s:ucw = {}

" TODO
" If g:ucw_save_num is greater than N,
" Use dict whose key is bufnr.
let s:ucw.histories = []
let s:HISTORY_BUFNAME = 0
let s:HISTORY_BUFNR = 1
lockvar s:HISTORY_BUFNAME s:HISTORY_BUFNR



function! s:ucw.get_nth_bufname(n) dict "{{{
    return get(self.histories, a:n, [-1, -1])[s:HISTORY_BUFNAME]
endfunction "}}}

function! s:ucw.get_nth_bufnr(n) dict "{{{
    return get(self.histories, a:n, [-1, -1])[s:HISTORY_BUFNR]
endfunction "}}}


function! s:ucw.add_history(bufname, bufnr) dict "{{{
    if g:ucw_ignore_unnamed_buffer && a:bufname == ''
        return
    endif
    if g:ucw_ignore_special_buffer && &l:buftype != ''
        return
    endif
    if !g:ucw_ignore_dup_buffer || g:ucw_ignore_dup_buffer && !self.has_buffer(a:bufnr)
        call add(self.histories, [a:bufname, a:bufnr])
    endif

    " Delete old histories.
    let num = g:ucw_save_num > 0 ? g:ucw_save_num : 1
    if len(self.histories) >= num
        while len(self.histories) >= num
            call remove(self.histories, 0)
        endwhile
    endif
endfunction "}}}

function! s:ucw.has_buffer(bufnr) dict "{{{
    for bufnr in map(copy(self.histories), 'v:val[s:HISTORY_BUFNR]')
        if bufnr ==# a:bufnr
            return 1
        endif
    endfor
    return 0
endfunction "}}}

function! s:ucw.remove_nth_history(n) dict "{{{
    call remove(self.histories, a:n)
endfunction "}}}


function! s:ucw.restore_window(n) dict "{{{
    let bufnr = s:ucw.get_nth_bufnr(a:n)
    if bufnr ==# -1 || !bufexists(bufnr)
        return
    endif

    execute g:ucw_restore_open_command
    " Ignore own BufWinLeave event.
    set eventignore=BufWinLeave
    try
        execute bufnr 'buffer'
    finally
        set eventignore=
    endtry

    call s:ucw.remove_nth_history(a:n)
endfunction "}}}


lockvar 1 s:ucw

" }}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
