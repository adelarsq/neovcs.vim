(when vim.g.loaded_neovcs (lua "return "))

(local M {})

(fn starts-with [str start]
  (= (str:sub 1 (length start)) start))

(set-forcibly! Get-emoji-for-commit
               (fn [commit-message]
                 (let [commit-message-lower (string.lower commit-message)]
                   (when (starts-with commit-message-lower :feat)
                     (lua "return \"✨\""))
                   (when (starts-with commit-message-lower :fix)
                     (lua "return \"🐛\""))
                   (when (starts-with commit-message-lower :docs)
                     (lua "return \"📚\""))
                   (when (starts-with commit-message-lower :style)
                     (lua "return \"💎\""))
                   (when (starts-with commit-message-lower :perf)
                     (lua "return \"🚀\""))
                   (when (starts-with commit-message-lower :test)
                     (lua "return \"🚨\""))
                   (when (starts-with commit-message-lower :build)
                     (lua "return \"📦\""))
                   (when (starts-with commit-message-lower :ci)
                     (lua "return \"⚙️\""))
                   (when (starts-with commit-message-lower :chore)
                     (lua "return \"♻️\""))
                   (when (starts-with commit-message-lower :revert)
                     (lua "return \"🗑\""))
                   (when (starts-with commit-message-lower :refact)
                     (lua "return \"🔨\""))
                   "")))

(set-forcibly! Get-nvim-tree-file-path
               (fn []
                 (let [(use imported) (pcall require :nvim-tree.lib)]
                   (when use (local entry (imported.get_node_at_cursor))
                     (let [___antifnl_rtn_1___ entry.absolute_path]
                       (lua "return ___antifnl_rtn_1___")))
                   "")))

(set-forcibly! Get-oil-file-path (fn []
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

(set-forcibly! Show-message
               (fn [arg]
                 (let [(success notify) (pcall require :notify)]
                   (if success (notify arg) (print arg)))))

(set-forcibly! Show-error
               (fn [arg]
                 (let [(success notify) (pcall require :notify)]
                   (if success (notify arg :error) (print arg)))))

(set-forcibly! Mercurial-root
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.hg (.. path ";")))))

(set-forcibly! Bazaar-root
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.bzr (.. path ";")))))

(set-forcibly! Darcs-root
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :_darcs (.. path ";")))))

(set-forcibly! Git-root
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.git (.. path ";")))))

(set-forcibly! Svn-root
               (fn []
                 (let [path (vim.fn.expand "%:p:h")]
                   (vim.fn.finddir :.svn (.. path ";")))))

(set-forcibly! Vcs-name (fn []
                          (if (> (length (Git-root)) 0) :git
                              (> (length (Svn-root)) 0) :svn
                              (> (length (Darcs-root)) 0) :darcs
                              (> (length (Bazaar-root)) 0) :bazaar
                              (> (length (Mercurial-root)) 0) :mercurial
                              "")))

