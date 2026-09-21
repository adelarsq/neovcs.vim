
if vim.g.loaded_neovcs then
  return
end

local M = {}

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

M.GetEmojiForCommit = function(commit_message)
  local commit_message_lower = string.lower(commit_message)
  if starts_with(commit_message_lower, "feat") then
    return "✨"
  end
  if starts_with(commit_message_lower, "fix") then
    return "🐛"
  end
  if starts_with(commit_message_lower, "docs") then
    return "📚"
  end
  if starts_with(commit_message_lower, "style") then
    return "💎"
  end
  if starts_with(commit_message_lower, "perf") then
    return "🚀"
  end
  if starts_with(commit_message_lower, "test") then
    return "🚨"
  end
  if starts_with(commit_message_lower, "build") then
    return "📦"
  end
  if starts_with(commit_message_lower, "ci") then
    return "⚙️"
  end
  if starts_with(commit_message_lower, "chore") then
    return "♻️"
  end
  if starts_with(commit_message_lower, "revert") then
    return "🗑"
  end
  if starts_with(commit_message_lower, "refact") then
    return "🔨"
  end
  return ""
end

M.GetNvimTreeFilePath = function()
  local use, imported = pcall(require, "nvim-tree.lib")
  if use then
    local entry = imported.get_node_at_cursor()
    return entry.absolute_path
  end
  return ""
end

M.GetOilFilePath = function()
  local use, imported = pcall(require, "oil")
  if use then
    local entry = imported.get_cursor_entry()
    if entry.type == "file" then
      local dir = imported.get_current_dir()
      local file_name = entry.name
      local full_name = dir .. file_name
      return full_name
    end
  end
  return ""
end

M.ShowMessage = function(arg)
  local success, notify = pcall(require, "notify")
  if success then
    notify(arg)
  else
    print(arg)
  end
end

M.ShowError = function(arg)
  local success, notify = pcall(require, "notify")
  if success then
    notify(arg, "error")
  else
    print(arg)
  end
end

M.MercurialRoot = function()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".hg", path .. ";")
end

M.BazaarRoot = function()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".bzr", path .. ";")
end

M.DarcsRoot = function()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir("_darcs", path .. ";")
end

M.GitRoot = function()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".git", path .. ";")
end

M.SvnRoot = function()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".svn", path .. ";")
end

M.VcsName = function()
  if #(M.GitRoot()) > 0 then
    return "git"
  elseif #(M.SvnRoot()) > 0 then
    return "svn"
  elseif #(M.DarcsRoot()) > 0 then
    return "darcs"
  elseif #(M.BazaarRoot()) > 0 then
    return "bazaar"
  elseif #(M.MercurialRoot()) > 0 then
    return "mercurial"
  else
    return ""
  end
end

M.VcsNamePath = function()
  local cwd_root = vim.fn.getcwd()
  local git_root = M.GitRoot()
  if #git_root > 0 then
    return { "git", cwd_root }
  end
  local svn_root = M.SvnRoot()
  if #svn_root > 0 then
    return { "svn", cwd_root }
  end
  local darcs_root = M.DarcsRoot()
  if #darcs_root > 0 then
    return { "darcs", cwd_root }
  end
  local bazaar_root = M.BazaarRoot()
  if #bazaar_root > 0 then
    return { "bazaar", cwd_root }
  end
  local mercurial_root = M.MercurialRoot()
  if #mercurial_root > 0 then
    return { "mercurial", cwd_root }
  end
  return {}
end

M.VcsBranchName = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsGitBranchName()
  else
    M.ShowError()
    return ""
  end
end

M.VcsGitBranchName = function()
  local result = vim.fn.systemlist("git branch --show-current")
  if vim.v.shell_error ~= 0 or not result or #result == 0 then
    return ""
  end
  local branch = vim.trim(result[1] or "")
  if branch == "" then
    -- Detached HEAD: try short SHA
    local sha = vim.fn.systemlist("git rev-parse --short HEAD")
    if vim.v.shell_error == 0 and sha and sha[1] and #sha[1] > 0 then
      return "(detached: " .. vim.trim(sha[1]) .. ")"
    end
    return "(detached)"
  end
  return branch
end

