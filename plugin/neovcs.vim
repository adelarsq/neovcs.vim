
if exists('g:loaded_neovcs')
    finish
endif
let g:loaded_neovcs=1

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

function! VcsNamePath()
    " TODO create better detection
    let cwdRoot = getcwd()

    let gitRoot = GitRoot()
    if !empty(gitRoot)
        return ['git', cwdRoot]
    endif

    let svnRoot = SvnRoot()
    if !empty(svnRoot)
        return ['svn', cwdRoot]
    endif

    let darcsRoot = DarcsRoot()
    if !empty(darcsRoot)
        return ['darcs', cwdRoot]
    endif

    let bazaarRoot = BazaarRoot()
    if !empty(bazaarRoot)
        return ['bazaar', cwdRoot]
    endif

    let mercurialRoot = MercurialRoot()
    if !empty(mercurialRoot)
        return ['mercurial', cwdRoot]
    endif

    return []
endfunction

function! MercurialRoot(...) abort
  let path = a:0 == 0 ? expand('%:p:h') : a:1
  return finddir('.hg', path. ';')
endfunction

function! BazaarRoot(...) abort
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

function! VcsBranchName() abort
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'git'
        return VcsGitBranchName()
    else
        echom "VCS not supported"
        return ''
    endif
endfunction

function! VcsGitBranchName() abort
    let branch = systemlist('git branch')[0]
    let branchSplit = split(branch,' ')[1]
    return branchSplit
endfunction

function! VcsCommit(...) abort
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'git'
        execute '!git commit -m "'.a:1.'"'
    elseif s:vcs_name ==# 'svn'
        execute '!svn commit --changelist '.a:2.' -m "'.a:1.'"'
    endif
endfunction

function! VcsDiff(...) abort
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'svn'
        execute '!svn diff -r'.a:1
    endif
endfunction

function! VcsOpenLineUrl()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'git'
        call VcsOpenLineUrlGit()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsOpenLineUrlGit()
    let s:cmd = 'git config --get remote.origin.url'
    " echo s:cmd
    let s:result = system(s:cmd)
    let s:split = split(s:result, '\n')

    let s:branch = VcsGitBranchName()

    let s:relativeFilePath = expand('%:P')

    let s:line = line('.')

    let s:url = s:split[0].'/blob/'.s:branch.'/'.s:relativeFilePath.'#L'.s:line

    let s:openurl = 'OpenBrowser '.s:url

    execute s:openurl
endfunction

function! VcsOpenUrl()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'git'
        call VcsOpenUrlGit()
    elseif s:vcs_name == 'svn'
        call VcsOpenUrlSvn()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsOpenUrlGit()
    let s:cmd = 'git config --get remote.origin.url'
    echo s:cmd
    let s:result = system(s:cmd)
    let s:split = split(s:result, '\n')
    let s:openurl = 'OpenBrowser '.s:split[0]
    execute s:openurl
endfunction

function! VcsOpenUrlSvn()
    " https://serverfault.com/questions/310300/how-to-get-the-url-of-the-current-svn-repo
    let s:cmd = 'svn info --show-item repos-root-url'
    echo s:cmd
    let s:result = system(s:cmd)
    let s:split = split(s:result, '\n')
    let s:openurl = 'OpenBrowser '.s:split[0]
    execute s:openurl
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

function! VcsShowBranchs()
    let s:command = ''
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'git'
        let s:command = 'git branch'
    else
        echo 'Is this file in a repository?'
        return
    endif
    let s:systemcommand = system(s:command)
    echo s:command
endfunction

function! VcsRmFile(...)
    let s:filepath = expand('%:p')
    let s:command = ''
    let s:vcs_name = VcsName()
    if s:vcs_name ==# 'git'
        let s:command = 'git rm '.s:filepath
    elseif s:vcs_name ==# 'svn'
        if a:0 == 0
            let s:command = 'svn rm '.s:filepath
        else
            " TODO
            let s:command = 'svn changelist '.a:1.' '.s:filepath
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
        call VcsBlameGit()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsBlameGit()
    let s:cmd = 'git blame '
    echo s:cmd
    let s:systemcommand = system(s:command)
endfunction

function! VcsResolve()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'svn'
        call VcsResolveSvn()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsResolveSvn()
    let s:filepath = expand('%:p')
    let s:cmd = 'svn resolve '.s:filepath
    echo s:cmd
    let s:systemcommand = system(s:command)
endfunction

function! VcsLog()
    let s:vcs_name = VcsName()
    if s:vcs_name == 'git'
        call VcsLogGit()
    elseif s:vcs_name == 'svn'
        call VcsLogSvn()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsLogGit()
    let s:cmd = 'git log '
    echo s:cmd
    let s:systemcommand = system(s:command)
