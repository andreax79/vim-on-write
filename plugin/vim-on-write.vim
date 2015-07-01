"=============================================================================
"	  VIM-On-Write
"	  Copyright (C) 2015 Andrea Bonomi <andrea.bonomi@gmail.com>
"
"  Name Of File: vim-on-write.vim
"   Description: Easily register commands executed when the current buffer or
"   a given files matching a glob are saved 
"
"=============================================================================

" Startup Check
if exists('loaded_onwrite')
    finish
endif
let loaded_onwrite = 1

" Mappings and Commands
if !exists(':OnWrite')
    command! -bang -nargs=* OnWrite call <SID>OnWrite(<q-args>)
endif
if !exists(':OnWriteGlob')
    command! -bang -nargs=* OnWriteGlob call <SID>OnWriteGlob(<q-args>)
endif
if !exists(':CancelOnWrite')
    command! -bang -nargs=* CancelOnWrite call <SID>CancelOnWrite(<q-args>)
endif

" Script variables
let s:onWriteBufferTriggers = {}
let s:onWritePatternTriggers = {}

" Split the line into [glob, rest of the line]
function SplitArg(arg)
    " search for a space
    let i = stridx(a:arg, ' ')
    if i == -1
        return ['', a:arg]
    endif
    " split the arg into head, tail
    let head = a:arg[0: i-1]
    let tail = a:arg[i+1 : 10000]
    return [head, tail]
endfunction

" Convert the glob into a regex
function GlobToRegex(glob)
    let pattern = escape(a:glob, '^$.\~[]')
    let pattern = substitute(pattern, '\*', '.*', 'g')
    let pattern = substitute(pattern, '?', '.', 'g')
    let pattern = "^" . pattern . "$"
    return pattern
endfunction

" Add a trigger executed after saving the current buffer
function! <SID>OnWrite(arg)
    let s:onWriteBufferTriggers[bufnr('%')] = a:arg
    echo "hook for buffer " . bufnr('%') . " registered"
endfunction

" Add a trigger executed after saving files matching a given glob
function! <SID>OnWriteGlob(arg)
    let [glob, cmd] = SplitArg(a:arg)
    if glob != ''
        echo "hook for pattern " . glob . " registered"
        let s:onWritePatternTriggers[GlobToRegex(glob)] = cmd 
    endif
endfunction

" Remove the trigger for the current buffer or a given glob
function! <SID>CancelOnWrite(...)
    if a:0 > 0 && len(a:1) > 0
        let glob = a:1
        let pattern = GlobToRegex(glob)
        if has_key(s:onWritePatternTriggers, pattern)
            unlet s:onWritePatternTriggers[pattern]
            echo "hook for pattern " . glob . " removed"
        endif
    else
        if has_key(s:onWriteBufferTriggers, bufnr('%'))
            unlet s:onWriteBufferTriggers[bufnr('%')]
            echo "hook for buffer " . bufnr('%') . " removed"
        endif
    endif
endfunction

" Executed on buffer save
function OnWriteTrigger()
    if has_key(s:onWriteBufferTriggers, bufnr('%'))
        " execute '!' . s:onWriteBufferTriggers[bufnr('%')]
        execute 'silent !' . s:onWriteBufferTriggers[bufnr('%')] . '&>/dev/null &' | redraw!
    endif

    let filename = expand('%:t')
    for [pattern, cmd] in items(s:onWritePatternTriggers)
        if match(filename, pattern) != -1
            " execute '!' . cmd 
            execute 'silent !' . cmd . '&>/dev/null &' | redraw!
        endif
    endfor
endfunction

autocmd BufWritePost,FileWritePost * call OnWriteTrigger()

