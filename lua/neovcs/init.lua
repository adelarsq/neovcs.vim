-- [nfnl] fnl/neovcs/init.fnl
if vim.g.loaded_neovcs then
  return 
else
end
local M = {}
local function starts_with(str, start)
  return (str:sub(1, #start) == start)
end
local function _2_(commit_message)
  local commit_message_lower = string.lower(commit_message)
  if starts_with(commit_message_lower, "feat") then
    return "✨"
  else
  end
  if starts_with(commit_message_lower, "fix") then
    return "🐛"
  else
  end
  if starts_with(commit_message_lower, "docs") then
    return "📚"
  else
  end
  if starts_with(commit_message_lower, "style") then
    return "💎"
  else
  end
  if starts_with(commit_message_lower, "perf") then
    return "🚀"
  else
  end
  if starts_with(commit_message_lower, "test") then
    return "🚨"
  else
  end
  if starts_with(commit_message_lower, "build") then
    return "📦"
  else
  end
  if starts_with(commit_message_lower, "ci") then
    return "⚙️"
  else
  end
  if starts_with(commit_message_lower, "chore") then
    return "♻️"
  else
  end
  if starts_with(commit_message_lower, "revert") then
    return "🗑"
  else
  end
  if starts_with(commit_message_lower, "refact") then
    return "🔨"
  else
  end
  return ""
end
M.GetEmojiForCommit = _2_
local function _14_()
  local use, imported = pcall(require, "nvim-tree.lib")
  if use then
    local entry = imported.get_node_at_cursor()
    local ___antifnl_rtn_1___ = entry.absolute_path
    return ___antifnl_rtn_1___
  else
  end
  return ""
end
M.GetNvimTreeFilePath = _14_
local function _16_()
  local use, imported = pcall(require, "oil")
  if use then
    local entry = imported.get_cursor_entry()
    if (entry.type == "file") then
      local dir = imported.get_current_dir()
      local file_name = entry.name
      local full_name = (dir .. file_name)
      local ___antifnl_rtn_1___ = full_name
      return ___antifnl_rtn_1___
    else
    end
  else
  end
  return ""
end
M.GetOilFilePath = _16_
local function _19_(arg)
  local success, notify = pcall(require, "notify")
  if success then
    return notify(arg)
  else
    return print(arg)
  end
end
M.ShowMessage = _19_
local function _21_(arg)
  local success, notify = pcall(require, "notify")
  if success then
    return notify(arg, "error")
  else
    return print(arg)
  end
end
M.ShowError = _21_
local function _23_()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".hg", (path .. ";"))
end
M.MercurialRoot = _23_
local function _24_()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".bzr", (path .. ";"))
end
M.BazaarRoot = _24_
local function _25_()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir("_darcs", (path .. ";"))
end
M.DarcsRoot = _25_
local function _26_()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".git", (path .. ";"))
end
M.GitRoot = _26_
local function _27_()
  local path = vim.fn.expand("%:p:h")
  return vim.fn.finddir(".svn", (path .. ";"))
