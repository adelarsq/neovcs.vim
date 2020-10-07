# neovcs.vim

VCS support for Neovim

Basic support for:

- [x] [Git](https://git-scm.com)
- [x] [Subversion](https://subversion.apache.org)
- [x] [Darcs](http://darcs.net)
- [x] [Bazaar](https://bazaar.canonical.com)
- [x] [Mercurial](https://www.mercurial-scm.org)

## Config

- `<leader>v` - VCS help

- `<leader>va` - add file to VCS
- `<leader>vA` - add all files to VCS
- `<leader>vr` - remove file from VCS

- `<leader>vh` - hunk diff

- `<leader>vm` - mark conflict as resolved for current file

- `<leader>vo` - open repository on browser TODO

- `<leader>vl` - blame
- `<leader>vL` - log
- `<leader>vs` - VCS status

- `<leader>vu` - update send changes
- `<leader>vU` - send receive changes

## Commands

- `VcsName()` - get the VCS name. Can be used on status line plugins to show
    the VCS name for the current repository

## Todo

- Hightlight itens on quickfix with diferent colors

## Acknowledgments 💡

Thanks goes to these people/projects for inspiration:

- [juneedahamed/vc.vim](https://github.com/juneedahamed/vc.vim)
- [LucHermitte/lh-vim-lib](https://github.com/LucHermitte/lh-vim-lib)