M.VcsCommit = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    local commit_message = vim.fn.input("Commit message: ")
    if commit_message == "" then
      M.ShowError("Please add a commit message")
      return ""
    end
    vim.fn.system("git commit -m \"" .. commit_message .. "\"")
  elseif vcs_name == "svn" then
    local commit_message = vim.fn.input("Commit message: ")
    if commit_message == "" then
      M.ShowError("Please add a commit message")
      return ""
    end
    local changelist_name = vim.fn.input("Changelist name: ")
    if changelist_name == "" then
      M.ShowError("Please add a changelist name")
      return ""
    end
    vim.fn.system("svn commit --changelist " .. changelist_name .. " -m \"" .. commit_message .. "\"")
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsAmend = function(...)
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    if select(1, ...) == "" then
      M.ShowError("Please add a commit message")
      return ""
    end
    local commit_message = select(1, ...) .. " " .. select(1, ...)
    vim.fn.system("git commit --amend -m \"" .. commit_message .. "\"")
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsDiff = function(...)
  local vcs_name = M.VcsName()
  if vcs_name == "svn" then
    vim.fn.system("svn diff -r " .. select(1, ...))
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsOpenLineUrl = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsOpenLineUrlGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsNextHunk = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    require("gitsigns").next_hunk({ navigation_message = false })
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsPrevHunk = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    require("gitsigns").prev_hunk({ navigation_message = false })
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsOpenLineUrlGit = function()
  local cmd = "git config --get remote.origin.url"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  local split = vim.split(result, "\n")
  local branch = M.VcsGitBranchName()
  local relative_file_path = vim.fn.expand("%:t")
  local line = vim.fn.line(".")
  local url = split[1] .. "/blob/" .. branch .. "/" .. relative_file_path .. "#L" .. line
  vim.ui.open(url)
end

M.VcsOpenUrl = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsOpenUrlGit()
  elseif vcs_name == "svn" then
    return M.VcsOpenUrlSvn()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsOpenUrlGit = function()
  local cmd = "git config --get remote.origin.url"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  local split = vim.split(result, "\n")
  local url = split[1]
  vim.ui.open(url)
end

M.VcsOpenUrlSvn = function()
  local cmd = "svn info --show-item repos-root-url"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  local split = vim.split(result, "\n")
  local url = split[1]
  vim.ui.open(url)
end

M.VcsAddFile = function()
  local full_name = ""
  local filetype = vim.bo.filetype
  if filetype == "oil" then
    full_name = M.GetOilFilePath()
  elseif filetype == "NvimTree" then
    full_name = M.GetNvimTreeFilePath()
  else
    full_name = vim.fn.expand("%:p")
  end
  local cmd = ""
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    cmd = "git add " .. full_name
  elseif vcs_name == "svn" then
    local changelist = vim.fn.input("Changelist name (optional): ")
    if changelist == "" then
      cmd = "svn add " .. full_name
    else
      cmd = "svn changelist " .. changelist .. " " .. full_name
    end
  else
    M.ShowMessage("Is this file in a repository?")
    return
  end
  vim.fn.system(cmd)
  M.ShowMessage(cmd)
end

M.VcsAddFiles = function()
  local cmd = ""
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    cmd = "git add *"
  elseif vcs_name == "svn" then
    local changelist = vim.fn.input("Changelist name (optional): ")
    if changelist == "" then
      cmd = "svn add *"
    else
      cmd = "svn changelist " .. changelist .. " *"
    end
  else
    M.ShowMessage("Is this file in a repository?")
    return
  end
  vim.fn.system(cmd)
  M.ShowMessage(cmd)
end

