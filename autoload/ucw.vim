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


" Interface {{{

function! ucw#load() "{{{
    " dummy function to load this script file.
endfunction "}}}



function! ucw#add_history(bufname, bufnr, winnr) "{{{
    call s:ucw.add_history(a:bufname, a:bufnr, a:winnr)
endfunction "}}}

function! ucw#restore_window(n) "{{{
    return s:ucw.restore_window(a:n)
endfunction "}}}

" }}}

" Implementation {{{

let s:ucw = {}
let u = s:ucw    " for easily access

" TODO
" If g:ucw_save_num is greater than N,
" Use dict whose key is bufnr.
let u.histories = []
let s:HISTORY_BUFNAME = 0
let s:HISTORY_BUFNR = 1
let s:HISTORY_WINNR = 2
lockvar s:HISTORY_BUFNAME s:HISTORY_WINNR s:HISTORY_BUFNR



function! u.get_nth_bufname(n) dict "{{{
    return get(self.histories, a:n, [-1, -1])[s:HISTORY_BUFNAME]
endfunction "}}}

function! u.get_nth_bufnr(n) dict "{{{
    return get(self.histories, a:n, [-1, -1])[s:HISTORY_BUFNR]
endfunction "}}}

function! u.get_nth_winnr(n) dict "{{{
    return get(self.histories, a:n, [-1, -1])[s:HISTORY_WINNR]
endfunction "}}}


function! u.add_history(bufname, bufnr, winnr) dict "{{{
    if !g:ucw_ignore_dup_buffer || g:ucw_ignore_dup_buffer && !self.has_buffer(a:bufnr)
        call add(self.histories, [a:bufname, a:bufnr, a:winnr])
    endif

    " Delete old histories.
    let num = g:ucw_save_num > 0 ? g:ucw_save_num : 1
    if len(self.histories) >= num
        while len(self.histories) >= num
            call remove(self.histories, 0)
        endwhile
    endif
endfunction "}}}

function! u.has_buffer(bufnr) dict "{{{
    for bufnr in map(copy(self.histories), 'v:val[s:HISTORY_BUFNR]')
        if bufnr ==# a:bufnr
            return 1
        endif
    endfor
    return 0
endfunction "}}}


function! u.restore_window(n) dict "{{{
    let bufnr = s:ucw.get_nth_bufnr(a:n)
    if bufnr ==# -1 || !bufexists(bufnr)
        return
    endif

    " Open bufnr at most belowright window.
    noautocmd execute winnr('$') 'wincmd w'
    noautocmd belowright split
    " Ignore own BufWinLeave event.
    set eventignore=BufWinLeave
    try
        execute bufnr 'buffer'
    finally
        set eventignore=
    endtry
endfunction "}}}


unlet u
lockvar 1 s:ucw

" }}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
