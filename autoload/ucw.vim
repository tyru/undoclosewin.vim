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
    " Return true when negative idx.
    let idx = idx >= 0 ? idx : len(a:list) + idx
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



function! ucw#add_history(type, ...) "{{{
    let [bufnr] = s:args(a:000, bufnr('%'))
    call s:ucw.add_history(a:type, bufnr)
endfunction "}}}

function! ucw#restore_window(n) "{{{
    return s:ucw.restore_window(a:n)
endfunction "}}}

function! ucw#open_history_buffer() "{{{
    call s:ucw.open_history_buffer()
endfunction "}}}

" }}}

" Implementation {{{

let s:ucw = {}

" TODO
" If g:ucw_save_num is greater than N,
" Use dict whose key is bufnr.
let s:ucw.histories = []
let s:HISTORY_TYPE = 0
let s:HISTORY_BUFNR = 1
lockvar s:HISTORY_TYPE s:HISTORY_BUFNR



function! ucw#_get_instance() "{{{
    return s:ucw
endfunction "}}}



function! s:ucw.get_nth_type(n) dict "{{{
    return get(self.histories, a:n, [-1, -1])[s:HISTORY_TYPE]
endfunction "}}}

function! s:ucw.get_nth_bufnr(n) dict "{{{
    return get(self.histories, a:n, [-1, -1])[s:HISTORY_BUFNR]
endfunction "}}}


function! s:ucw.add_history(type, bufnr) dict "{{{
    if !self.is_valid_type(a:type)
        echohl WarningMsg
        echomsg 'undoclosewin:' a:type 'is not valid type.'
        echohl None
        return
    endif
    if !bufexists(a:bufnr)
        return
    endif
    if g:ucw_ignore_unnamed_buffer && bufname(a:bufnr) == ''
        return
    endif
    if g:ucw_ignore_special_buffer && &l:buftype != ''
        return
    endif
    if !g:ucw_ignore_dup_buffer || g:ucw_ignore_dup_buffer && !self.has_same_type_buffer(a:type, a:bufnr)
        call add(self.histories, [a:type, a:bufnr])
    endif

    " Delete old histories.
    let num = g:ucw_save_num > 0 ? g:ucw_save_num : 1
    if len(self.histories) >= num
        while len(self.histories) >= num
            call remove(self.histories, 0)
        endwhile
    endif
endfunction "}}}

function! s:ucw.is_valid_type(type) "{{{
    return a:type ==# 'window'
    \   || a:type ==# 'tab'
endfunction "}}}

function! s:ucw.has_same_type_buffer(type, bufnr) dict "{{{
    for [type, bufnr] in self.histories
        if type ==# a:type && bufnr ==# a:bufnr
            return 1
        endif
    endfor
    return 0
endfunction "}}}

function! s:ucw.remove_nth_history(n) dict "{{{
    call remove(self.histories, a:n)
endfunction "}}}


function! s:ucw.restore_window(n) dict "{{{
    if !s:ucw.has_nth_info(a:n)
        return
    endif

    let bufnr = s:ucw.get_nth_bufnr(a:n)
    let type  = s:ucw.get_nth_type(a:n)

    if !bufexists(bufnr)
        return
    endif

    if !has_key(g:ucw_restore_open_commands, type)
        return
    endif
    execute g:ucw_restore_open_commands[type]

    " Ignore own BufWinLeave event.
    set eventignore=BufWinLeave
    try
        execute bufnr 'buffer'
    finally
        set eventignore=
    endtry

    call s:ucw.remove_nth_history(a:n)
endfunction "}}}

function! s:ucw.has_nth_info(n) dict "{{{
    return s:has_idx(self.histories, a:n)
endfunction "}}}


function! s:ucw.open_history_buffer() dict "{{{
    try
        execute g:ucw_history_open_command
    catch
        echohl ErrorMsg
        echomsg v:exception
        echomsg v:throwpoint
        echohl None
        return
    endtry


    let lines = []
    for [type, bufnr] in self.histories
        if bufexists(bufnr)
            call add(lines, type . ': <' . bufnr . '> ' . bufname(bufnr))
        endif
    endfor
    call setline(1, lines)
    setlocal bufhidden=unload noswapfile nobuflisted nomodifiable nomodified

    " TODO Update buffer list when `self.histories` are updated.
    nnoremap <buffer> <Plug>(ucw-history-restore) :<C-u>call ucw#_get_instance().history_restore()<CR>
    if !g:ucw_no_default_history_keymappings
        nmap <buffer> <CR> <Plug>(ucw-history-restore)
    endif

    setfiletype ucw-history
endfunction "}}}

function! s:ucw.history_restore() dict "{{{
    close
    call self.restore_window(line('.') - 1)
endfunction "}}}

lockvar 1 s:ucw

" }}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