M.VcsShowBranches = function()
  local vcs_name = M.VcsName()
  if vcs_name ~= "git" then
    M.ShowMessage("Is this file in a repository?")
    return
  end

  local current_branch = M.VcsGitBranchName() or ""

  -- Local branches
  local local_branches = {}
  local local_set = {}
  for _, branch in ipairs(vim.fn.systemlist("git branch --format='%(refname:short)'")) do
    local trimmed = vim.trim(branch)
    if #trimmed > 0 then
      table.insert(local_branches, trimmed)
      local_set[trimmed] = true
    end
  end

  -- Remote branches (excluding */HEAD)
  local remote_branches = {}
  for _, branch in ipairs(vim.fn.systemlist("git branch -r --format='%(refname:short)'")) do
    local trimmed = vim.trim(branch)
    if #trimmed > 0 and not trimmed:match("/HEAD$") then
      local short_name = trimmed:match("^[^/]+/(.+)$") or trimmed
      if not local_set[short_name] then
        table.insert(remote_branches, trimmed)
      end
    end
  end

  table.sort(local_branches)
  table.sort(remote_branches)

  -- Build selection items
  local items = {}

  for _, branch in ipairs(local_branches) do
    table.insert(items, {
      name = branch,
      is_remote = false,
      display = (branch == current_branch and "* " or "  ") .. branch,
    })
  end

  if #remote_branches > 0 then
    table.insert(items, { separator = true, display = "── remote branches ──" })
    for _, branch in ipairs(remote_branches) do
      table.insert(items, {
        name = branch,
        is_remote = true,
        display = "  🌐 " .. branch,
      })
    end
  end

  if #items == 0 then
    M.ShowError("No branches found")
    return
  end

  vim.ui.select(items, {
    prompt = "Select branch"
      .. (current_branch ~= "" and (" (current: " .. current_branch .. ")") or "")
      .. ":",
    format_item = function(item)
      return item.display
    end,
  }, function(choice)
    if not choice or choice.separator then
      return
    end

    if not choice.is_remote then
      -- Local branch
      if choice.name == current_branch then
        M.ShowMessage("Already on branch: " .. choice.name)
        return
      end
      local cmd = "git checkout " .. vim.fn.shellescape(choice.name)
      M.ShowMessage(cmd)
      local result = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        M.ShowError("Failed to switch branch: " .. result)
      else
        M.ShowMessage("Switched to branch: " .. choice.name)
        vim.b.vcs_name_branch = nil
      end
    else
      -- Remote branch: create local tracking branch if needed
      local remote = choice.name
      local local_name = remote:match("^[^/]+/(.+)$") or remote

      local cmd
      if local_set[local_name] then
        cmd = "git checkout " .. vim.fn.shellescape(local_name)
      else
        cmd = "git checkout --track " .. vim.fn.shellescape(remote)
      end

      M.ShowMessage(cmd)
      local result = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        M.ShowError("Failed to checkout remote branch: " .. result)
      else
        M.ShowMessage("Switched to branch: " .. local_name)
        vim.b.vcs_name_branch = nil
      end
    end
  end)
end

M.VcsRmFile = function()
  local filepath = vim.fn.expand("%:p")
  local cmd = ""
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    cmd = "git rm " .. filepath
  elseif vcs_name == "svn" then
    local changelist = vim.fn.input("Changelist name (optional): ")
    if changelist == "" then
      cmd = "svn rm " .. filepath
    else
      cmd = "svn changelist " .. changelist .. " " .. filepath
    end
  else
    M.ShowMessage("Is this file in a repository?")
    return
  end
  vim.fn.system(cmd)
  M.ShowMessage(cmd)
end

M.VcsBlameLine = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsBlameLineGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsBlameLineGit = function()
  local r = table.concat(vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " blame -L " .. vim.fn.line(".") .. "," .. vim.fn.line(".") .. " " .. vim.fn.expand("%:t")), "\n")
  M.ShowMessage(r)
end

M.VcsBlameFile = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsBlameFileGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsBlameFileGit = function()
  local cmd = "git blame "
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
end

M.VcsResolve = function()
  local vcs_name = M.VcsName()
  if vcs_name == "svn" then
    return M.VcsResolveSvn()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsResolveSvn = function()
  local filepath = vim.fn.expand("%:p")
  local cmd = "svn resolve " .. filepath
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
end

M.VcsLogFile = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsLogFileGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsLogFileGit = function()
  local file_path = vim.fn.expand("%:p")
  local cmd = "git log --pretty=oneline -- " .. file_path
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    if #item > 0 then
      local dic = { filename = "", text = item }
      table.insert(list, dic)
    end
  end
  vim.fn.setqflist(list)
  vim.cmd("bel copen 10")
end

M.VcsLogProject = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsLogProjectGit()
  elseif vcs_name == "svn" then
    return M.VcsLogProjectSvn()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsLogProjectGit = function()
  local cmd = "git log --pretty=oneline"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    if #item > 0 then
      local dic = { filename = "", text = item }
      table.insert(list, dic)
    end
  end
  vim.fn.setqflist(list)
  vim.cmd("bel copen 10")
end

M.VcsLogProjectSvn = function()
  local cmd = "svn log"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    if #item > 0 then
      local dic = { filename = "", text = item }
      table.insert(list, dic)
    end
  end
  vim.fn.setqflist(list)
  vim.cmd("bel copen 10")
end

