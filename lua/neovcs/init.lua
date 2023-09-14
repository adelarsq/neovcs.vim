
if vim.g.loaded_neovcs then
    return
end

local M = {}

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

-- Based on https://github.com/pvdlg/conventional-changelog-metahub
function GetEmojiForCommit(commitMessage)
    local commitMessageLower = string.lower(commitMessage)

    if (starts_with(commitMessageLower, "feat")) then
        return "✨"
    end
    if (starts_with(commitMessageLower, "fix")) then
        return "🐛"
    end
    if (starts_with(commitMessageLower, "docs")) then
        return "📚"
    end
    if (starts_with(commitMessageLower, "style")) then
        return "💎"
    end
    if (starts_with(commitMessageLower, "perf")) then
        return "🚀"
    end
    if (starts_with(commitMessageLower, "test")) then
        return "🚨"
    end
    if (starts_with(commitMessageLower, "build")) then
        return "📦"
    end
    if (starts_with(commitMessageLower, "ci")) then
        return "⚙️"
    end
    if (starts_with(commitMessageLower, "chore")) then
        return "♻️"
    end
    if (starts_with(commitMessageLower, "revert")) then
        return "🗑"
    end
    if (starts_with(commitMessageLower, "refact")) then
        return "🔨"
    end
    return "";
end

function GetNvimTreeFilePath()
    local use, imported = pcall(require, "nvim-tree.lib")
    if use then
        local entry = imported.get_node_at_cursor()
        return entry.absolute_path
    end
    return ''
end

function GetOilFilePath()
    local use, imported = pcall(require, "oil")
    if use then
        local entry = imported.get_cursor_entry()

        if (entry['type'] == 'file') then
            local dir = imported.get_current_dir()
            local fileName = entry['name']
            local fullName = dir .. fileName

            return fullName
        end
    end
    return ''
end

function ShowMessage(arg)
    local success, notify = pcall(require, 'notify')
    if success then
        notify(arg)
    else
        print(arg)
    end
end

function ShowError(arg)
    local success, notify = pcall(require, 'notify')
    if success then
        notify(arg, 'error')
    else
        print(arg)
    end
end

function MercurialRoot()
    local path = vim.fn.expand('%:p:h')
    return vim.fn.finddir('.hg', path .. ';')
end

function BazaarRoot()
    local path = vim.fn.expand('%:p:h')
    return vim.fn.finddir('.bzr', path .. ';')
end

function DarcsRoot()
    local path = vim.fn.expand('%:p:h')
    return vim.fn.finddir('_darcs', path .. ';')
end

function GitRoot()
    local path = vim.fn.expand('%:p:h')
    return vim.fn.finddir('.git', path .. ';')
end

function SvnRoot()
    local path = vim.fn.expand('%:p:h')
    return vim.fn.finddir('.svn', path .. ';')
end

function VcsName()
    if #(GitRoot()) > 0 then
        return 'git'
    elseif #(SvnRoot()) > 0 then
        return 'svn'
    elseif #(DarcsRoot()) > 0 then
        return 'darcs'
    elseif #(BazaarRoot()) > 0 then
        return 'bazaar'
    elseif #(MercurialRoot()) > 0 then
        return 'mercurial'
    else
        return ''
    end
end

function VcsNamePath()
    -- TODO: Create better detection
    local cwdRoot = vim.fn.getcwd()

    local gitRoot = GitRoot()
    if #(gitRoot) > 0 then
        return { 'git', cwdRoot }
    end

    local svnRoot = SvnRoot()
    if #(svnRoot) > 0 then
        return { 'svn', cwdRoot }
    end

    local darcsRoot = DarcsRoot()
    if #(darcsRoot) > 0 then
        return { 'darcs', cwdRoot }
    end

    local bazaarRoot = BazaarRoot()
    if #(bazaarRoot) > 0 then
        return { 'bazaar', cwdRoot }
    end

    local mercurialRoot = MercurialRoot()
    if #(mercurialRoot) > 0 then
        return { 'mercurial', cwdRoot }
    end

    return {}
end

function VcsBranchName()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        return VcsGitBranchName()
    else
        ShowError("VCS not supported")
        return ''
    end
end

function VcsGitBranchName()
    local branch = vim.fn.systemlist('git branch')[1]
    local branchSplit = vim.fn.split(branch, ' ')[2]
    return branchSplit
