" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_ucw') && g:loaded_ucw
    finish
endif
let g:loaded_ucw = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


if !exists('g:ucw_save_num')
    let g:ucw_save_num = 10
endif
if !exists('g:ucw_restore_open_commands')
    let g:ucw_restore_open_commands = {'window': 'split', 'tab': 'tabedit'}
endif
if !exists('g:ucw_history_open_command')
    let g:ucw_history_open_command = 'new'
endif
if !exists('g:ucw_ignore_dup_buffer')
    let g:ucw_ignore_dup_buffer = 1
endif
if !exists('g:ucw_ignore_unnamed_buffer')
    let g:ucw_ignore_unnamed_buffer = 1
endif
if !exists('g:ucw_ignore_special_buffer')
    let g:ucw_ignore_special_buffer = 1
endif
if !exists('g:ucw_no_default_commands')
    let g:ucw_no_default_commands = 0
endif
if !exists('g:ucw_no_default_keymappings')
    let g:ucw_no_default_keymappings = 0
endif
if !exists('g:ucw_no_default_autocmd')
    let g:ucw_no_default_autocmd = 0
endif
if !exists('g:ucw_no_default_history_keymappings')
    let g:ucw_no_default_history_keymappings = 0
endif


if !g:ucw_no_default_commands
    command!
    \   -bar
    \   UcwRestoreWindow
    \   call ucw#restore_window(-1)

    command!
    \   -bar
    \   UcwOpenHistoryBuffer
    \   call ucw#open_history_buffer()
endif

if !g:ucw_no_default_keymappings
    nnoremap <Plug>(ucw-restore-window) :<C-u>call ucw#restore_window(-v:count1)<CR>
endif



" Save info to `ucw.histories`. {{{
if !g:ucw_no_default_autocmd
    augroup ucw
        autocmd!

        autocmd TabLeave * let s:leaving_tab = bufnr('%')
        autocmd BufWinLeave *
        \   if exists('s:leaving_tab')
        \   |   call ucw#add_history('tab', s:leaving_tab)
        \   | else
        \   |   call ucw#add_history('window')
        \   | endif
        \   | unlet! s:leaving_tab
    augroup END
endif
" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