M.VcsLogFileGraph = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsLogFileGraphGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsLogFileGraphGit = function()
  local file_path = vim.fn.expand("%:p")
  local cmd = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -- " .. file_path
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    if #item > 0 then
      local dic = { filename = "", text = item }
      table.insert(list, dic)
    end
  end
  vim.fn.setqflist(list)
  vim.cmd("bel copen 10")
end

M.VcsLogProjectGraph = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsLogProjectGitGraph()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsLogProjectGitGraph = function()
  local cmd = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    if #item > 0 then
      local dic = { filename = "", text = item }
      table.insert(list, dic)
    end
  end
  vim.fn.setqflist(list)
  vim.cmd("bel copen 10")
end

M.VcsUndoLastCommit = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsUndoLastCommitGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsUndoLastCommitGit = function()
  local cmd = "git reset --soft HEAD~1"
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
end

M.VcsRevertLastCommit = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsRevertLastCommitGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsRevertLastCommitGit = function()
  local cmd = "git revert HEAD"
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
end

M.VcsStatus = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsStatusGit()
  elseif vcs_name == "svn" then
    return M.VcsStatusSvn()
  else
    M.ShowError("VCS not supported")
  end
end

-- Helper: run git command and refresh quickfix
local function git_run_and_refresh(cmd, msg)
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    M.ShowError("Failed: " .. result)
    return false
  end
  M.ShowMessage(msg or cmd)
  return true
end

-- Get current entry path from quickfix window
local function qf_current_path()
  local qf = vim.fn.getqflist({ idx = 0, items = 0 })
  local idx = qf.idx
  if idx < 1 or idx > #qf.items then
    return nil
  end
  local item = qf.items[idx]
  if not item.filename or item.filename == "" then
    return nil
  end
  return item.filename
end

-- Stage current quickfix entry
M.VcsStageCurrent = function()
  local path = qf_current_path()
  if not path then
    M.ShowError("No file under cursor")
    return
  end
  if git_run_and_refresh("git add " .. vim.fn.shellescape(path), "Staged: " .. path) then
    -- Remember cursor path so we can re-focus after refresh
    local last_path = path
    vim.schedule(function()
      M.VcsStatusGit(last_path)
    end)
  end
end

-- Unstage current quickfix entry
M.VcsUnstageCurrent = function()
  local path = qf_current_path()
  if not path then
    M.ShowError("No file under cursor")
    return
  end
  -- Check if there's a HEAD (repo has commits)
  local has_head = vim.fn.systemlist("git rev-parse --verify HEAD")[1] ~= ""
  local cmd
  if has_head then
    cmd = "git restore --staged " .. vim.fn.shellescape(path)
  else
    cmd = "git rm --cached " .. vim.fn.shellescape(path)
  end
  if git_run_and_refresh(cmd, "Unstaged: " .. path) then
    local last_path = path
    vim.schedule(function()
      M.VcsStatusGit(last_path)
    end)
  end
end

-- Toggle: if staged -> unstage, else stage
M.VcsToggleStageCurrent = function()
  local path = qf_current_path()
  if not path then
    M.ShowError("No file under cursor")
    return
  end
  -- Determine if the file is currently staged
  local out = vim.fn.systemlist("git status --porcelain -- " .. vim.fn.shellescape(path))
  if #out == 0 then
    M.ShowError("No status for: " .. path)
    return
  end
  local x = out[1]:sub(1, 1)
  local staged = x ~= " " and x ~= "?"
  if staged then
    M.VcsUnstageCurrent()
  else
    M.VcsStageCurrent()
  end
end

-- Stage all files
M.VcsStageAll = function()
  if git_run_and_refresh("git add -A", "Staged all files") then
    vim.schedule(function() M.VcsStatusGit() end)
  end
end

-- Unstage all files
M.VcsUnstageAll = function()
  local has_head = vim.fn.systemlist("git rev-parse --verify HEAD")[1] ~= ""
  local cmd
  if has_head then
    cmd = "git reset HEAD"
  else
    cmd = "git rm -r --cached ."
  end
  if git_run_and_refresh(cmd, "Unstaged all files") then
    vim.schedule(function() M.VcsStatusGit() end)
  end
end

