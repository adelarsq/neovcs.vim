
function! VcsName()
    if !empty(GitRoot())
        return 'git'
    elseif !empty(SvnRoot())
        return 'svn'
    elseif !empty(DarcsRoot())
        return 'darcs'
    elseif !empty(BazaarRoot())
        return 'bazaar'
    elseif !empty(MercurialRoot())
        return 'mercurial'
    else
        return ''
    endif
endfunction

function! MercurialRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.hg', path. ';')
endfunction

function! BazzarRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.bzr', path. ';')
endfunction

function! DarcsRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('_darcs', path. ';')
endfunction

function! GitRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.git', path. ';')
endfunction

function! SvnRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.svn', path. ';')
endfunction

function! VcsCommit(...) abort
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'git'
        execute '!git commit -m "'.a:1.'"'
    elseif s:vcs_name ==# 'svn'
        execute '!svn commit --changelist '.a:1.' -m "'.a:2.'"'
    endif
endfunction

function! VcsAddFile(...)
    let s:filepath = expand('%:p')
    let s:command = ''
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'git'
        let s:command = 'git add '.s:filepath
    elseif s:vcs_name ==# 'svn'
        if a:0 == 0
            let s:command = 'svn add '.s:filepath
        else
            let s:command = 'svn changelist '.a:1.' '.s:filepath
        endif
    else
        echo 'Is this file in a repository?'
        return
    endif
    let s:systemcommand = system(s:command)
    echo s:command
endfunction

function! VcsAddFiles(...)
    let s:command = ''
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'git'
        let s:command = 'git add *'
    elseif s:vcs_name ==# 'svn'
        if a:0 == 0
            let s:command = 'svn add *'
        else
            let s:command = 'svn changelist '.a:1.' *'
        endif
    else
        echo 'Is this file in a repository?'
        return
    endif
    let s:systemcommand = system(s:command)
    echo s:command
endfunction

function! VcsBlame()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'git'
        call VcsGitBlame()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsGitBlame()
    let s:cmd = 'git blame '
    echo s:cmd
endfunction

function! VcsStatus()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'git'
        call VcsStatusGit()
    elseif s:vcs_name == 'svn'
        call VcsStatusSvn()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsStatusGit()

    let s:cmd = 'git status --porcelain'
    echo s:cmd

    " Get the result of git
    let s:flist = system(s:cmd)
    let s:flist = split(s:flist, '\n')

    " Create the dictionaries used to populate the quickfix list
    let s:list = []
    for s:f1 in s:flist
        let s:f2 = trim(s:f1)
        echom s:f2
        let s:glist = split(s:f2)
        echom s:glist
        let s:a = s:glist[0]
        let s:b = s:glist[1]
        let s:dic = {'filename': s:b, "text": s:a}
        echom s:dic
        call add(s:list, s:dic)
    endfor

    " Populate the qf list
    call setqflist(s:list)

endfunction

function! VcsStatusSvn()

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

function! VcsUpdateSend()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'git'
        call VcsUpdateSendGit()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsUpdateSendGit()
    let s:cmd = "git push"
    echo s:cmd
    let s:flist = system(s:cmd)
endfunction

function! VcsUpdateReceive()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'git'
        call VcsUpdateReceiveGit()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsUpdateReceiveGit()
    let s:cmd = "git pull"
    echo s:cmd
    let s:flist = system(s:cmd)
endfunction

function! VcsHelp()
    echom "VCS Help:"
    echom "- <leader>va - add file to VCS"
    echom "- <leader>vA - add all files to VCS"
    " echom "- <leader>vb - change branch"
    echom "- <leader>vc - commit file"
    " echom "- <leader>vr - remove file from VCS"
    echom "- <leader>vs - status"
    echom "- <leader>vu - update send changes"
    echom "- <leader>vU - send receive changes"
    echom "- <leader>vh - this help"
    " <leader>vl :VcsBlame<CR>
    " <leader>vL :VcsLog<CR>
endfunction

nnoremap <silent> <leader>va :call VcsAddFile()<CR>
nnoremap <silent> <leader>vA :call VcsAddFiles()<CR>
nmap <leader>vc :call VcsCommit("","")<left><left><left><left><left>
nnoremap <silent> <leader>vs :call VcsStatus()<CR>:copen<CR>
nnoremap <silent> <leader>vu :call VcsUpdateSend()<CR>
nnoremap <silent> <leader>vU :call VcsUpdateReceive()<CR>
nnoremap <silent> <leader>vh :call VcsHelp()<CR>