endfunction

function! VcsLogSvn()
    let s:cmd = 'svn log '
    echo s:cmd
    let s:systemcommand = system(s:command)
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
        let s:glist = split(s:f2)
        let s:a = s:glist[0]
        let s:b = s:glist[1]
        let s:dic = {'filename': s:b, "text": s:a}
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

function! VcsStatusLine()

    let s:vcs_name_path = VcsNamePath()

    if empty(s:vcs_name_path)
        return ''
    endif

    let s:vcs_name = s:vcs_name_path[0]
    let s:root_dir = s:vcs_name_path[1]

    let s:cd_root_dir = 'cd '.s:root_dir

    " Get local file changes

    let [s:added, s:modified, s:removed] = sy#repo#get_stats()

    let s:symbols = ['+', '-', '~']
    let s:stats = [s:added, s:removed, s:modified]
    let s:hunkline = ''
    for s:i in range(3)
        let s:hunkline .= printf('%s%s', s:symbols[s:i], s:stats[s:i])
    endfor
    let s:hunkline .= ' '
    if !empty(s:hunkline)
        let s:hunkline = printf('%s', s:hunkline[:-2])
    endif

    " Shows conflits on current file
    let s:mark_conflits = '≠'
    let s:light_line_vcs_conflits = ''
    if s:vcs_name ==# 'git'
        let s:light_line_vcs_conflits = s:mark_conflits . VcsGitConflictMarker()
    elseif s:vcs_name ==# 'svn'
        let s:light_line_vcs_conflits = s:mark_conflits . VcsGitConflictMarker()
    else
        let g:light_line_vcs_conflits = s:mark_conflits.'0'
    endif

    " Get local repository changes
    let s:mark_local = '↑'
    let g:light_line_vcs_status_local = ''

    if s:vcs_name ==# 'git'
        let s:status_update_list = systemlist('git for-each-ref --format="%(HEAD) %(refname:short) %(push:track)" refs/heads | grep -o "[0-9]\+"')
        if len(s:status_update_list) > 0
            let g:light_line_vcs_status_local = s:mark_local.s:status_update_list[0]
        else
            let g:light_line_vcs_status_local = s:mark_local.'0'
        endif
    elseif s:vcs_name ==# 'svn'
        let s:commands = s:cd_root_dir.'; svn status'
        let s:status_update_list_local = systemlist(s:commands)
        if len(s:status_update_list_local) > 0
            let g:light_line_vcs_status_local = s:mark_local.len(s:status_update_list_local)
        else
            let g:light_line_vcs_status_local = s:mark_local.'0'
        endif
    else
        let g:light_line_vcs_status_local = s:mark_local.'0'
    endif

    " Get remote changes
    let s:mark_behind = '↓'
    let g:light_line_vcs_status_behind = ''

    if s:vcs_name ==# 'git'
        " TODO
        " let s:commands = s:cd_root_dir.'; git for-each-ref --format="%(HEAD) %(refname:short) %(push:track)" refs/heads | grep -o "[0-9]\+"'
        " let s:status_behind = systemlist(s:commands)
        " if len(s:status_behind) > 0
            " let g:light_line_vcs_status_behind = s:mark_behind.s:status_behind[0]
        " else
            " let g:light_line_vcs_status_behind = s:mark_behind.'0'
        " endif
        let g:light_line_vcs_status_behind = s:mark_behind.'?'
    elseif s:vcs_name ==# 'svn'
        let s:commands = s:cd_root_dir.'; svn status -u | grep "        \*"'
        let s:status_behind = systemlist(s:commands)
        if len(s:status_behind) > 0
            let g:light_line_vcs_status_behind = s:mark_behind.len(s:status_behind)
        else
            let g:light_line_vcs_status_behind = s:mark_behind.'0'
        endif
    else
        let g:light_line_vcs_status_behind = s:mark_behind.'0'
    endif

    " Shows conflits on current repository
    let s:mark_repository_conflits = '≠'
    let s:light_line_vcs_repository_conflits = ''
    if s:vcs_name ==# 'git'
        " Based on: https://stackoverflow.com/questions/3065650/whats-the-simplest-way-to-list-conflicted-files-in-git
        let s:commands = s:cd_root_dir.'; git diff --name-only --diff-filter=U '
        let s:status_conflicts_repository = systemlist(s:commands)
        let g:light_line_vcs_repository_conflits = s:mark_repository_conflits.len(s:status_conflicts_repository)
    elseif s:vcs_name ==# 'svn'
        let s:commands = s:cd_root_dir.'; svn status|grep "Text conflicts"|sed ''s/[^0-9]*//g'' '
        let s:status_conflicts_repository = systemlist(s:commands)
        if len(s:status_conflicts_repository) > 0
            let g:light_line_vcs_repository_conflits = s:mark_repository_conflits.s:status_conflicts_repository[0]
        else
            let g:light_line_vcs_repository_conflits = s:mark_repository_conflits.'0'
        endif
    else
        let g:light_line_vcs_repository_conflits = s:mark_repository_conflits.'0'
    endif

    " Get name branch

    let s:mark_vcs = ''
    let s:vcs_name_branch = ''

    if !exists("b:vcs_name_branch")
        if s:vcs_name ==# 'git'
            let s:vcs_name_branch = s:vcs_name.' '.VcsGitBranchName()
        elseif s:vcs_name ==# 'svn'
            let s:commands = s:cd_root_dir."; svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$' "
            let s:vcs_name_branch = s:vcs_name.' '.systemlist(s:commands)[0]
        endif
        let b:vcs_name_branch = s:vcs_name_branch
    else
        let s:vcs_name_branch = b:vcs_name_branch
    endif

    return
        \ s:mark_vcs
        \ . ' '
        \ . s:hunkline
        \ . s:light_line_vcs_conflits
        \ . ' '
        \ . g:light_line_vcs_status_local
        \ . g:light_line_vcs_status_behind
        \ . g:light_line_vcs_repository_conflits
        \ . ' '
        \ . s:vcs_name_branch