-- Optional: pass a path to focus on after refresh
M.VcsStatusGit = function(focus_path)
  local cmd = "git status --porcelain"
  M.ShowMessage(cmd)

  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    M.ShowError("git status failed")
    return
  end

  local staged = {}
  local unstaged = {}
  local untracked = {}
  local conflicted = {}

  for _, line in ipairs(output) do
    if #line > 0 then
      local x = line:sub(1, 1) -- staged status
      local y = line:sub(2, 2) -- unstaged status
      local path = line:sub(4)

      local rename_target = path:match("%-> (.+)$")
      if rename_target then
        path = rename_target
      end

      if x == "U" or y == "U" or (x == "A" and y == "A") or (x == "D" and y == "D") then
        table.insert(conflicted, { filename = path, text = "UU " .. path })
      else
        if x ~= " " and x ~= "?" then
          table.insert(staged, { filename = path, text = string.format("%-2s %s", x, path) })
        end
        if x == "?" and y == "?" then
          table.insert(untracked, { filename = path, text = "?? " .. path })
        end
        if y ~= " " and y ~= "?" then
          table.insert(unstaged, { filename = path, text = string.format("%2s %s", y, path) })
        end
      end
    end
  end

  local list = {}
  local function add_section(title, items)
    if #items > 0 then
      table.insert(list, { filename = "", text = title })
      for _, item in ipairs(items) do table.insert(list, item) end
    end
  end

  add_section("=== Conflicted ===", conflicted)
  add_section("=== Staged (use <leader>v- to unstage) ===", staged)
  add_section("=== Unstaged (use <leader>v+ to stage) ===", unstaged)
  add_section("=== Untracked (use <leader>v+ to stage) ===", untracked)

  if #list == 0 then
    M.ShowMessage("no changes")
    return
  end

  vim.fn.setqflist(list)
  vim.cmd("bel copen 10")

  -- Set buffer-local keymaps in the quickfix window
  local qf_buf = vim.api.nvim_get_current_buf()
  local opts = { buffer = qf_buf, silent = true, noremap = true }

  vim.keymap.set("n", "<leader>v+", function()
    local p = qf_current_path()
    if not p then return end
    if git_run_and_refresh("git add " .. vim.fn.shellescape(p), "Staged: " .. p) then
      vim.schedule(function() M.VcsStatusGit(p) end)
    end
  end, vim.tbl_extend("force", opts, { desc = "Stage file" }))

  vim.keymap.set("n", "<leader>v-", function()
    local p = qf_current_path()
    if not p then return end
    local has_head = vim.fn.systemlist("git rev-parse --verify HEAD")[1] ~= ""
    local cmd = has_head
      and ("git restore --staged " .. vim.fn.shellescape(p))
      or  ("git rm --cached " .. vim.fn.shellescape(p))
    if git_run_and_refresh(cmd, "Unstaged: " .. p) then
      vim.schedule(function() M.VcsStatusGit(p) end)
    end
  end, vim.tbl_extend("force", opts, { desc = "Unstage file" }))

  vim.keymap.set("n", "<leader>v=", function()
    local p = qf_current_path()
    if not p then return end
    local out = vim.fn.systemlist("git status --porcelain -- " .. vim.fn.shellescape(p))
    if #out == 0 then
      M.ShowError("No status for: " .. p)
      return
    end
    local x = out[1]:sub(1, 1)
    local staged = x ~= " " and x ~= "?"
    local cmd = staged
      and (vim.fn.systemlist("git rev-parse --verify HEAD")[1] ~= ""
            and ("git restore --staged " .. vim.fn.shellescape(p))
            or  ("git rm --cached " .. vim.fn.shellescape(p)))
      or  ("git add " .. vim.fn.shellescape(p))
    if git_run_and_refresh(cmd, (staged and "Unstaged: " or "Staged: ") .. p) then
      vim.schedule(function() M.VcsStatusGit(p) end)
    end
  end, vim.tbl_extend("force", opts, { desc = "Toggle stage/unstage" }))

  vim.keymap.set("n", "<leader>vS", function()
    if git_run_and_refresh("git add -A", "Staged all") then
      vim.schedule(function() M.VcsStatusGit() end)
    end
  end, vim.tbl_extend("force", opts, { desc = "Stage all files" }))

  vim.keymap.set("n", "<leader>vU", function()
    local has_head = vim.fn.systemlist("git rev-parse --verify HEAD")[1] ~= ""
    local cmd = has_head and "git reset HEAD" or "git rm -r --cached ."
    if git_run_and_refresh(cmd, "Unstaged all") then
      vim.schedule(function() M.VcsStatusGit() end)
    end
  end, vim.tbl_extend("force", opts, { desc = "Unstage all files" }))

  -- Refocus the entry on the same file after refresh
  if focus_path and focus_path ~= "" then
    vim.schedule(function()
      local items = vim.fn.getqflist()
      for i, item in ipairs(items) do
        if item.filename == focus_path then
          vim.fn.setqflist({}, "r", { idx = i })
          break
        end
      end
    end)
  end