end

function VcsCommit(...)
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        if select(1, ...) == '' then
            ShowError("Please add a commit message")
            return ''
        end
        local commitMessage = GetEmojiForCommit(select(1, ...)) .. ' ' .. select(1, ...)
        local cmd = 'git commit -m "' .. commitMessage .. '"'
        vim.fn.system(cmd)
        ShowMessage(cmd)
    elseif vcs_name == 'svn' then
        if select(1, ...) == '' then
            ShowError("Please add a commit message")
            return ''
        end
        if select(2, ...) == '' then
            ShowError("Please add a changelist name")
            return ''
        end
        local cmd = 'svn commit --changelist ' .. select(2, ...) .. ' -m "' .. select(1, ...) .. '"'
        vim.fn.system(cmd)
        ShowMessage(cmd)
    else
        ShowError("VCS not supported")
    end
end

function VcsAmend(...)
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        if select(1, ...) == '' then
            ShowError("Please add a commit message")
            return ''
        end
        local commitMessage = GetEmojiForCommit(select(1, ...)) .. ' ' .. select(1, ...)
        local cmd = 'git commit --amend -m "' .. commitMessage .. '"'
        vim.fn.system(cmd)
        ShowMessage(cmd)
    else
        ShowError("VCS not supported")
    end
end

function VcsDiff(...)
    local vcs_name = VcsName()
    if vcs_name == 'svn' then
        local cmd = 'svn diff -r ' .. select(1, ...)
        vim.fn.system(cmd)
        ShowMessage(cmd)
    else
        ShowError("VCS not supported")
    end
end

function VcsOpenLineUrl()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsOpenLineUrlGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsNextHunk()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        require('gitsigns').next_hunk({ navigation_message = false })
    else
        ShowError("VCS not supported")
    end
end

function VcsPrevHunk()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        require('gitsigns').prev_hunk({ navigation_message = false })
    else
        ShowError("VCS not supported")
    end
end

function VcsOpenLineUrlGit()
    local cmd = 'git config --get remote.origin.url'
    ShowMessage(cmd)

    local result = vim.fn.system(cmd)
    local split = vim.split(result, '\n')

    local branch = VcsGitBranchName()

    local relativeFilePath = vim.fn.expand('%:t')

    local line = vim.fn.line('.')

    local url = split[1] .. '/blob/' .. branch .. '/' .. relativeFilePath .. '#L' .. line

    vim.ui.open(url)
end

function VcsOpenUrl()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsOpenUrlGit()
    elseif vcs_name == 'svn' then
        VcsOpenUrlSvn()
    else
        ShowError("VCS not supported")
    end
end

function VcsOpenUrlGit()
    local cmd = 'git config --get remote.origin.url'
    ShowMessage(cmd)
    local result = vim.fn.system(cmd)
    local split = vim.split(result, '\n')
    local url = split[1]

    vim.ui.open(url)
end

function VcsOpenUrlSvn()
    local cmd = 'svn info --show-item repos-root-url'
    ShowMessage(cmd)
    local result = vim.fn.system(cmd)
    local split = vim.split(result, '\n')
    local url = split[1]

    vim.ui.open(url)
end

function VcsAddFile()
    local fullName = ''
    local filetype = vim.bo.filetype

    if filetype == 'oil' then
        fullName = GetOilFilePath()
    elseif filetype == 'NvimTree' then
        fullName = GetNvimTreeFilePath()
    else
        fullName = vim.fn.expand('%:p')
    end

    local cmd = ''
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        cmd = 'git add ' .. fullName
    elseif vcs_name == 'svn' then
        if arg[0] == 0 then
            cmd = 'svn add ' .. fullName
        else
            cmd = 'svn changelist ' .. arg[1] .. ' ' .. fullName
        end
    else
        ShowMessage('Is this file in a repository?')
        return
    end
    vim.fn.system(cmd)
    ShowMessage(cmd)
end

function VcsAddFiles(...)
    local cmd = ''
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        cmd = 'git add *'
    elseif vcs_name == 'svn' then
        if select(1, ...) == 0 then
            cmd = 'svn add *'
        else
            cmd = 'svn changelist ' .. select(1, ...) .. ' *'
        end
    else
        ShowMessage('Is this file in a repository?')
        return
    end
    vim.fn.system(cmd)
    ShowMessage(cmd)
end