endfunction

" Shows conflits marker
" Source: https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions/whitespace.vim
function! VcsGitConflictMarker()
    " Checks for git conflict markers
    let annotation = '\%([0-9A-Za-z_.:]\+\)\?'
    let pattern = '^\%(\%(<\{7} '.annotation. '\)\|\%(=\{7\}\)\|\%(>\{7\} '.annotation.'\)\)$'
    return search(pattern, 'nw')
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
    elseif s:vcs_name == 'svn'
        call VcsUpdateReceiveSvn()
    else
        echom "VCS not supported"
    endif
endfunction

function! VcsUpdateReceiveGit()
    let s:cmd = "git pull"
    echo s:cmd
    let s:flist = system(s:cmd)
endfunction

function! VcsUpdateReceiveSvn()
    let s:cmd = "svn update"
    echo s:cmd
    let s:flist = system(s:cmd)
endfunction

function! VcsHelp()
    echom "VCS Help:"
    echom "- <leader>v  - this help"
    echom "- <leader>va - add file"
    echom "- <leader>vA - add all files"
    echom "- <leader>vb - show branchs"
    echom "- <leader>vc - commit"
    echom "- <leader>vd - hunk diff"
    echom "- <leader>vD - file diff"
    echom "- <leader>vo - open current line URL"
    echom "- <leader>vO - open repository URL"
    echom "- <leader>vm - mark conflict as resolved for current file"
    echom "- <leader>vl - blame"
    echom "- <leader>vL - log"
    echom "- <leader>vs - status"
    echom "- <leader>vS - echo status line"
    echom "- <leader>vu - receive changes from remote"
    echom "- <leader>vU - send changes to remote"
    echom "- <leader>vx - hunk undo"
    echom "- <leader>vX - remove file"
endfunction

nnoremap <silent> <leader>v  :call VcsHelp()<CR>
nmap              <leader>va :call VcsAddFile("")<left><left>
nnoremap <silent> <leader>vA :call VcsAddFiles()<CR>
nmap              <leader>vb :call VcsShowBranchs("")<left><left>
nmap              <leader>vc :call VcsCommit("","")<left><left><left><left><left>
nnoremap <silent> <leader>vd :SignifyHunkDiff<CR>
nmap              <leader>vD :call VcsDiff("")<left><left>
nnoremap <silent> <leader>vm :call VcsResolve()<CR>
nnoremap <silent> <leader>vo :call VcsOpenLineUrl()<CR>
nnoremap <silent> <leader>vO :call VcsOpenUrl()<CR>
nnoremap <silent> <leader>vl :call VcsBlame()<CR>
nnoremap <silent> <leader>vL :call VcsLog()<CR>
nnoremap <silent> <leader>vs :call VcsStatus()<CR>:bel copen<CR>
nnoremap <silent> <leader>vS :echo VcsStatusLine()<CR>
nnoremap <silent> <leader>vu :call VcsUpdateReceive()<CR>
nnoremap <silent> <leader>vU :call VcsUpdateSend()<CR>
nnoremap <silent> <leader>vx :SignifyHunkUndo<CR>
nnoremap <silent> <leader>vX :call VcsRmFile("")<left><left>