end

M.VcsStatusSvn = function()
  local cmd = "svn status"
  M.ShowMessage(cmd)

  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    M.ShowError("svn status failed")
    return
  end

  local added = {}
  local modified = {}
  local deleted = {}
  local untracked = {}
  local conflicted = {}

  for _, line in ipairs(output) do
    if #line > 0 then
      local status = line:sub(1, 1)
      local path = vim.trim(line:sub(2))

      if status == "A" then
        table.insert(added, { filename = path, text = "A  " .. path })
      elseif status == "M" then
        table.insert(modified, { filename = path, text = "M  " .. path })
      elseif status == "D" then
        table.insert(deleted, { filename = path, text = "D  " .. path })
      elseif status == "?" then
        table.insert(untracked, { filename = path, text = "?  " .. path })
      elseif status == "C" then
        table.insert(conflicted, { filename = path, text = "C  " .. path })
      end
    end
  end

  local list = {}
  local function add_section(title, items)
    if #items > 0 then
      table.insert(list, { filename = "", text = title })
      for _, item in ipairs(items) do table.insert(list, item) end
    end
  end

  add_section("=== Conflicted ===", conflicted)
  add_section("=== Added ===", added)
  add_section("=== Modified ===", modified)
  add_section("=== Deleted ===", deleted)
  add_section("=== Untracked ===", untracked)

  if #list > 0 then
    vim.fn.setqflist(list)
    vim.cmd("bel copen 10")
  else
    M.ShowMessage("no changes")
  end
end

M.GetLocalFileChangesForGit = function()
  local filename = vim.api.nvim_buf_get_name(0)
  local git_command = "git ls-files --error-unmatch " .. vim.fn.shellescape(filename)
  local git_output = io.popen(git_command)
  local file_exists = git_output:read("*a")
  git_output:close()
  local git_status_symbol = "?"
  if file_exists ~= "" then
    local git_diff_command = "git diff --name-only " .. vim.fn.shellescape(filename)
    local git_diff_output = io.popen(git_diff_command)
    local is_modified = git_diff_output:read("*a")
    git_diff_output:close()
    if is_modified ~= "" then
      git_status_symbol = "~"
    else
      local git_status_command = "git status --porcelain --untracked-files=no " .. vim.fn.shellescape(filename)
      local git_status_output = io.popen(git_status_command)
      local git_status = git_status_output:read("*a")
      git_status_output:close()
      if git_status:match("^A") then
        git_status_symbol = "+"
      elseif git_status:match("^D") then
        git_status_symbol = "-"
      end
    end
  end
  vim.api.nvim_command("echo '" .. git_status_symbol .. "'")
  return git_status_symbol
end

