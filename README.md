# neovcs.vim 🌱

VCS support for Neovim

Basic support for:

- [x] [Git](https://git-scm.com)
- [x] [Subversion](https://subversion.apache.org)
- [x] [Darcs](http://darcs.net) - just VCS name for now
- [x] [Bazaar](https://bazaar.canonical.com) - just VCS name for now
- [x] [Mercurial](https://www.mercurial-scm.org) - just VCS name for now

## Mappings 🗺

- `<leader>v` - help
- `<leader>va` - add file. Parameters:
    - `1` Changelist name (just for SVN at moment)
- `<leader>vA` - add all files
- `<leader>vb` - blame line
- `<leader>vB` - blame file
- `<leader>vc` - commit. Parameters:
    - `1` Message 
    - `2` Changelist name (just for SVN at moment)
- `<leader>vC` - commit with amend. Parameters:
    - `1` Message 
- `<leader>vd` - hunk diff
- `<leader>vD` - file diff. Parameters:
    - `1` Revision (just for SVN at moment)
- `<leader>vo` - open URL for current line
- `<leader>vO` - open URL for repository
- `<leader>vm` - mark conflict as resolved for current file
- `<leader>vn` - go to next hunk
- `<leader>vN` - go to previous hunk
- `<leader>vl` - log
- `<leader>vr` - reload changes (get/send changes from/to remote)
- `<leader>vp` - get changes from remote
- `<leader>vP` - send changes to remote
- `<leader>vs` - status
- `<leader>vt` - show branchs
- `<leader>vu` - hunk undo
- `<leader>vU` - undo last commit
- `<leader>vx` - remove file
- `<leader>vX` - revert last commit

## Commands 🕹

- `VcsName()` - get the VCS name. Can be used on status line plugins to show
    the VCS name for the current repository
- `VcsStatusLine()` - get the repository status to use on status lines
- `VcsBranchName()` - get the name for the current branch

# Supported Plugins 🧩

- [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify)
- [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua). Mappings:
  - `<leader>va` - add file or directory under cursor

## Features

### Emoji Support for Commits

Just add a prefix based on the table:

| Commit Type | Title                    | Description                                                                                                 | Emoji | Release                        | Include in changelog |
|:-----------:|--------------------------|-------------------------------------------------------------------------------------------------------------|:-----:|--------------------------------|:--------------------:|
|   `feat`    | Features                 | A new feature                                                                                               |   ✨   | `minor`                        |        `wip`        |
|    `fix`    | Bug Fixes                | A bug Fix                                                                                                   |  🐛   | `patch`                        |        `wip`        |
|   `docs`    | Documentation            | Documentation only changes                                                                                  |  📚   | `patch` if `scope` is `readme` |        `wip`        |
|   `style`   | Styles                   | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)      |  💎   | -                              |        `wip`        |
| `refactor`  | Code Refactoring         | A code change that neither fixes a bug nor adds a feature                                                   |  📦   | -                              |        `wip`        |
|   `perf`    | Performance Improvements | A code change that improves performance                                                                     |  🚀   | `patch`                        |        `wip`        |
|   `test`    | Tests                    | Adding missing tests or correcting existing tests                                                           |  🚨   | -                              |        `wip`        |
|   `build`   | Builds                   | Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)         |  🛠   | `patch`                        |        `wip`        |
|    `ci`     | Continuous Integrations  | Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs) |  ⚙️   | -                              |        `wip`        |
|   `chore`   | Chores                   | Other changes that don't modify src or test files                                                           |  ♻️   | -                              |        `wip`        |
|  `revert`   | Reverts                  | Reverts a previous commit                                                                                   |  🗑   | -                              |        `wip`        |

## Todo 🚧

- [ ] Remove Gitsigns dependency [wip]
- [ ] Root folder based on the current file [wip]
- [ ] Convert all code to Lua
- [ ] Telescope integration
- [x] Show commit for current line. Based on [1](https://www.reddit.com/r/vim/comments/i50pce/how_to_show_commit_that_introduced_current_line/).
- [ ] Hightlight itens on quickfix with diferent colors
- [ ] Support all commands on:
  - [ ] [Mercurial](https://www.mercurial-scm.org)
  - [ ] [Darcs](http://darcs.net)
  - [ ] [Bazaar](https://bazaar.canonical.com)
- [ ] On repository for modified files show the lines status, like `+3-2~1M`

## Acknowledgments 💡

Thanks goes to these people/projects for inspiration:

- [juneedahamed/vc.vim](https://github.com/juneedahamed/vc.vim)
- [LucHermitte/lh-vim-lib](https://github.com/LucHermitte/lh-vim-lib)
- [Emoji Log VSCode plugin](https://marketplace.visualstudio.com/items?itemName=ahmadawais.emoji-log-vscode)
- [conventional-changelog-metahub](https://github.com/pvdlg/conventional-changelog-metahub)

## Self-plug 🔌

If you liked this plugin, also check out:

- [vim-emoji-icon-theme](https://github.com/adelarsq/vim-emoji-icon-theme) - Emoji/Unicode Icons Theme for Vim and Neovim with support for 40+ plugins and 300+ filetypes
- [neoline.vim](https://github.com/adelarsq/neoline.vim) - Status Line for Neovim focused on beauty and performance

