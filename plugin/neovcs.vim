
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


" VCS add current buffer
function! AddBuffer()
	w
    if s:vcs_name ==# 'git'
        windo !git add %
    elseif s:vcs_name ==# 'svn'
        windo !svn add %
    endif
endfunction
command! AddBuffer :call AddBuffer()

function! Commit()
    let s:vcs_name = lh#vcs#get_type(expand('%:p'))

    if s:vcs_name ==# 'git'
        Gcommit
    elseif s:vcs_name ==# 'svn'
        VCCommit
    endif
endfunction

function! Status()
    let s:vcs_name = lh#vcs#get_type(expand('%:p'))

    if s:vcs_name ==# 'git'
        FloatermNew git status
    elseif s:vcs_name ==# 'svn'
        FloatermNew svn status
    endif
endfunction

function! AddFileToVCS()
    let s:filepath = expand('%:p')
    let s:vcs_name = lh#vcs#get_type(s:filepath)
    let s:command = ''
    if s:vcs_name ==# 'git'
        let s:command = 'git add '.s:filepath
    elseif s:vcs_name ==# 'svn'
        let s:command = 'svn add '.s:filepath
    else
        echo 'O arquivo não está em um repositório'
        return
    endif
    let s:systemcommand = system(s:command)
    echo s:command
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

    " Get the result of git show in a list
    let flist = system('git ls-files -dmo')
    let flist = split(flist, '\n')

    " Create the dictionnaries used to populate the quickfix list
    let list = []
    for f in flist
        let dic = {'filename': f, "lnum": 1}
        call add(list, dic)
    endfor

    " Populate the qf list
    call setqflist(list)

endfunction

function! SvnStatus()

    " Get the result of git show in a list
    let flist = system("svn status | awk '{print $2}'")
    let flist = split(flist, '\n')

    " Create the dictionnaries used to populate the quickfix list
    let list = []
    for f in flist
        let dic = {'filename': f, "lnum": 1}
        call add(list, dic)
    endfor

    " Populate the qf list
    call setqflist(list)

endfunction

function! SvnRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.svn', path. ';')
endfunction

function! GitRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.git', path. ';')
endfunction

nnoremap <silent> <leader>vs :call VcsStatus()<CR>:copen<CR>