function VcsShowBranches()
    local cmd = ''
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        cmd = 'git branch'
    else
        ShowMessage('Is this file in a repository?')
        return
    end
    vim.fn.system(cmd)
    ShowMessage(cmd)
end

function VcsRmFile(...)
    local filepath = vim.fn.expand('%:p')
    local cmd = ''
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        cmd = 'git rm ' .. filepath
    elseif vcs_name == 'svn' then
        if select(1, ...) == 0 then
            cmd = 'svn rm ' .. filepath
        else
            -- TODO
            cmd = 'svn changelist ' .. select(1, ...) .. ' ' .. filepath
        end
    else
        ShowMessage('Is this file in a repository?')
        return
    end
    vim.fn.system(cmd)
    ShowMessage(cmd)
end

function VcsBlameLine()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsBlameLineGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsBlameLineGit()
    -- Based on https://www.reddit.com/r/vim/comments/i50pce/how_to_show_commit_that_introduced_current_line
    local r = table.concat(
        vim.fn.systemlist("git -C " ..
            vim.fn.shellescape(vim.fn.expand('%:p:h')) .. " blame -L <line1>,<line2> " .. vim.fn.expand('%:t')), "\n")
    ShowMessage(r)
end

function VcsBlameFile()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsBlameFileGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsBlameFileGit()
    local cmd = 'git blame '
    ShowMessage(cmd)
    vim.fn.system(cmd)
end

function VcsResolve()
    local vcs_name = VcsName()
    if vcs_name == 'svn' then
        VcsResolveSvn()
    else
        ShowError("VCS not supported")
    end
end

function VcsResolveSvn()
    local filepath = vim.fn.expand('%:p')
    local cmd = 'svn resolve ' .. filepath
    ShowMessage(cmd)
    vim.fn.system(cmd)
end

function VcsLogFile()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsLogFileGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsLogFileGit()
    local filePath = vim.fn.expand('%:p')

    local cmd = 'git log --pretty=oneline -- filename ' .. filePath
    ShowMessage(cmd)
    local result = vim.fn.system(cmd)

    result = vim.split(result, '\n')

    -- Create the dictionaries used to populate the quickfix list
    local list = {}
    for _, item in ipairs(result) do
        local dic = { filename = "", text = item }
        table.insert(list, dic)
    end

    -- Populate the quickfix list
    vim.fn.setqflist(list)

    vim.cmd('bel copen 10')
end

function VcsLogProject()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsLogProjectGit()
    elseif vcs_name == 'svn' then
        VcsLogProjectSvn()
    else
        ShowError("VCS not supported")
    end
end

function VcsLogProjectGit()
    local cmd = 'git log --pretty=oneline'
    ShowMessage(cmd)
    local result = vim.fn.system(cmd)

    result = vim.split(result, '\n')

    -- Create the dictionaries used to populate the quickfix list
    local list = {}
    for _, item in ipairs(result) do
        local dic = { filename = '', text = item }
        table.insert(list, dic)
    end

    -- Populate the quickfix list
    vim.fn.setqflist(list)

    vim.cmd('bel copen 10')
end

function VcsLogProjectSvn()
    local cmd = 'svn log'
    ShowMessage(cmd)
    local result = vim.fn.system(cmd)

    result = vim.split(result, '\n')

    -- Create the dictionaries used to populate the quickfix list
    local list = {}
    for _, item in ipairs(result) do
        local dic = { filename = '', text = item }
        table.insert(list, dic)
    end

    -- Populate the quickfix list
    vim.fn.setqflist(list)

    vim.cmd('bel copen 10')
end

function VcsLogFileGraph()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsLogFileGraphGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsLogFileGraphGit()
    local filePath = vim.fn.expand('%:p')

    local cmd =
        "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -- filename " ..
        filePath
    ShowMessage(cmd)
    local result = vim.fn.system(cmd)

    result = vim.split(result, '\n')

    -- Create the dictionaries used to populate the quickfix list
    local list = {}
    for _, item in ipairs(result) do
        local dic = { filename = '', text = item }
        table.insert(list, dic)
    end

    -- Populate the quickfix list
    vim.fn.setqflist(list)

    vim.cmd('bel copen 10')
end

function VcsLogProjectGraph()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsLogProjectGitGraph()
    else
        ShowError("VCS not supported")
    end
end

