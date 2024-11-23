(when vim.g.loaded_neovcs (lua "return "))

(local M {})

(fn startsWith [str start]
  (= (str:sub 1 (length start)) start))

(set-forcibly! GetEmojiForCommit
               (fn [commit-message]
                 (let [commit-message-lower (string.lower commit-message)]
                   (when (startsWith commit-message-lower :feat)
                     (lua "return \"✨\""))
                   (when (startsWith commit-message-lower :fix)
                     (lua "return \"🐛\""))
                   (when (startsWith commit-message-lower :docs)
                     (lua "return \"📚\""))
                   (when (startsWith commit-message-lower :style)
                     (lua "return \"💎\""))
                   (when (startsWith commit-message-lower :perf)
                     (lua "return \"🚀\""))
                   (when (startsWith commit-message-lower :test)
                     (lua "return \"🚨\""))
                   (when (startsWith commit-message-lower :build)
                     (lua "return \"📦\""))
                   (when (startsWith commit-message-lower :ci)
                     (lua "return \"⚙️\""))
                   (when (startsWith commit-message-lower :chore)
                     (lua "return \"♻️\""))
                   (when (startsWith commit-message-lower :revert)
                     (lua "return \"🗑\""))
                   (when (startsWith commit-message-lower :refact)
                     (lua "return \"🔨\""))
                   "")))

(set-forcibly! GetNvimTreeFilePath
               (fn []
                 (let [(use imported) (pcall require :nvim-tree.lib)]
                   (when use (local entry (imported.get_node_at_cursor))
                     (let [___antifnl_rtn_1___ entry.absolute_path]
                       (lua "return ___antifnl_rtn_1___")))
                   "")))

(set-forcibly! GetOilFilePath (fn []
                                   (let [(use imported) (pcall require :oil)]
                                     (when use
                                       (local entry (imported.get_cursor_entry))
                                       (when (= (. entry :type) :file)
                                         (local dir (imported.get_current_dir))
                                         (local file-name (. entry :name))
                                         (local full-name (.. dir file-name))
                                         (let [___antifnl_rtn_1___ full-name]
                                           (lua "return ___antifnl_rtn_1___"))))
                                     "")))

(set-forcibly! ShowMessage
               (fn [arg]
                 (let [(success notify) (pcall require :notify)]
                   (if success (notify arg) (print arg)))))

(set-forcibly! ShowError
               (fn [arg]
                 (let [(success notify) (pcall require :notify)]
                   (if success (notify arg :error) (print arg)))))

(set-forcibly! MercurialRoot
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.hg (.. path ";")))))

(set-forcibly! BazaarRoot
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.bzr (.. path ";")))))

(set-forcibly! DarcsRoot
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :_darcs (.. path ";")))))

(set-forcibly! GitRoot
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.git (.. path ";")))))

(set-forcibly! SvnRoot
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.svn (.. path ";")))))

(set-forcibly! VcsName (fn []
                          (if (> (length (GitRoot)) 0) :git
                              (> (length (SvnRoot)) 0) :svn
                              (> (length (DarcsRoot)) 0) :darcs
                              (> (length (BazaarRoot)) 0) :bazaar
                              (> (length (MercurialRoot)) 0) :mercurial
                              "")))

