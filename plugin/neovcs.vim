
" Function to get current root vcs dir
" Based on: https://github.com/airblade/vim-rooter/blob/master/plugin/rooter.vim
let g:my_rooter_patterns = ['.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/']
function! MySearchForRootDirectory()
  let s:root_dir = getcwd(-1)
  for s:pattern in g:my_rooter_patterns
    let s:result = s:MyFindAncestor(s:root_dir, s:pattern)
    if !empty(s:result)
      return {'vcs': s:MyGetVCSType(s:pattern), 'dir': s:result}
    endif
  endfor
  return ''
endfunction

function! MyGetVCSType(pattern)
    if a:pattern ==# '.git' || a:pattern ==# '.git/'
        return 'git'
    elseif a:pattern ==# '.svn/'
        return 'svn'
    else
        return ''
    endif
endfunction

function! MyFindAncestor(rootdir, pattern)
  " let fd_dir = isdirectory(s:fd) ? s:fd : fnamemodify(s:fd, ':h')
  let fd_dir = a:rootdir
  let fd_dir_escaped = escape(fd_dir, ' ')
  if s:IsDirectory(a:pattern)
    let match = finddir(a:pattern, fd_dir_escaped.';')
  else
    let [_suffixesadd, &suffixesadd] = [&suffixesadd, '']
    let match = findfile(a:pattern, fd_dir_escaped.';')
    let &suffixesadd = _suffixesadd
  endif
  if empty(match)
    return ''
  endif
  if s:IsDirectory(a:pattern)
    " If the directory we found (`match`) is part of the file's path
    " it is the project root and we return it.
    "
    " Compare with trailing path separators to avoid false positives.
    if stridx(fnamemodify(fd_dir, ':p'), fnamemodify(match, ':p')) == 0
      return fnamemodify(match, ':p:h')

    " Else the directory we found (`match`) is a subdirectory of the
    " project root, so return match's parent.
    else
      return fnamemodify(match, ':p:h:h')
    endif

  else
    return fnamemodify(match, ':p:h')
  endif
endfunction
function! IsDirectory(pattern)
  return a:pattern[-1:] == '/'
endfunction

function! Commit()
    let s:vcs_name = lh#vcs#get_type(expand('%:p'))

    if s:vcs_name ==# 'git'
        Gcommit
    elseif s:vcs_name ==# 'svn'
        VCCommit
    endif
endfunction

function! VcsAddFile()
    let s:filepath = expand('%:p')
    let s:command = ''
    if !empty(GitRoot())
        let s:command = 'git add '.s:filepath
    elseif !empty(SvnRoot())
        let s:command = 'svn add '.s:filepath
    else
        echo 'O arquivo não está em um repositório'
        return
    endif
    let s:systemcommand = system(s:command)
    echo s:command
endfunction

function! VcsName()
    if !empty(GitRoot())
        return 'git'
    elseif !empty(SvnRoot())
        return 'svn'
    else
        return ''
    endif
endfunction

function! VcsStatus()
    if !empty(GitRoot())
        call GitStatus()
    elseif !empty(SvnRoot())
        call SvnStatus()
    else
        echom "VCS not supported"
    endif
endfunction

function! GitStatus()

    let s:cmd = 'git status --porcelain'
    echo s:cmd

    " Get the result of git
    let s:flist = system(s:cmd)
    let s:flist = split(s:flist, '\n')

    " Create the dictionaries used to populate the quickfix list
    let s:list = []
    for f in s:flist
        let s:glist = split(f,' ')
        let s:a = s:glist[0]
        let s:b = s:glist[1]
        let s:dic = {'filename': s:b, "text": s:a}
        call add(s:list, s:dic)
    endfor

    " Populate the qf list
    call setqflist(s:list)

endfunction

function! SvnStatus()

    let s:cmd = "svn status | awk '{print $1\" \"$2}'"
    echo s:cmd

    " Get the result of svn
    let s:flist = system(s:cmd)
    let s:flist = split(s:flist, '\n')

    " Create the dictionaries used to populate the quickfix list
    let s:list = []
    for f in s:flist
        " if f == ''
            " continue
        " elseif stridx(f, '---') == 0
            " continue
        " endif

        let s:glist = split(f,' ')

        if len(s:glist) == 2
            let s:a = s:glist[0]
            let s:b = s:glist[1]
            let s:dic = {'filename': s:b, "text": s:a}
            call add(s:list, s:dic)
        endif
    endfor

    " Populate the qf list
    call setqflist(s:list)

endfunction

function! SvnRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.svn', path. ';')
endfunction

function! GitRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.git', path. ';')
endfunction

function! VcsHelp()
    echom "VCS Help:"
    echom "- <leader>va - add file to VCS"
    echom "- <leader>vA - add file to VCS (custom)"
    echom "- <leader>vr - remove file from VCS"
    echom "- <leader>vs - VCS status"
    echom "- <leader>vh - VCS help"
endfunction

nnoremap <silent> <leader>va :call VcsAddFile()<CR>
nnoremap <silent> <leader>vs :call VcsStatus()<CR>:copen<CR>
nnoremap <silent> <leader>vh :call VcsHelp()<CR>