function VcsLogProjectGitGraph()
    local cmd =
    "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    ShowMessage(cmd)
    local result = vim.fn.system(cmd)

    result = vim.split(result, '\n')

    -- Create the dictionaries used to populate the quickfix list
    local list = {}
    for _, item in ipairs(result) do
        local dic = { filename = '', text = item }
        table.insert(list, dic)
    end

    -- Populate the quickfix list
    vim.fn.setqflist(list)

    vim.cmd('bel copen 10')
end

function VcsUndoLastCommit()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsUndoLastCommitGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsUndoLastCommitGit()
    local cmd = 'git reset --soft HEAD~1'
    ShowMessage(cmd)
    vim.fn.system(cmd)
end

function VcsRevertLastCommit()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsRevertLastCommitGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsRevertLastCommitGit()
    local cmd = 'git revert HEAD'
    ShowMessage(cmd)
    vim.fn.system(cmd)
end

function VcsStatus()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsStatusGit()
    elseif vcs_name == 'svn' then
        VcsStatusSvn()
    else
        ShowError("VCS not supported")
    end
end

function VcsStatusGit()
    local cmd = 'git status --porcelain'
    ShowMessage(cmd)

    -- Get the result of git
    local flist = vim.fn.system(cmd)
    flist = vim.split(flist, '\n')

    -- Create the dictionaries used to populate the quickfix list
    local list = {}
    for _, f1 in ipairs(flist) do
        local f2 = vim.trim(f1)
        local glist = vim.split(f2, '\n')
        local a = glist[1]
        local b = glist[2]
        local dic = { filename = b, text = a }
        table.insert(list, dic)
    end

    -- Returns if no change is detected
    if #list == 0 then
        ShowMessage('no changes')
        return ''
    end

    -- Populate the qf list
    vim.fn.setqflist(list)

    vim.cmd('bel copen 10')
end

function VcsStatusSvn()
    local cmd = "svn status | awk '{print $1\" \"$2}'"
    ShowMessage(cmd)

    -- Get the result of svn
    local flist = vim.fn.system(cmd)
    flist = vim.split(flist, '\n')

    -- Create the dictionaries used to populate the quickfix list
    local list = {}
    for _, f in ipairs(flist) do
        local glist = vim.split(f, ' ')
        if #glist == 2 then
            local a = glist[1]
            local b = glist[2]
            local dic = { filename = b, text = a }
            table.insert(list, dic)
        end
    end

    -- Populate the qf list
    vim.fn.setqflist(list)
end

function GetLocalFileChangesForGit()
    -- Get the current buffer's file name
    local filename = vim.api.nvim_buf_get_name(0)

    -- Check if the file is tracked by Git
    local gitCommand = "git ls-files --error-unmatch " .. vim.fn.shellescape(filename)
    local gitOutput = io.popen(gitCommand)
    local fileExists = gitOutput:read("*a")
    gitOutput:close()

    -- Set the Git status symbol based on the file status
    local gitStatusSymbol = "?"

    if fileExists ~= "" then
        -- Check if the file is modified
        local gitDiffCommand = "git diff --name-only " .. vim.fn.shellescape(filename)
        local gitDiffOutput = io.popen(gitDiffCommand)
        local isModified = gitDiffOutput:read("*a")
        gitDiffOutput:close()

        if isModified ~= "" then
            gitStatusSymbol = "~" -- Modified
        else
            -- Check if the file is added or deleted
            local gitStatusCommand = "git status --porcelain --untracked-files=no " .. vim.fn.shellescape(filename)
            local gitStatusOutput = io.popen(gitStatusCommand)
            local gitStatus = gitStatusOutput:read("*a")
            gitStatusOutput:close()

            if gitStatus:match("^A") then
                gitStatusSymbol = "+" -- Added
            elseif gitStatus:match("^D") then
                gitStatusSymbol = "-" -- Deleted
            end
        end
    end

    -- Display the Git status symbol in the status line
    vim.api.nvim_command("echo '" .. gitStatusSymbol .. "'")

    return gitStatusSymbol
end

