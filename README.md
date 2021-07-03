# neovcs.vim 🌱

VCS support for Neovim

Basic support for:

- [x] [Git](https://git-scm.com)
- [x] [Subversion](https://subversion.apache.org)
- [x] [Darcs](http://darcs.net)
- [x] [Bazaar](https://bazaar.canonical.com)
- [x] [Mercurial](https://www.mercurial-scm.org)

## Mappings 🗺

- `<leader>v` - help
- `<leader>va` - add file
- `<leader>vA` - add all files
- `<leader>vb` - blame line
- `<leader>vB` - blame file
- `<leader>vc` - commit
- `<leader>vd` - hunk diff
- `<leader>vD` - file diff
- `<leader>vo` - open URL for current line
- `<leader>vO` - open URL for repository
- `<leader>vm` - mark conflict as resolved for current file
- `<leader>vL` - log
- `<leader>vr` - undo last commit
- `<leader>vR` - revert last commit
- `<leader>vs` - status
- `<leader>vS` - echo status line
- `<leader>vt` - show branchs
- `<leader>vu` - receive changes from remote
- `<leader>vU` - send changes to remote
- `<leader>vx` - hunk undo
- `<leader>vX` - remove file

## Commands 🕹

- `VcsName()` - get the VCS name. Can be used on status line plugins to show
    the VCS name for the current repository
- `VcsStatusLine()` - get the repository status to use on status lines
- `VcsBranchName()` - get the name for the current branch

## Todo 🚧

- [ ] Convert all code to Lua
- [ ] Telescope integration
- [ ] Hightlight itens on quickfix with diferent colors
- [ ] Show commit for current line. Based on [1](https://www.reddit.com/r/vim/comments/i50pce/how_to_show_commit_that_introduced_current_line/).

## Acknowledgments 💡

Thanks goes to these people/projects for inspiration:

- [juneedahamed/vc.vim](https://github.com/juneedahamed/vc.vim)
- [LucHermitte/lh-vim-lib](https://github.com/LucHermitte/lh-vim-lib)

## Self-plug 🔌

If you liked this plugin, also check out:

- [vim-emoji-icon-theme](https://github.com/adelarsq/vim-emoji-icon-theme) - Emoji/Unicode Icons Theme for Vim and Neovim with support for 40+ plugins and 300+ filetypes
- [neoline.vim](https://github.com/adelarsq/neoline.vim) - Status Line for Neovim focused on beauty and performance