(set-forcibly! Vcs-name-path (fn []
                               (let [cwd-root (vim.fn.getcwd)
                                     git-root (Git-root)]
                                 (when (> (length git-root) 0)
                                   (let [___antifnl_rtn_1___ [:git cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local svn-root (Svn-root))
                                 (when (> (length svn-root) 0)
                                   (let [___antifnl_rtn_1___ [:svn cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local darcs-root (Darcs-root))
                                 (when (> (length darcs-root) 0)
                                   (let [___antifnl_rtn_1___ [:darcs cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local bazaar-root (Bazaar-root))
                                 (when (> (length bazaar-root) 0)
                                   (let [___antifnl_rtn_1___ [:bazaar cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 (local mercurial-root (Mercurial-root))
                                 (when (> (length mercurial-root) 0)
                                   (let [___antifnl_rtn_1___ [:mercurial
                                                              cwd-root]]
                                     (lua "return ___antifnl_rtn_1___")))
                                 {})))

(set-forcibly! Vcs-branch-name (fn []
                                 (let [vcs-name (Vcs-name)]
                                   (if (= vcs-name :git) (Vcs-git-branch-name)
                                       (do
                                         (Show-error )
                                         "")))))

(set-forcibly! Vcs-git-branch-name
               (fn []
                 (let [branch (. (vim.fn.systemlist "git branch") 1)
                       branch-split (. (vim.fn.split branch " ") 2)]
                   branch-split)))

(set-forcibly! Vcs-commit
               (fn [...]
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git)
                       (do
                         (when (= (select 2 ...) "")
                           (Show-error "Please add a commit message")
                           (lua "return \"\""))
                         (local commit-message
                                (.. (Get-emoji-for-commit (select 2 ...)) " "
                                    (select 2 ...)))
                         (vim.fn.system (.. "git commit -m \"" commit-message
                                            "\"")))
                       (= vcs-name :svn)
                       (do
                         (when (= (select 2 ...) "")
                           (Show-error "Please add a commit message")
                           (lua "return \"\""))
                         (when (= (select 3 ...) "")
                           (Show-error "Please add a changelist name")
                           (lua "return \"\""))
                         (vim.fn.system (.. "svn commit --changelist "
                                            (select 3 ...) " -m \""
                                            (select 2 ...) "\"")))
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-amend
               (fn [...]
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git)
                       (do
                         (when (= (select 1 ...) "")
                           (Show-error "Please add a commit message")
                           (lua "return \"\""))
                         (local commit-message
                                (.. (Get-emoji-for-commit (select 1 ...)) " "
                                    (select 1 ...)))
                         (vim.fn.system (.. "git commit --amend -m \""
                                            commit-message "\"")))
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-diff
               (fn [...]
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :svn)
                       (vim.fn.system (.. "svn diff -r " (select 1 ...)))
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-open-line-url
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-open-line-url-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-next-hunk
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git)
                       ((. (require :gitsigns) :next_hunk) {:navigation_message false})
                       (Show-error "VCS not supported")))))
(set-forcibly! Vcs-prev-hunk
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git)
                       ((. (require :gitsigns) :prev_hunk) {:navigation_message false})
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-open-line-url-git
               (fn []
                 (let [cmd "git config --get remote.origin.url"]
                   (Show-message cmd)
                   (local result (vim.fn.system cmd))
                   (local split (vim.split result "\n"))
                   (local branch (Vcs-git-branch-name))
                   (local relative-file-path (vim.fn.expand "%:P"))
                   (local line (vim.fn.line "."))
                   (local url
                          (.. (. split 1) :/blob/ branch "/" relative-file-path
                              "#L" line))
                   (vim.ui.open url))))

(set-forcibly! Vcs-open-url
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-open-url-git)
                       (= vcs-name :svn) (Vcs-open-url-svn)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-open-url-git
               (fn []
                 (let [cmd "git config --get remote.origin.url"]
                   (Show-message cmd)
                   (local result (vim.fn.system cmd))
                   (local split (vim.split result "\n"))
                   (local url (. split 1))
                   (vim.ui.open url))))

(set-forcibly! Vcs-open-url-svn
               (fn []
                 (let [cmd "svn info --show-item repos-root-url"]
                   (Show-message cmd)
                   (local result (vim.fn.system cmd))
                   (local split (vim.split result "\n"))
                   (local url (. split 1))
                   (vim.ui.open url))))

(set-forcibly! Vcs-add-file (fn []
                              (var full-name "")
                              (local filetype vim.bo.filetype)
                              (if (= filetype :oil)
                                  (set full-name (Get-oil-file-path))
                                  (= filetype :NvimTree)
                                  (set full-name (Get-nvim-tree-file-path))
                                  (set full-name (vim.fn.expand "%:p")))
                              (var cmd "")
                              (local vcs-name (Vcs-name))
                              (if (= vcs-name :git)
                                  (set cmd (.. "git add " full-name))
                                  (= vcs-name :svn)
                                  (if (= (. arg 0) 0)
                                      (set cmd (.. "svn add " full-name))
                                      (set cmd
                                           (.. "svn changelist " (. arg 1) " "
                                               full-name)))
                                  (do
                                    (Show-message "Is this file in a repository?")
                                    (lua "return ")))
                              (vim.fn.system cmd)
                              (Show-message cmd)))

(set-forcibly! Vcs-add-files (fn [...]
                               (var cmd "")
                               (local vcs-name (Vcs-name))
                               (if (= vcs-name :git) (set cmd "git add *")
                                   (= vcs-name :svn)
                                   (if (= (select 1 ...) 0)
                                       (set cmd "svn add *")
                                       (set cmd
                                            (.. "svn changelist "
                                                (select 1 ...) " *")))
                                   (do
                                     (Show-message "Is this file in a repository?")
                                     (lua "return ")))
                               (vim.fn.system cmd)
                               (Show-message cmd)))

(set-forcibly! Vcs-show-branches
               (fn []
                 (var cmd "")
                 (local vcs-name (Vcs-name))
                 (if (= vcs-name :git) (set cmd "git branch")
                     (do
                       (Show-message "Is this file in a repository?")
                       (lua "return ")))
                 (vim.fn.system cmd)
                 (Show-message cmd)))

(set-forcibly! Vcs-rm-file (fn [...]
                             (let [filepath (vim.fn.expand "%:p")]
                               (var cmd "")
                               (local vcs-name (Vcs-name))
                               (if (= vcs-name :git)
                                   (set cmd (.. "git rm " filepath))
                                   (= vcs-name :svn)
                                   (if (= (select 1 ...) 0)
                                       (set cmd (.. "svn rm " filepath))
                                       (set cmd
                                            (.. "svn changelist "
                                                (select 1 ...) " " filepath)))
                                   (do
                                     (Show-message "Is this file in a repository?")
                                     (lua "return ")))
                               (vim.fn.system cmd)
                               (Show-message cmd))))

(set-forcibly! Vcs-blame-line
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-blame-line-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-blame-line-git
               (fn []
                 (let [r (table.concat (vim.fn.systemlist (.. "git -C "
                                                              (vim.fn.shellescape (vim.fn.expand "%:p:h"))
                                                              " blame -L <line1>,<line2> "
                                                              (vim.fn.expand "%:t")))
                                       "\n")]
                   (Show-message r))))

(set-forcibly! Vcs-blame-file
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-blame-file-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-blame-file-git
               (fn []
                 (let [cmd "git blame "] (Show-message cmd) (vim.fn.system cmd))))

(set-forcibly! Vcs-resolve
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :svn) (Vcs-resolve-svn)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-resolve-svn
               (fn []
                 (let [filepath (vim.fn.expand "%:p")
                       cmd (.. "svn resolve " filepath)]
                   (Show-message cmd)
                   (vim.fn.system cmd))))

(set-forcibly! Vcs-log-file
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-log-file-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-log-file-git
               (fn []
                 (let [file-path (vim.fn.expand "%:p")
                       cmd (.. "git log --pretty=oneline -- filename "
                               file-path)]
                   (Show-message cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! Vcs-log-project
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-log-project-git)
                       (= vcs-name :svn) (Vcs-log-project-svn)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-log-project-git
               (fn []
                 (let [cmd "git log --pretty=oneline"]
                   (Show-message cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! Vcs-log-project-svn
               (fn []
                 (let [cmd "svn log"]
                   (Show-message cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! Vcs-log-file-graph
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-log-file-graph-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-log-file-graph-git
               (fn []
                 (let [file-path (vim.fn.expand "%:p")
                       cmd (.. "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -- filename "
                               file-path)]
                   (Show-message cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! Vcs-log-project-graph
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-log-project-git-graph)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-log-project-git-graph
               (fn []
                 (let [cmd "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"]
                   (Show-message cmd)
                   (var result (vim.fn.system cmd))
                   (set result (vim.split result "\n"))
                   (local list {})
                   (each [_ item (ipairs result)]
                     (local dic {:filename "" :text item})
                     (table.insert list dic))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! Vcs-undo-last-commit
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-undo-last-commit-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-undo-last-commit-git
               (fn []
                 (let [cmd "git reset --soft HEAD~1"] (Show-message cmd)
                   (vim.fn.system cmd))))

(set-forcibly! Vcs-revert-last-commit
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-revert-last-commit-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-revert-last-commit-git
               (fn []
                 (let [cmd "git revert HEAD"] (Show-message cmd)
                   (vim.fn.system cmd))))

(set-forcibly! Vcs-status
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-status-git)
                       (= vcs-name :svn) (Vcs-status-svn)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-status-git
               (fn []
                 (let [cmd "git status --porcelain"]
                   (Show-message cmd)
                   (var flist (vim.fn.system cmd))
                   (set flist (vim.split flist "\n"))
                   (local list {})
                   (each [_ f1 (ipairs flist)] (local f2 (vim.trim f1))
                     (local glist (vim.split f2 "\n"))
                     (local a (. glist 1))
                     (local b (. glist 2))
                     (local dic {:filename b :text a})
                     (table.insert list dic))
                   (when (= (length list) 0) (Show-message "no changes")
                     (lua "return \"\""))
                   (vim.fn.setqflist list)
                   (vim.cmd "bel copen 10"))))

(set-forcibly! Vcs-status-svn
               (fn []
                 (let [cmd "svn status | awk '{print $1\" \"$2}'"]
                   (Show-message cmd)
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

(set-forcibly! Get-local-file-changes-for-git
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

(set-forcibly! Vcs-status-line
               (fn []
                 (let [vcs-name-path (Vcs-name-path)]
                   (when (vim.tbl_isempty vcs-name-path) (lua "return \"\""))
                   (local vcs-name (. vcs-name-path 1))
                   (local root-dir (. vcs-name-path 2))
                   (local cd-root-dir (.. "cd " root-dir))
                   (local hunkline (Get-local-file-changes-for-git))
                   (local mark-conflits "≠")
                   (var light-line-vcs-conflits "")
                   (if (= vcs-name :git)
                       (set light-line-vcs-conflits
                            (.. mark-conflits (Vcs-git-conflict-marker)))
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
                                  (.. vcs-name " " (Vcs-git-branch-name)))
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

(set-forcibly! Vcs-git-conflict-marker
               (fn []
                 (let [annotation "\\%([0-9A-Za-z_.:]+\\)\\?"
                       pattern (.. "^\\%(\\%(<\\{7} " annotation
                                   "\\)\\|\\%(=\\{7\\}\\)\\|\\%(>\\{7\\} "
                                   annotation "\\)\\)$")]
                   (vim.fn.search pattern :nw))))

(set-forcibly! Vcs-update-send
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-update-send-git)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-update-send-git
               (fn []
                 (let [cmd "git push"] (Show-message cmd) (vim.fn.system cmd))))

(set-forcibly! Vcs-update-receive
               (fn []
                 (let [vcs-name (Vcs-name)]
                   (if (= vcs-name :git) (Vcs-update-receive-git)
                       (= vcs-name :svn) (Vcs-update-receive-svn)
                       (Show-error "VCS not supported")))))

(set-forcibly! Vcs-update-receive-git
               (fn []
                 (let [cmd "git pull"] (Show-message cmd) (vim.fn.system cmd))))

(set-forcibly! Vcs-update-receive-svn
               (fn []
                 (let [cmd "svn update"] (Show-message cmd) (vim.fn.system cmd))))

(set-forcibly! Vcs-reload (fn [] (Vcs-update-receive) (Vcs-update-send)))

(set-forcibly! Vcs-hunk-diff
               (fn []
                 ((. (require :gitsigns) :preview_hunk))))

(set-forcibly! Vcs-hunk-undo
               (fn []
                 ((. (require :gitsigns) :reset_hunk))))

(set-forcibly! Vcs-help
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