function VcsStatusLine()
    local vcs_name_path = VcsNamePath()

    if vim.tbl_isempty(vcs_name_path) then
        return ''
    end

    local vcs_name = vcs_name_path[1]
    local root_dir = vcs_name_path[2]

    local cd_root_dir = 'cd ' .. root_dir

    -- Get local file changes
    local hunkline = GetLocalFileChangesForGit()

    -- Shows conflicts on current file
    local mark_conflits = '≠'
    local light_line_vcs_conflits = ''
    if vcs_name == 'git' then
        light_line_vcs_conflits = mark_conflits .. VcsGitConflictMarker()
    else
        light_line_vcs_conflits = mark_conflits .. '0'
    end

    -- Get local repository changes
    local mark_local = '↑'
    local light_line_vcs_status_local = ''

    if vcs_name == 'git' then
        local status_update_list = vim.fn.systemlist(
            'git for-each-ref --format="%(HEAD) %(refname:short) %(push:track)" refs/heads | grep -o "[0-9]\\+"')
        if #status_update_list > 0 then
            light_line_vcs_status_local = mark_local .. status_update_list[1]
        else
            light_line_vcs_status_local = mark_local .. '0'
        end
    elseif vcs_name == 'svn' then
        local cmds = cd_root_dir .. '; svn status'
        local status_update_list_local = vim.fn.systemlist(cmds)
        if #status_update_list_local > 0 then
            light_line_vcs_status_local = mark_local .. #status_update_list_local
        else
            light_line_vcs_status_local = mark_local .. '0'
        end
    else
        light_line_vcs_status_local = mark_local .. '0'
    end

    -- Get remote changes
    local mark_behind = '↓'
    local light_line_vcs_status_behind = ''

    if vcs_name == 'git' then
        light_line_vcs_status_behind = mark_behind .. '?'
    elseif vcs_name == 'svn' then
        local cmds = cd_root_dir .. '; svn status -u | grep "        \\*"'
        local status_behind = vim.fn.systemlist(cmds)
        if #status_behind > 0 then
            light_line_vcs_status_behind = mark_behind .. #status_behind
        else
            light_line_vcs_status_behind = mark_behind .. '0'
        end
    else
        light_line_vcs_status_behind = mark_behind .. '0'
    end

    -- Shows conflicts on current repository
    local mark_repository_conflits = '≠'
    local light_line_vcs_repository_conflits = ''
    if vcs_name == 'git' then
        -- Based on: https://stackoverflow.com/questions/3065650/whats-the-simplest-way-to-list-conflicted-files-in-git
        local cmds = cd_root_dir .. '; git diff --name-only --diff-filter=U '
        local status_conflicts_repository = vim.fn.systemlist(cmds)
        light_line_vcs_repository_conflits = mark_repository_conflits .. #status_conflicts_repository
    elseif vcs_name == 'svn' then
        local cmds = cd_root_dir .. '; svn status|grep "Text conflicts"|sed \'\'s/[^0-9]*//g\'\' '
        local status_conflicts_repository = vim.fn.systemlist(cmds)
        if #status_conflicts_repository > 0 then
            light_line_vcs_repository_conflits = mark_repository_conflits .. status_conflicts_repository[1]
        else
            light_line_vcs_repository_conflits = mark_repository_conflits .. '0'
        end
    else
        light_line_vcs_repository_conflits = mark_repository_conflits .. '0'
    end

    -- Get branch name
    local mark_vcs = ''
    local vcs_name_branch = ''

    if not vim.b.vcs_name_branch then
        if vcs_name == 'git' then
            vcs_name_branch = vcs_name .. ' ' .. VcsGitBranchName()
        elseif vcs_name == 'svn' then
            local cmds = cd_root_dir ..
                "; svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$' "
            vcs_name_branch = vcs_name .. ' ' .. vim.fn.systemlist(cmds)[1]
        end
        vim.b.vcs_name_branch = vcs_name_branch
    else
        vcs_name_branch = vim.b.vcs_name_branch
    end

    return mark_vcs ..
        ' ' ..
        hunkline ..
        light_line_vcs_conflits ..
        ' ' ..
        light_line_vcs_status_local ..
        light_line_vcs_status_behind .. light_line_vcs_repository_conflits .. ' ' .. vcs_name_branch
end

function VcsGitConflictMarker()
    -- Checks for git conflict markers
    local annotation = '\\%([0-9A-Za-z_.:]+\\)\\?'
    local pattern = '^\\%(\\%(<\\{7} ' ..
        annotation .. '\\)\\|\\%(=\\{7\\}\\)\\|\\%(>\\{7\\} ' .. annotation .. '\\)\\)$'
    return vim.fn.search(pattern, 'nw')
end