M.VcsStatusLine = function()
  local vcs_name_path = M.VcsNamePath()
  if vim.tbl_isempty(vcs_name_path) then
    return ""
  end
  local vcs_name = vcs_name_path[1]
  local root_dir = vcs_name_path[2]
  local cd_root_dir = "cd " .. root_dir
  local hunkline = M.GetLocalFileChangesForGit()
  local mark_conflits = "≠"
  local light_line_vcs_conflits = ""
  if vcs_name == "git" then
    light_line_vcs_conflits = mark_conflits .. M.VcsGitConflictMarker()
  else
    light_line_vcs_conflits = mark_conflits .. "0"
  end
  local mark_local = "↑"
  local light_line_vcs_status_local = ""
  if vcs_name == "git" then
    local status_update_list = vim.fn.systemlist("git for-each-ref --format=\"%(HEAD) %(refname:short) %(push:track)\" refs/heads | grep -o \"[0-9]\\+\"")
    if #status_update_list > 0 then
      light_line_vcs_status_local = mark_local .. status_update_list[1]
    else
      light_line_vcs_status_local = mark_local .. "0"
    end
  elseif vcs_name == "svn" then
    local cmds = cd_root_dir .. "; svn status"
    local status_update_list_local = vim.fn.systemlist(cmds)
    if #status_update_list_local > 0 then
      light_line_vcs_status_local = mark_local .. #status_update_list_local
    else
      light_line_vcs_status_local = mark_local .. "0"
    end
  else
    light_line_vcs_status_local = mark_local .. "0"
  end
  local mark_behind = "↓"
  local light_line_vcs_status_behind = ""
  if vcs_name == "git" then
    light_line_vcs_status_behind = mark_behind .. "?"
  elseif vcs_name == "svn" then
    local cmds = cd_root_dir .. "; svn status -u | grep \"        \\*\""
    local status_behind = vim.fn.systemlist(cmds)
    if #status_behind > 0 then
      light_line_vcs_status_behind = mark_behind .. #status_behind
    else
      light_line_vcs_status_behind = mark_behind .. "0"
    end
  else
    light_line_vcs_status_behind = mark_behind .. "0"
  end
  local mark_repository_conflits = "≠"
  local light_line_vcs_repository_conflits = ""
  if vcs_name == "git" then
    local cmds = cd_root_dir .. "; git diff --name-only --diff-filter=U "
    local status_conflicts_repository = vim.fn.systemlist(cmds)
    light_line_vcs_repository_conflits = mark_repository_conflits .. #status_conflicts_repository
  elseif vcs_name == "svn" then
    local cmds = cd_root_dir .. "; svn status|grep \"Text conflicts\"|sed ''s/[^0-9]*//g'' "
    local status_conflicts_repository = vim.fn.systemlist(cmds)
    if #status_conflicts_repository > 0 then
      light_line_vcs_repository_conflits = mark_repository_conflits .. status_conflicts_repository[1]
    else
      light_line_vcs_repository_conflits = mark_repository_conflits .. "0"
    end
  else
    light_line_vcs_repository_conflits = mark_repository_conflits .. "0"
  end
  local mark_vcs = ""
  local vcs_name_branch = ""
  if not vim.b.vcs_name_branch then
    if vcs_name == "git" then
      vcs_name_branch = vcs_name .. " " .. M.VcsGitBranchName()
    elseif vcs_name == "svn" then
      local cmds = cd_root_dir .. "; svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$' "
      vcs_name_branch = vcs_name .. " " .. vim.fn.systemlist(cmds)[1]
    end
    vim.b.vcs_name_branch = vcs_name_branch
  else
    vcs_name_branch = vim.b.vcs_name_branch
  end
  return mark_vcs .. " " .. hunkline .. light_line_vcs_conflits .. " " .. light_line_vcs_status_local .. light_line_vcs_status_behind .. light_line_vcs_repository_conflits .. " " .. vcs_name_branch
end

M.VcsGitConflictMarker = function()
  local annotation = "\\%([0-9A-Za-z_.:]+\\)\\?"
  local pattern = "^\\%(\\%(<\\{7} " .. annotation .. "\\)\\|\\%(=\\{7\\}\\)\\|\\%(>\\{7\\} " .. annotation "\\)\\)$"
  return vim.fn.search(pattern, "nw")
end

M.VcsUpdateSend = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsUpdateSendGit()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsUpdateSendGit = function()
  local cmd = "git push"
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
end

M.VcsUpdateReceive = function()
  local vcs_name = M.VcsName()
  if vcs_name == "git" then
    return M.VcsUpdateReceiveGit()
  elseif vcs_name == "svn" then
    return M.VcsUpdateReceiveSvn()
  else
    M.ShowError("VCS not supported")
  end
end

M.VcsUpdateReceiveGit = function()
  M.ShowMessage("First pull")
  local cmd = "git pull -p"
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
  M.ShowMessage("Second pull")
  cmd = "git pull -p"
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
end

M.VcsUpdateReceiveSvn = function()
  local cmd = "svn update"
  M.ShowMessage(cmd)
  vim.fn.system(cmd)
end

M.VcsReload = function()
  M.VcsUpdateReceive()
  M.VcsUpdateSend()
end

M.VcsHunkDiff = function()
  require("gitsigns").preview_hunk()
end

M.VcsHunkUndo = function()
  require("gitsigns").reset_hunk()
end

