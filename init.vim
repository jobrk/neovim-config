:set exrc
:set number
:set relativenumber
:set hidden
:set noerrorbells
:set ignorecase
:set mouse=a
:set autoindent
:set tabstop=2
:set shiftwidth=2
:set softtabstop=0
:set expandtab
:set smarttab
:set scrolloff=8
:set incsearch
:set termguicolors
:set nowrap

call plug#begin()
  Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
  Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
  Plug 'junegunn/goyo.vim'
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
  Plug 'preservim/nerdtree'
  Plug 'ryanoasis/vim-devicons'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-surround'
  Plug 'wellle/context.vim'
call plug#end()

syntax on

colorscheme catppuccin
Catppuccin frappe

nnoremap <leader>n :NERDTreeFind<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
let g:NERDTreeMinimalMenu=1

nnoremap <C-p> :Telescope find_files hidden=true<CR>
nnoremap <C-l> :Telescope live_grep hidden=true<CR>
nnoremap <C-b> :Telescope buffers<CR>
lua require('telescope').setup{  defaults = { file_ignore_patterns = { "node_modules", ".git" }} }

autocmd VimEnter,ColorScheme * hi! link CocMenuSel PMenuSel
autocmd VimEnter,ColorScheme * hi! link CocSearch Identifier

nnoremap <silent> <leader>g :Goyo<CR>
let g:goyo_linenr = 1
let g:goyo_height = '100%'
let g:goyo_width = 100

function! s:goyo_enter()
  lua require('lualine').hide()
endfunction

function! s:goyo_leave()
  lua require('lualine').hide({unhide=true})
  Catppuccin frappe
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

lua require('bufferline').setup{}
lua require('lualine').setup()

xnoremap <leader>p "_dP
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap <C-w>v <C-w>v<C-w><C-w>
nnoremap gn :bn<cr>
nnoremap gp :bp<cr>

runtime coc.vim