(set-forcibly! VcsNamePath (fn []
                               (let [cwd-root (vim.fn.getcwd)
                                     git-root (GitRoot)]
                                 (when (> (length git-root) 0)
                                   (let [___antifnl_rtn_1___ [:git cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local svn-root (SvnRoot))
                                 (when (> (length svn-root) 0)
                                   (let [___antifnl_rtn_1___ [:svn cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local darcs-root (DarcsRoot))
                                 (when (> (length darcs-root) 0)
                                   (let [___antifnl_rtn_1___ [:darcs cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local bazaar-root (BazaarRoot))
                                 (when (> (length bazaar-root) 0)
                                   (let [___antifnl_rtn_1___ [:bazaar cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local mercurial-root (MercurialRoot))
                                 (when (> (length mercurial-root) 0)
                                   (let [___antifnl_rtn_1___ [:mercurial
                                                              cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 {})))

(set-forcibly! VcsBranchName (fn []
                                 (let [vcs-name (VcsName)]
                                   (if (= vcs-name :git) (VcsGitBranchName)
                                       (do
                                         (ShowError )
                                         "")))))

(set-forcibly! VcsGitBranchName
               (fn []
                 (let [branch (. (vim.fn.systemlist "git branch") 1)
                       branch-split (. (vim.fn.split branch " ") 2)]
                   branch-split)))

(set-forcibly! VcsCommit
               (fn [...]
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git)
                       (do
                         (when (= (select 2 ...) "")
                           (ShowError "Please add a commit message")
                           (lua "return \"\""))
                         (local commit-message
                                (.. (GetEmojiForCommit (select 2 ...)) " "
                                    (select 2 ...)))
                         (vim.fn.system (.. "git commit -m \"" commit-message
                                            "\"")))
                       (= vcs-name :svn)
                       (do
                         (when (= (select 2 ...) "")
                           (ShowError "Please add a commit message")
                           (lua "return \"\""))
                         (when (= (select 3 ...) "")
                           (ShowError "Please add a changelist name")
                           (lua "return \"\""))
                         (vim.fn.system (.. "svn commit --changelist "
                                            (select 3 ...) " -m \""
                                            (select 2 ...) "\"")))
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsAmend
               (fn [...]
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git)
                       (do
                         (when (= (select 1 ...) "")
                           (ShowError "Please add a commit message")
                           (lua "return \"\""))
                         (local commit-message
                                (.. (GetEmojiForCommit (select 1 ...)) " "
                                    (select 1 ...)))
                         (vim.fn.system (.. "git commit --amend -m \""
                                            commit-message "\"")))
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsDiff
               (fn [...]
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :svn)
                       (vim.fn.system (.. "svn diff -r " (select 1 ...)))
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsOpenLineUrl
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsOpenLineUrlGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsNextHunk
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git)
                       ((. (require :gitsigns) :next_hunk) {:navigation_message false})
                       (ShowError "VCS not supported")))))
(set-forcibly! VcsPrevHunk
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git)
                       ((. (require :gitsigns) :prev_hunk) {:navigation_message false})
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsOpenLineUrlGit
               (fn []
                 (let [cmd "git config --get remote.origin.url"]
                   (ShowMessage cmd)
                   (local result (vim.fn.system cmd))
                   (local split (vim.split result "\n"))
                   (local branch (VcsGitBranchName))
                   (local relative-file-path (vim.fn.expand "%:t"))
                   (local line (vim.fn.line "."))
                   (local url
                          (.. (. split 1) :/blob/ branch "/" relative-file-path
                              "#L" line))
                   (vim.ui.open url))))

(set-forcibly! VcsOpenUrl
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsOpenUrlGit)
                       (= vcs-name :svn) (VcsOpenUrlSvn)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsOpenUrlGit
               (fn []
                 (let [cmd "git config --get remote.origin.url"]
                   (ShowMessage cmd)
                   (local result (vim.fn.system cmd))
                   (local split (vim.split result "\n"))
                   (local url (. split 1))
                   (vim.ui.open url))))

(set-forcibly! VcsOpenUrlSvn
               (fn []
                 (let [cmd "svn info --show-item repos-root-url"]
                   (ShowMessage cmd)
                   (local result (vim.fn.system cmd))
                   (local split (vim.split result "\n"))
                   (local url (. split 1))
                   (vim.ui.open url))))

(set-forcibly! VcsAddFile (fn []
                              (var full-name "")
                              (local filetype vim.bo.filetype)
                              (if (= filetype :oil)
                                  (set full-name (Get-oil-file-path))
                                  (= filetype :NvimTree)
                                  (set full-name (Get-nvim-tree-file-path))
                                  (set full-name (vim.fn.expand "%:p")))
                              (var cmd "")
                              (local vcs-name (VcsName))
                              (if (= vcs-name :git)
                                  (set cmd (.. "git add " full-name))
                                  (= vcs-name :svn)
                                  (if (= (. arg 0) 0)
                                      (set cmd (.. "svn add " full-name))
                                      (set cmd
                                           (.. "svn changelist " (. arg 1) " "
                                               full-name)))
                                  (do
                                    (ShowMessage "Is this file in a repository?")
                                    (lua "return ")))
                              (vim.fn.system cmd)
                              (ShowMessage cmd)))

(set-forcibly! VcsAddFiles (fn [...]
                               (var cmd "")
                               (local vcs-name (VcsName))
                               (if (= vcs-name :git) (set cmd "git add *")
                                   (= vcs-name :svn)
                                   (if (= (select 1 ...) 0)
                                       (set cmd "svn add *")
                                       (set cmd
                                            (.. "svn changelist "
                                                (select 1 ...) " *")))
                                   (do
                                     (ShowMessage "Is this file in a repository?")
                                     (lua "return ")))
                               (vim.fn.system cmd)
                               (ShowMessage cmd)))

(set-forcibly! VcsShowBranches
               (fn []
                 (var cmd "")
                 (local vcs-name (VcsName))
                 (if (= vcs-name :git) (set cmd "git branch")
                     (do
                       (ShowMessage "Is this file in a repository?")
                       (lua "return ")))
                 (vim.fn.system cmd)
                 (ShowMessage cmd)))

(set-forcibly! VVsRmFile (fn [...]
                             (let [filepath (vim.fn.expand "%:p")]
                               (var cmd "")
                               (local vcs-name (VcsName))
                               (if (= vcs-name :git)
                                   (set cmd (.. "git rm " filepath))
                                   (= vcs-name :svn)
                                   (if (= (select 1 ...) 0)
                                       (set cmd (.. "svn rm " filepath))
                                       (set cmd
                                            (.. "svn changelist "
                                                (select 1 ...) " " filepath)))
                                   (do
                                     (ShowMessage "Is this file in a repository?")
                                     (lua "return ")))
                               (vim.fn.system cmd)
                               (ShowMessage cmd))))

(set-forcibly! VcsBlameLine
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsBlameLineGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsBlameLineGit
               (fn []
                 (let [r (table.concat (vim.fn.systemlist (.. "git -C "
                                                              (vim.fn.shellescape (vim.fn.expand "%:p:h"))
                                                              " blame -L <line1>,<line2> "
                                                              (vim.fn.expand "%:t")))
                                       "\n")]
                   (ShowMessage r))))

(set-forcibly! VcsBlameFile
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsBlameFileGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsBlameFileGit
               (fn []
                 (let [cmd "git blame "] (ShowMessage cmd) (vim.fn.system cmd))))

(set-forcibly! VcsResolve
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :svn) (VcsResolveSvn)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsResolveSvn
               (fn []
                 (let [filepath (vim.fn.expand "%:p")
                       cmd (.. "svn resolve " filepath)]
                   (ShowMessage cmd)
                   (vim.fn.system cmd))))

(set-forcibly! VcsLogFile
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsLogFileGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsLogFileGit
               (fn []
                 (let [file-path (vim.fn.expand "%:p")
                       cmd (.. "git log --pretty=oneline -- filename "
                               file-path)]
                   (ShowMessage cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! VcsLogProject
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsLogProjectGit)
                       (= vcs-name :svn) (VcsLogProjectSvn)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsLogProjectGit
               (fn []
                 (let [cmd "git log --pretty=oneline"]
                   (ShowMessage cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! VcsLogProjectSvn
               (fn []
                 (let [cmd "svn log"]
                   (ShowMessage cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! VcsLogFileGraph
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsLogFileGraphGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsLogFileGraphGit
               (fn []
                 (let [file-path (vim.fn.expand "%:p")
                       cmd (.. "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -- filename "
                               file-path)]
                   (ShowMessage cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! VcsLogProjectGraph
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsLogProjectGitGraph)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsLogProjectGitGraph
               (fn []
                 (let [cmd "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"]
                   (ShowMessage cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! VcsUndoLastCommit
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsUndoLastCommitGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsUndoLastCommitGit
               (fn []
                 (let [cmd "git reset --soft HEAD~1"] (ShowMessage cmd)
                   (vim.fn.system cmd))))

(set-forcibly! VcsRevertLastCommit
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsRevertLastCommitGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsRevertLastCommitGit
               (fn []
                 (let [cmd "git revert HEAD"] (ShowMessage cmd)
                   (vim.fn.system cmd))))

(set-forcibly! VcsStatus
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsStatusGit)
                       (= vcs-name :svn) (VcsStatusSvn)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsStatusGit
               (fn []
                 (let [cmd "git status --porcelain"]
                   (ShowMessage cmd)
                   (var flist (vim.fn.system cmd))
                   (set flist (vim.split flist "\n"))
                   (local list {})
                   (each [_ f1 (ipairs flist)] (local f2 (vim.trim f1))
                     (local glist (vim.split f2 "\n"))
                     (local a (. glist 1))
                     (local b (. glist 2))
                     (local dic {:filename b :text a})
                     (table.insert list dic))
                   (when (= (length list) 0) (ShowMessage "no changes")
                     (lua "return \"\""))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! VcsStatusSvn
               (fn []
                 (let [cmd "svn status | awk '{print $1\" \"$2}'"]
                   (ShowMessage cmd)
                   (var flist (vim.fn.system cmd))
                   (set flist (vim.split flist "\n"))
                   (local list {})
                   (each [_ f (ipairs flist)]
                     (local glist (vim.split f " "))
                     (when (= (length glist) 2) (local a (. glist 1))
                       (local b (. glist 2))
                       (local dic {:filename b :text a})
                       (table.insert list dic)))
                   (vim.fn.setqflist list))))

(set-forcibly! GetLocalFileChangesForGit
               (fn []
                 (let [filename (vim.api.nvim_buf_get_name 0)
                       git-command (.. "git ls-files --error-unmatch "
                                       (vim.fn.shellescape filename))
                       git-output (io.popen git-command)
                       file-exists (git-output:read :*a)]
                   (git-output:close)
                   (var git-status-symbol "?")
                   (when (not= file-exists "")
                     (local git-diff-command
                            (.. "git diff --name-only "
                                (vim.fn.shellescape filename)))
                     (local git-diff-output (io.popen git-diff-command))
                     (local is-modified (git-diff-output:read :*a))
                     (git-diff-output:close)
                     (if (not= is-modified "") (set git-status-symbol "~")
                         (let [git-status-command (.. "git status --porcelain --untracked-files=no "
                                                      (vim.fn.shellescape filename))
                               git-status-output (io.popen git-status-command)
                               git-status (git-status-output:read :*a)]
                           (git-status-output:close)
                           (if (git-status:match :^A)
                               (set git-status-symbol "+")
                               (git-status:match :^D)
                               (set git-status-symbol "-")))))
                   (vim.api.nvim_command (.. "echo '" git-status-symbol "'"))
                   git-status-symbol)))

(set-forcibly! VcsStatusLine
               (fn []
                 (let [vcs-name-path (VcsNamePath)]
                   (when (vim.tbl_isempty vcs-name-path) (lua "return \"\""))
                   (local vcs-name (. vcs-name-path 1))
                   (local root-dir (. vcs-name-path 2))
                   (local cd-root-dir (.. "cd " root-dir))
                   (local hunkline (Get-local-file-changes-for-git))
                   (local mark-conflits "≠")
                   (var light-line-vcs-conflits "")
                   (if (= vcs-name :git)
                       (set light-line-vcs-conflits
                            (.. mark-conflits (VcsGitConflictMarker)))
                       (set light-line-vcs-conflits (.. mark-conflits :0)))
                   (local mark-local "↑")
                   (var light-line-vcs-status-local "")
                   (if (= vcs-name :git)
                       (let [status-update-list (vim.fn.systemlist "git for-each-ref --format=\"%(HEAD) %(refname:short) %(push:track)\" refs/heads | grep -o \"[0-9]\\+\"")]
                         (if (> (length status-update-list) 0)
                             (set light-line-vcs-status-local
                                  (.. mark-local (. status-update-list 1)))
                             (set light-line-vcs-status-local
                                  (.. mark-local :0))))
                       (= vcs-name :svn)
                       (let [cmds (.. cd-root-dir "; svn status")
                             status-update-list-local (vim.fn.systemlist cmds)]
                         (if (> (length status-update-list-local) 0)
                             (set light-line-vcs-status-local
                                  (.. mark-local
                                      (length status-update-list-local)))
                             (set light-line-vcs-status-local
                                  (.. mark-local :0))))
                       (set light-line-vcs-status-local (.. mark-local :0)))
                   (local mark-behind "↓")
                   (var light-line-vcs-status-behind "")
                   (if (= vcs-name :git)
                       (set light-line-vcs-status-behind (.. mark-behind "?"))
                       (= vcs-name :svn)
                       (let [cmds (.. cd-root-dir
                                      "; svn status -u | grep \"        \\*\"")
                             status-behind (vim.fn.systemlist cmds)]
                         (if (> (length status-behind) 0)
                             (set light-line-vcs-status-behind
                                  (.. mark-behind (length status-behind)))
                             (set light-line-vcs-status-behind
                                  (.. mark-behind :0))))
                       (set light-line-vcs-status-behind (.. mark-behind :0)))
                   (local mark-repository-conflits "≠")
                   (var light-line-vcs-repository-conflits "")
                   (if (= vcs-name :git)
                       (let [cmds (.. cd-root-dir
                                      "; git diff --name-only --diff-filter=U ")
                             status-conflicts-repository (vim.fn.systemlist cmds)]
                         (set light-line-vcs-repository-conflits
                              (.. mark-repository-conflits
                                  (length status-conflicts-repository))))
                       (= vcs-name :svn)
                       (let [cmds (.. cd-root-dir
                                      "; svn status|grep \"Text conflicts\"|sed ''s/[^0-9]*//g'' ")
                             status-conflicts-repository (vim.fn.systemlist cmds)]
                         (if (> (length status-conflicts-repository) 0)
                             (set light-line-vcs-repository-conflits
                                  (.. mark-repository-conflits
                                      (. status-conflicts-repository 1)))
                             (set light-line-vcs-repository-conflits
                                  (.. mark-repository-conflits :0))))
                       (set light-line-vcs-repository-conflits
                            (.. mark-repository-conflits :0)))
                   (local mark-vcs "")
                   (var vcs-name-branch "")
                   (if (not vim.b.vcs_name_branch)
                       (do
                         (if (= vcs-name :git)
                             (set vcs-name-branch
                                  (.. vcs-name " " (VcsGitBranchName)))
                             (= vcs-name :svn)
                             (let [cmds (.. cd-root-dir
                                            "; svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$' ")]
                               (set vcs-name-branch
                                    (.. vcs-name " "
                                        (. (vim.fn.systemlist cmds) 1)))))
                         (set vim.b.vcs_name_branch vcs-name-branch))
                       (set vcs-name-branch vim.b.vcs_name_branch))
                   (.. mark-vcs " " hunkline light-line-vcs-conflits " "
                       light-line-vcs-status-local light-line-vcs-status-behind
                       light-line-vcs-repository-conflits " " vcs-name-branch))))

(set-forcibly! VcsGitConflictMarker
               (fn []
                 (let [annotation "\\%([0-9A-Za-z_.:]+\\)\\?"
                       pattern (.. "^\\%(\\%(<\\{7} " annotation
                                   "\\)\\|\\%(=\\{7\\}\\)\\|\\%(>\\{7\\} "
                                   annotation "\\)\\)$")]
                   (vim.fn.search pattern :nw))))

(set-forcibly! VcsUpdateSend
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsUpdateSendGit)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsUpdateSendGit
               (fn []
                 (let [cmd "git push"] (ShowMessage cmd) (vim.fn.system cmd))))

(set-forcibly! VcsUpdateReceive
               (fn []
                 (let [vcs-name (VcsName)]
                   (if (= vcs-name :git) (VcsUpdateReceiveGit)
                       (= vcs-name :svn) (VcsUpdateReceiveSvn)
                       (ShowError "VCS not supported")))))

(set-forcibly! VcsUpdateReceiveGit
               (fn []
                 (let [cmd "git pull"] (ShowMessage cmd) (vim.fn.system cmd))))

(set-forcibly! VcsUpdateReceiveSvn
               (fn []
                 (let [cmd "svn update"] (ShowMessage cmd) (vim.fn.system cmd))))

(set-forcibly! VcsReload (fn [] (VcsUpdateReceive) (VcsUpdateSend)))

(set-forcibly! VcsHunkDiff
               (fn []
                 ((. (require :gitsigns) :preview_hunk))))

(set-forcibly! VcsHunkUndo
               (fn []
                 ((. (require :gitsigns) :reset_hunk))))

(set-forcibly! VcsHelp
               (fn [] (print "VCS Help:") (print "- <leader>v  - this help")
                 (print "- <leader>va - add file")
                 (print "- <leader>vA - add all files")
                 (print "- <leader>vb - blame line")
                 (print "- <leader>vB - blame file")
                 (print "- <leader>vc - commit")
                 (print "- <leader>vC - commit with amend")
                 (print "- <leader>vd - hunk diff")
                 (print "- <leader>vD - file diff")
                 (print "- <leader>vn - next hunk")
                 (print "- <leader>vN - prev hunk")
                 (print "- <leader>vo - open current line URL")
                 (print "- <leader>vO - open repository URL")
                 (print "- <leader>vm - mark conflict as resolved for current file")
                 (print "- <leader>vl - log for current file")
                 (print "- <leader>vL - log for the project")
                 (print "- <leader>vp - get changes from remote")
                 (print "- <leader>vP - send changes to remote")
                 (print "- <leader>vr - reload changes (get/send changes from/to remote)")
                 (print "- <leader>vs - status")
                 (print "- <leader>vt - show branches")
                 (print "- <leader>vu - hunk undo")
                 (print "- <leader>vU - undo last commit")
                 (print "- <leader>vx - remove file")
                 (print "- <leader>vX - revert last commit")))

(fn M.setup []
  (vim.api.nvim_set_keymap :n :<leader>v ":lua VcsHelp()<CR>" {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>va ":lua VcsAddFile(\"\")<left><left>"
                           {})
  (vim.api.nvim_set_keymap :n :<leader>vA
                           ":lua VcsAddFiles(\"\",\"\")<left><left><left><left><left>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vb ":lua VcsBlameLine()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vB ":lua VcsBlameFile()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vc
                           ":lua VcsCommit(\"\",\"\")<left><left><left><left><left>"
                           {})
  (vim.api.nvim_set_keymap :n :<leader>vC
                           ":lua VcsAmend(\"\")<left><left><left>" {})
  (vim.api.nvim_set_keymap :n :<leader>vd ":lua VcsHunkDiff()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vD ":lua VcsDiff(\"\")<left><left>" {})
  (vim.api.nvim_set_keymap :n :<leader>vl ":lua VcsLogFile()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vL ":lua VcsLogProject()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vm ":lua VcsResolve()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vn ":lua VcsNextHunk()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vN ":lua VcsPrevHunk()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vo ":lua VcsOpenLineUrl()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vO ":lua VcsOpenUrl()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vr ":lua VcsReload()<CR>" {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vs ":lua VcsStatus()<CR>" {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vp ":lua VcsUpdateReceive()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vP ":lua VcsUpdateSend()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vt ":lua VcsShowBranchs()<CR>" {})
  (vim.api.nvim_set_keymap :n :<leader>vu ":lua VcsHunkUndo()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vU ":lua VcsUndoLastCommit()<CR>"
                           {:silent true})
  (vim.api.nvim_set_keymap :n :<leader>vx ":lua VcsRmFile(\"\")<left><left>" {})
  (vim.api.nvim_set_keymap :n :<leader>vX ":lua VcsRevertLastCommit()<CR>"
                           {:silent true})
  (set vim.g.loaded_neovcs 1))
M	