end
M.SvnRoot = _27_
local function _28_()
  if (#M.GitRoot() > 0) then
    return "git"
  elseif (#M.SvnRoot() > 0) then
    return "svn"
  elseif (#M.DarcsRoot() > 0) then
    return "darcs"
  elseif (#M.BazaarRoot() > 0) then
    return "bazaar"
  elseif (#M.MercurialRoot() > 0) then
    return "mercurial"
  else
    return ""
  end
end
M.VcsName = _28_
local function _30_()
  local cwd_root = vim.fn.getcwd()
  local git_root = M.GitRoot()
  if (#git_root > 0) then
    local ___antifnl_rtn_1___ = {"git", cwd_root}
    return ___antifnl_rtn_1___
  else
  end
  local svn_root = M.SvnRoot()
  if (#svn_root > 0) then
    local ___antifnl_rtn_1___ = {"svn", cwd_root}
    return ___antifnl_rtn_1___
  else
  end
  local darcs_root = M.DarcsRoot()
  if (#darcs_root > 0) then
    local ___antifnl_rtn_1___ = {"darcs", cwd_root}
    return ___antifnl_rtn_1___
  else
  end
  local bazaar_root = M.BazaarRoot()
  if (#bazaar_root > 0) then
    local ___antifnl_rtn_1___ = {"bazaar", cwd_root}
    return ___antifnl_rtn_1___
  else
  end
  local mercurial_root = M.MercurialRoot()
  if (#mercurial_root > 0) then
    local ___antifnl_rtn_1___ = {"mercurial", cwd_root}
    return ___antifnl_rtn_1___
  else
  end
  return {}
end
M.VcsNamePath = _30_
local function _36_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsGitBranchName()
  else
    M.ShowError()
    return ""
  end
end
M.VcsBranchName = _36_
local function _38_()
  local branch = vim.fn.systemlist("git branch")[1]
  local branch_split = vim.fn.split(branch, " ")[2]
  return branch_split
end
M.VcsGitBranchName = _38_
local function _39_(...)
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    if (select(2, ...) == "") then
      M.ShowError("Please add a commit message")
      return ""
    else
    end
    local commit_message = (__fnl_global__Get_2demoji_2dfor_2dcommit(select(2, ...)) .. " " .. select(2, ...))
    return vim.fn.system(("git commit -m \"" .. commit_message .. "\""))
  elseif (vcs_name == "svn") then
    if (select(2, ...) == "") then
      M.ShowError("Please add a commit message")
      return ""
    else
    end
    if (select(3, ...) == "") then
      M.ShowError("Please add a changelist name")
      return ""
    else
    end
    return vim.fn.system(("svn commit --changelist " .. select(3, ...) .. " -m \"" .. select(2, ...) .. "\""))
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsCommit = _39_
local function _44_(...)
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    if (select(1, ...) == "") then
      M.ShowError("Please add a commit message")
      return ""
    else
    end
    local commit_message = (__fnl_global__Get_2demoji_2dfor_2dcommit(select(1, ...)) .. " " .. select(1, ...))
    return vim.fn.system(("git commit --amend -m \"" .. commit_message .. "\""))
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsAmend = _44_
local function _47_(...)
  local vcs_name = M.VcsName()
  if (vcs_name == "svn") then
    return vim.fn.system(("svn diff -r " .. select(1, ...)))
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsDiff = _47_
local function _49_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsOpenLineUrlGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsOpenLineUrl = _49_
local function _51_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return require("gitsigns").next_hunk({navigation_message = false})
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsNextHunk = _51_
local function _53_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return require("gitsigns").prev_hunk({navigation_message = false})
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsPrevHunk = _53_
local function _55_()
  local cmd = "git config --get remote.origin.url"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  local split = vim.split(result, "\n")
  local branch = M.VcsGitBranchName()
  local relative_file_path = vim.fn.expand("%:t")
  local line = vim.fn.line(".")
  local url = (split[1] .. "/blob/" .. branch .. "/" .. relative_file_path .. "#L" .. line)
  return vim.ui.open(url)
end
M.VcsOpenLineUrlGit = _55_
local function _56_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsOpenUrlGit()
  elseif (vcs_name == "svn") then
    return M.VcsOpenUrlSvn()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsOpenUrl = _56_
local function _58_()
  local cmd = "git config --get remote.origin.url"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  local split = vim.split(result, "\n")
  local url = split[1]
  return vim.ui.open(url)
end
M.VcsOpenUrlGit = _58_
local function _59_()
  local cmd = "svn info --show-item repos-root-url"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  local split = vim.split(result, "\n")
  local url = split[1]
  return vim.ui.open(url)
end
M.VcsOpenUrlSvn = _59_
local function _60_()
  local full_name = ""
  local filetype = vim.bo.filetype
  if (filetype == "oil") then
    full_name = get_oil_file_path()
  elseif (filetype == "NvimTree") then
    full_name = get_nvim_tree_file_path()
  else
    full_name = vim.fn.expand("%:p")
  end
  local cmd = ""
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    cmd = ("git add " .. full_name)
  elseif (vcs_name == "svn") then
    if (arg[0] == 0) then
      cmd = ("svn add " .. full_name)
    else
      cmd = ("svn changelist " .. arg[1] .. " " .. full_name)
    end
  else
    M.ShowMessage("Is this file in a repository?")
    return 
  end
  vim.fn.system(cmd)
  return M.ShowMessage(cmd)
end
M.VcsAddFile = _60_
local function _64_(...)
  local cmd = ""
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    cmd = "git add *"
  elseif (vcs_name == "svn") then
    if (select(1, ...) == 0) then
      cmd = "svn add *"
    else
      cmd = ("svn changelist " .. select(1, ...) .. " *")
    end
  else
    M.ShowMessage("Is this file in a repository?")
    return 
  end
  vim.fn.system(cmd)
  return M.ShowMessage(cmd)
end
M.VcsAddFiles = _64_
local function _67_()
  local cmd = ""
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    cmd = "git branch"
  else
    M.ShowMessage("Is this file in a repository?")
    return 
  end
  vim.fn.system(cmd)
  return M.ShowMessage(cmd)
end
M.VcsShowBranches = _67_
local function _69_(...)
  local filepath = vim.fn.expand("%:p")
  local cmd = ""
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    cmd = ("git rm " .. filepath)
  elseif (vcs_name == "svn") then
    if (select(1, ...) == 0) then
      cmd = ("svn rm " .. filepath)
    else
      cmd = ("svn changelist " .. select(1, ...) .. " " .. filepath)
    end
  else
    M.ShowMessage("Is this file in a repository?")
    return 
  end
  vim.fn.system(cmd)
  return M.ShowMessage(cmd)
end
M.VcsRmFile = _69_
local function _72_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsBlameLineGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsBlameLine = _72_
local function _74_()
  local r = table.concat(vim.fn.systemlist(("git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " blame -L <line1>,<line2> " .. vim.fn.expand("%:t"))), "\n")
  return M.ShowMessage(r)
end
M.VcsBlameLineGit = _74_
local function _75_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsBlameFileGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsBlameFile = _75_
local function _77_()
  local cmd = "git blame "
  M.ShowMessage(cmd)
  return vim.fn.system(cmd)
end
M.VcsBlameFileGit = _77_
local function _78_()
  local vcs_name = M.VcsName()
  if (vcs_name == "svn") then
    return M.VcsResolveSvn()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsResolve = _78_
local function _80_()
  local filepath = vim.fn.expand("%:p")
  local cmd = ("svn resolve " .. filepath)
  M.ShowMessage(cmd)
  return vim.fn.system(cmd)
end
M.VcsResolveSvn = _80_
local function _81_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsLogFileGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsLogFile = _81_
local function _83_()
  local file_path = vim.fn.expand("%:p")
  local cmd = ("git log --pretty=oneline -- filename " .. file_path)
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    local dic = {filename = "", text = item}
    table.insert(list, dic)
  end
  vim.fn.setqflist(list)
  return vim.cmd("bel copen 10")
end
M.VcsLogFileGit = _83_
local function _84_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsLogProjectGit()
  elseif (vcs_name == "svn") then
    return M.VcsLogProjectSvn()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsLogProject = _84_
local function _86_()
  local cmd = "git log --pretty=oneline"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    local dic = {filename = "", text = item}
    table.insert(list, dic)
  end
  vim.fn.setqflist(list)
  return vim.cmd("bel copen 10")
end
M.VcsLogProjectGit = _86_
local function _87_()
  local cmd = "svn log"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    local dic = {filename = "", text = item}
    table.insert(list, dic)
  end
  vim.fn.setqflist(list)
  return vim.cmd("bel copen 10")
end
M.VcsLogProjectSvn = _87_
local function _88_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsLogFileGraphGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsLogFileGraph = _88_
local function _90_()
  local file_path = vim.fn.expand("%:p")
  local cmd = ("git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -- filename " .. file_path)
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    local dic = {filename = "", text = item}
    table.insert(list, dic)
  end
  vim.fn.setqflist(list)
  return vim.cmd("bel copen 10")
end
M.VcsLogFileGraphGit = _90_
local function _91_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsLogProjectGitGraph()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsLogProjectGraph = _91_
local function _93_()
  local cmd = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  M.ShowMessage(cmd)
  local result = vim.fn.system(cmd)
  result = vim.split(result, "\n")
  local list = {}
  for _, item in ipairs(result) do
    local dic = {filename = "", text = item}
    table.insert(list, dic)
  end
  vim.fn.setqflist(list)
  return vim.cmd("bel copen 10")
end
M.VcsLogProjectGitGraph = _93_
local function _94_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsUndoLastCommitGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsUndoLastCommit = _94_
local function _96_()
  local cmd = "git reset --soft HEAD~1"
  M.ShowMessage(cmd)
  return vim.fn.system(cmd)
end
M.VcsUndoLastCommitGit = _96_
local function _97_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsRevertLastCommitGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsRevertLastCommit = _97_
local function _99_()
  local cmd = "git revert HEAD"
  M.ShowMessage(cmd)
  return vim.fn.system(cmd)
end
M.VcsRevertLastCommitGit = _99_
local function _100_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsStatusGit()
  elseif (vcs_name == "svn") then
    return M.VcsStatusSvn()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsStatus = _100_
local function _102_()
  local cmd = "git status --porcelain"
  M.ShowMessage(cmd)
  local flist = vim.fn.system(cmd)
  flist = vim.split(flist, "\n")
  local list = {}
  for _, f1 in ipairs(flist) do
    local f2 = vim.trim(f1)
    local glist = vim.split(f2, "\n")
    local a = glist[1]
    local b = glist[2]
    local dic = {filename = b, text = a}
    table.insert(list, dic)
  end
  if (#list == 0) then
    M.ShowMessage("no changes")
    return ""
  else
  end
  vim.fn.setqflist(list)
  return vim.cmd("bel copen 10")
end
M.VcsStatusGit = _102_
local function _104_()
  local cmd = "svn status | awk '{print $1\" \"$2}'"
  M.ShowMessage(cmd)
  local flist = vim.fn.system(cmd)
  flist = vim.split(flist, "\n")
  local list = {}
  for _, f in ipairs(flist) do
    local glist = vim.split(f, " ")
    if (#glist == 2) then
      local a = glist[1]
      local b = glist[2]
      local dic = {filename = b, text = a}
      table.insert(list, dic)
    else
    end
  end
  return vim.fn.setqflist(list)
end
M.VcsStatusSvn = _104_
local function _106_()
  local filename = vim.api.nvim_buf_get_name(0)
  local git_command = ("git ls-files --error-unmatch " .. vim.fn.shellescape(filename))
  local git_output = io.popen(git_command)
  local file_exists = git_output:read("*a")
  git_output:close()
  local git_status_symbol = "?"
  if (file_exists ~= "") then
    local git_diff_command = ("git diff --name-only " .. vim.fn.shellescape(filename))
    local git_diff_output = io.popen(git_diff_command)
    local is_modified = git_diff_output:read("*a")
    git_diff_output:close()
    if (is_modified ~= "") then
      git_status_symbol = "~"
    else
      local git_status_command = ("git status --porcelain --untracked-files=no " .. vim.fn.shellescape(filename))
      local git_status_output = io.popen(git_status_command)
      local git_status = git_status_output:read("*a")
      git_status_output:close()
      if git_status:match("^A") then
        git_status_symbol = "+"
      elseif git_status:match("^D") then
        git_status_symbol = "-"
      else
      end
    end
  else
  end
  vim.api.nvim_command(("echo '" .. git_status_symbol .. "'"))
  return git_status_symbol
end
M.GetLocalFileChangesForGit = _106_
local function _110_()
  local vcs_name_path = M.VcsNamePath()
  if vim.tbl_isempty(vcs_name_path) then
    return ""
  else
  end
  local vcs_name = vcs_name_path[1]
  local root_dir = vcs_name_path[2]
  local cd_root_dir = ("cd " .. root_dir)
  local hunkline = __fnl_global__Get_2dlocal_2dfile_2dchanges_2dfor_2dgit()
  local mark_conflits = "\226\137\160"
  local light_line_vcs_conflits = ""
  if (vcs_name == "git") then
    light_line_vcs_conflits = (mark_conflits .. M.VcsGitConflictMarker())
  else
    light_line_vcs_conflits = (mark_conflits .. "0")
  end
  local mark_local = "\226\134\145"
  local light_line_vcs_status_local = ""
  if (vcs_name == "git") then
    local status_update_list = vim.fn.systemlist("git for-each-ref --format=\"%(HEAD) %(refname:short) %(push:track)\" refs/heads | grep -o \"[0-9]\\+\"")
    if (#status_update_list > 0) then
      light_line_vcs_status_local = (mark_local .. status_update_list[1])
    else
      light_line_vcs_status_local = (mark_local .. "0")
    end
  elseif (vcs_name == "svn") then
    local cmds = (cd_root_dir .. "; svn status")
    local status_update_list_local = vim.fn.systemlist(cmds)
    if (#status_update_list_local > 0) then
      light_line_vcs_status_local = (mark_local .. #status_update_list_local)
    else
      light_line_vcs_status_local = (mark_local .. "0")
    end
  else
    light_line_vcs_status_local = (mark_local .. "0")
  end
  local mark_behind = "\226\134\147"
  local light_line_vcs_status_behind = ""
  if (vcs_name == "git") then
    light_line_vcs_status_behind = (mark_behind .. "?")
  elseif (vcs_name == "svn") then
    local cmds = (cd_root_dir .. "; svn status -u | grep \"        \\*\"")
    local status_behind = vim.fn.systemlist(cmds)
    if (#status_behind > 0) then
      light_line_vcs_status_behind = (mark_behind .. #status_behind)
    else
      light_line_vcs_status_behind = (mark_behind .. "0")
    end
  else
    light_line_vcs_status_behind = (mark_behind .. "0")
  end
  local mark_repository_conflits = "\226\137\160"
  local light_line_vcs_repository_conflits = ""
  if (vcs_name == "git") then
    local cmds = (cd_root_dir .. "; git diff --name-only --diff-filter=U ")
    local status_conflicts_repository = vim.fn.systemlist(cmds)
    light_line_vcs_repository_conflits = (mark_repository_conflits .. #status_conflicts_repository)
  elseif (vcs_name == "svn") then
    local cmds = (cd_root_dir .. "; svn status|grep \"Text conflicts\"|sed ''s/[^0-9]*//g'' ")
    local status_conflicts_repository = vim.fn.systemlist(cmds)
    if (#status_conflicts_repository > 0) then
      light_line_vcs_repository_conflits = (mark_repository_conflits .. status_conflicts_repository[1])
    else
      light_line_vcs_repository_conflits = (mark_repository_conflits .. "0")
    end
  else
    light_line_vcs_repository_conflits = (mark_repository_conflits .. "0")
  end
  local mark_vcs = "\238\130\160"
  local vcs_name_branch = ""
  if not vim.b.vcs_name_branch then
    if (vcs_name == "git") then
      vcs_name_branch = (vcs_name .. " " .. M.VcsGitBranchName())
    elseif (vcs_name == "svn") then
      local cmds = (cd_root_dir .. "; svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$' ")
      vcs_name_branch = (vcs_name .. " " .. vim.fn.systemlist(cmds)[1])
    else
    end
    vim.b.vcs_name_branch = vcs_name_branch
  else
    vcs_name_branch = vim.b.vcs_name_branch
  end
  return (mark_vcs .. " " .. hunkline .. light_line_vcs_conflits .. " " .. light_line_vcs_status_local .. light_line_vcs_status_behind .. light_line_vcs_repository_conflits .. " " .. vcs_name_branch)
end
M.VcsStatusLine = _110_
local function _122_()
  local annotation = "\\%([0-9A-Za-z_.:]+\\)\\?"
  local pattern = ("^\\%(\\%(<\\{7} " .. annotation .. "\\)\\|\\%(=\\{7\\}\\)\\|\\%(>\\{7\\} " .. annotation .. "\\)\\)$")
  return vim.fn.search(pattern, "nw")
end
M.VcsGitConflictMarker = _122_
local function _123_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsUpdateSendGit()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsUpdateSend = _123_
local function _125_()
  local cmd = "git push"
  M.ShowMessage(cmd)
  return vim.fn.system(cmd)
end
M.VcsUpdateSendGit = _125_
local function _126_()
  local vcs_name = M.VcsName()
  if (vcs_name == "git") then
    return M.VcsUpdateReceiveGit()
  elseif (vcs_name == "svn") then
    return M.VcsUpdateReceiveSvn()
  else
    return M.ShowError("VCS not supported")
  end
end
M.VcsUpdateReceive = _126_
local function _128_()
  M.ShowMessage("First pull")
  do
    local cmd = "git pull -p"
    M.ShowMessage(cmd)
    vim.fn.system(cmd)
  end
  M.ShowMessage("Second pull")
  local cmd = "git pull -p"
  M.ShowMessage(cmd)
  return vim.fn.system(cmd)
end
M.VcsUpdateReceiveGit = _128_
local function _129_()
  local cmd = "svn update"
  M.ShowMessage(cmd)
  return vim.fn.system(cmd)
end
M.VcsUpdateReceiveSvn = _129_
local function _130_()
  M.VcsUpdateReceive()
  return M.VcsUpdateSend()
end
M.VcsReload = _130_
local function _131_()
  return require("gitsigns").preview_hunk()
end
M.VcsHunkDiff = _131_
local function _132_()
  return require("gitsigns").reset_hunk()
end
M.VcsHunkUndo = _132_
local function _133_()
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
  return print("- <leader>vX - revert last commit")
end
M.VcsHelp = _133_
M.setup = function()
  vim.api.nvim_set_keymap("n", "<leader>v", ":lua require('neovcs').VcsHelp()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>va", ":lua require('neovcs').VcsAddFile(\"\")<left><left>", {})
  vim.api.nvim_set_keymap("n", "<leader>vA", ":lua require('neovcs').VcsAddFiles(\"\",\"\")<left><left><left><left><left>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vb", ":lua require('neovcs').VcsBlameLine()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vB", ":lua require('neovcs').VcsBlameFile()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vc", ":lua require('neovcs').VcsCommit(\"\",\"\")<left><left><left><left><left>", {})
  vim.api.nvim_set_keymap("n", "<leader>vC", ":lua require('neovcs').VcsAmend(\"\")<left><left><left>", {})
  vim.api.nvim_set_keymap("n", "<leader>vd", ":lua require('neovcs').VcsHunkDiff()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vD", ":lua require('neovcs').VcsDiff(\"\")<left><left>", {})
  vim.api.nvim_set_keymap("n", "<leader>vl", ":lua require('neovcs').VcsLogFile()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vL", ":lua require('neovcs').VcsLogProject()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vm", ":lua require('neovcs').VcsResolve()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vn", ":lua require('neovcs').VcsNextHunk()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vN", ":lua require('neovcs').VcsPrevHunk()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vo", ":lua require('neovcs').VcsOpenLineUrl()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vO", ":lua require('neovcs').VcsOpenUrl()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vr", ":lua require('neovcs').VcsReload()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vs", ":lua require('neovcs').VcsStatus()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vp", ":lua require('neovcs').VcsUpdateReceive()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vP", ":lua require('neovcs').VcsUpdateSend()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vt", ":lua require('neovcs').VcsShowBranchs()<CR>", {})
  vim.api.nvim_set_keymap("n", "<leader>vu", ":lua require('neovcs').VcsHunkUndo()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vU", ":lua require('neovcs').VcsUndoLastCommit()<CR>", {silent = true})
  vim.api.nvim_set_keymap("n", "<leader>vx", ":lua require('neovcs').VcsRmFile(\"\")<left><left>", {})
  vim.api.nvim_set_keymap("n", "<leader>vX", ":lua require('neovcs').VcsRevertLastCommit()<CR>", {silent = true})
  vim.g.loaded_neovcs = 1
  return nil
end
return M