M.VcsHelp = function()
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
  -- Help - Show VCS help
  vim.keymap.set("n", "<leader>vh", function() M.VcsHelp() end, { silent = true, desc = "Show VCS help" })

  -- Add file to VCS
  vim.keymap.set("n", "<leader>va", function() M.VcsAddFile() end, { desc = "Add file to VCS" })

  -- Add all files to VCS
  vim.keymap.set("n", "<leader>vA", function() M.VcsAddFiles() end, { silent = true, desc = "Add all files to VCS" })

  -- Blame current line
  vim.keymap.set("n", "<leader>vb", function() M.VcsBlameLine() end, { silent = true, desc = "Blame current line" })

  -- Blame current file
  vim.keymap.set("n", "<leader>vB", function() M.VcsBlameFile() end, { silent = true, desc = "Blame current file" })

  -- Commit changes
  vim.keymap.set("n", "<leader>vc", function() M.VcsCommit() end, { desc = "Commit changes" })

  -- Amend commit
  vim.keymap.set("n", "<leader>vC", function() M.VcsAmend("") end, { desc = "Amend commit" })

  -- Show hunk diff
  vim.keymap.set("n", "<leader>vd", function() M.VcsHunkDiff() end, { silent = true, desc = "Show hunk diff" })

  -- Show file diff
  vim.keymap.set("n", "<leader>vD", function() M.VcsDiff("") end, { desc = "Show file diff" })

  -- Show file log
  vim.keymap.set("n", "<leader>vl", function() M.VcsLogFile() end, { silent = true, desc = "Show file log" })

  -- Show project log
  vim.keymap.set("n", "<leader>vL", function() M.VcsLogProject() end, { silent = true, desc = "Show project log" })

  -- Mark conflict as resolved
  vim.keymap.set("n", "<leader>vm", function() M.VcsResolve() end, { silent = true, desc = "Mark conflict resolved" })

  -- Next hunk
  vim.keymap.set("n", "<leader>vn", function() M.VcsNextHunk() end, { silent = true, desc = "Next hunk" })

  -- Previous hunk
  vim.keymap.set("n", "<leader>vN", function() M.VcsPrevHunk() end, { silent = true, desc = "Previous hunk" })

  -- Open current line URL
  vim.keymap.set("n", "<leader>vo", function() M.VcsOpenLineUrl() end, { silent = true, desc = "Open current line URL" })

  -- Open repository URL
  vim.keymap.set("n", "<leader>vO", function() M.VcsOpenUrl() end, { silent = true, desc = "Open repository URL" })

  -- Reload changes from remote
  vim.keymap.set("n", "<leader>vr", function() M.VcsReload() end, { silent = true, desc = "Reload changes from remote" })

  -- Show status
  vim.keymap.set("n", "<leader>vs", function() M.VcsStatus() end, { silent = true, desc = "Show VCS status" })

  -- Pull changes from remote
  vim.keymap.set("n", "<leader>vp", function() M.VcsUpdateReceive() end, { silent = true, desc = "Pull changes from remote" })

  -- Push changes to remote
  vim.keymap.set("n", "<leader>vP", function() M.VcsUpdateSend() end, { silent = true, desc = "Push changes to remote" })

  -- Show branches
  vim.keymap.set("n", "<leader>vt", function() M.VcsShowBranches() end, { desc = "Show branches" })

  -- Undo hunk
  vim.keymap.set("n", "<leader>vu", function() M.VcsHunkUndo() end, { silent = true, desc = "Undo hunk" })

  -- Undo last commit
  vim.keymap.set("n", "<leader>vU", function() M.VcsUndoLastCommit() end, { silent = true, desc = "Undo last commit" })

  -- Remove file from VCS
  vim.keymap.set("n", "<leader>vx", function() M.VcsRmFile() end, { desc = "Remove file from VCS" })

  -- Revert last commit
  vim.keymap.set("n", "<leader>vX", function() M.VcsRevertLastCommit() end, { silent = true, desc = "Revert last commit" })

  -- Stage/unstage from quickfix (only active when cursor is on a file entry)
    vim.keymap.set("n", "<leader>v+", function() M.VcsStageCurrent() end, { desc = "Stage current file" })
    vim.keymap.set("n", "<leader>v-", function() M.VcsUnstageCurrent() end, { desc = "Unstage current file" })
    vim.keymap.set("n", "<leader>v=", function() M.VcsToggleStageCurrent() end, { desc = "Toggle stage/unstage" })
    vim.keymap.set("n", "<leader>vS", function() M.VcsStageAll() end, { desc = "Stage all files" })
    vim.keymap.set("n", "<leader>vU", function() M.VcsUnstageAll() end, { desc = "Unstage all files" })

  vim.g.loaded_neovcs = 1
end

return M

