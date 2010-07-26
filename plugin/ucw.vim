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
if !exists('g:ucw_ignore_dup_buffer')
    let g:ucw_ignore_dup_buffer = 1
endif
if !exists('g:ucw_no_default_commands')
    let g:ucw_no_default_commands = 0
endif
if !exists('g:ucw_no_default_keymappings')
    let g:ucw_no_default_keymappings = 0
endif


if !g:ucw_no_default_commands
    command!
    \   -bar
    \   UcwRestoreWindow
    \   call ucw#restore_window(-1)
endif

if !g:ucw_no_default_keymappings
    nnoremap <Plug>(ucw-restore-window) :<C-u>call ucw#restore_window(-v:count1)<CR>
endif



" Save info to `ucw.histories`. {{{
augroup ucw
    autocmd!
    autocmd BufWinLeave * call ucw#add_history(expand('%'), bufnr('%'), winnr())
augroup END
" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