function VcsUpdateSend()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsUpdateSendGit()
    else
        ShowError("VCS not supported")
    end
end

function VcsUpdateSendGit()
    local cmd = "git push"
    ShowMessage(cmd)
    vim.fn.system(cmd)
end

function VcsUpdateReceive()
    local vcs_name = VcsName()
    if vcs_name == 'git' then
        VcsUpdateReceiveGit()
    elseif vcs_name == 'svn' then
        VcsUpdateReceiveSvn()
    else
        ShowError("VCS not supported")
    end
end

function VcsUpdateReceiveGit()
    local cmd = "git pull"
    ShowMessage(cmd)
    vim.fn.system(cmd)
end

function VcsUpdateReceiveSvn()
    local cmd = "svn update"
    ShowMessage(cmd)
    vim.fn.system(cmd)
end

function VcsReload()
    VcsUpdateReceive()
    VcsUpdateSend()
end

function VcsHunkDiff()
    require('gitsigns').preview_hunk()
end

function VcsHunkUndo()
    require('gitsigns').reset_hunk()
end

function VcsHelp()
    print("VCS Help:")
    print("- <leader>v  - this help")
    print("- <leader>va - add file")
    print("- <leader>vA - add all files")
    print("- <leader>vb - blame line")
    print("- <leader>vB - blame file")
    print("- <leader>vc - commit")
    print("- <leader>vC - commit with amend")
    print("- <leader>vd - hunk diff")
    print("- <leader>vD - file diff")
    print("- <leader>vn - next hunk")
    print("- <leader>vN - prev hunk")
    print("- <leader>vo - open current line URL")
    print("- <leader>vO - open repository URL")
    print("- <leader>vm - mark conflict as resolved for current file")
    print("- <leader>vl - log for current file")
    print("- <leader>vL - log for the project")
    print("- <leader>vp - get changes from remote")
    print("- <leader>vP - send changes to remote")
    print("- <leader>vr - reload changes (get/send changes from/to remote)")
    print("- <leader>vs - status")
    print("- <leader>vt - show branches")
    print("- <leader>vu - hunk undo")
    print("- <leader>vU - undo last commit")
    print("- <leader>vx - remove file")
    print("- <leader>vX - revert last commit")
end

function M.setup()
    vim.api.nvim_set_keymap('n', '<leader>v', ':lua VcsHelp()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>va', ':lua VcsAddFile("")<left><left>', {})
    vim.api.nvim_set_keymap('n', '<leader>vA', ':lua VcsAddFiles("","")<left><left><left><left><left>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vb', ':lua VcsBlameLine()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vB', ':lua VcsBlameFile()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vc', ':lua VcsCommit("","")<left><left><left><left><left>', {})
    vim.api.nvim_set_keymap('n', '<leader>vC', ':lua VcsAmend("")<left><left><left>', {})
    vim.api.nvim_set_keymap('n', '<leader>vd', ':lua VcsHunkDiff()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vD', ':lua VcsDiff("")<left><left>', {})
    vim.api.nvim_set_keymap('n', '<leader>vl', ':lua VcsLogFile()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vL', ':lua VcsLogProject()<CR>', { silent = true })
    -- vim.api.nvim_set_keymap('n', '<leader>vg', ':lua VcsLogFileGraph()<CR>', {silent = true})
    -- vim.api.nvim_set_keymap('n', '<leader>vG', ':lua VcsLogProjectGraph()<CR>', {silent = true})
    vim.api.nvim_set_keymap('n', '<leader>vm', ':lua VcsResolve()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vn', ':lua VcsNextHunk()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vN', ':lua VcsPrevHunk()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vo', ':lua VcsOpenLineUrl()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vO', ':lua VcsOpenUrl()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vr', ':lua VcsReload()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vs', ':lua VcsStatus()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vp', ':lua VcsUpdateReceive()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vP', ':lua VcsUpdateSend()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vt', ':lua VcsShowBranchs()<CR>', {})
    vim.api.nvim_set_keymap('n', '<leader>vu', ':lua VcsHunkUndo()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vU', ':lua VcsUndoLastCommit()<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>vx', ':lua VcsRmFile("")<left><left>', {})
    vim.api.nvim_set_keymap('n', '<leader>vX', ':lua VcsRevertLastCommit()<CR>', { silent = true })

    vim.g.loaded_neovcs = 1
end

return M
