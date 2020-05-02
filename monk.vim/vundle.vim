" Automatically setup Vundle on first run
if !isdirectory(expand("~/.vim/bundle"))
    call system("git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim")
endif

set nocompatible
set showcmd

syntax on
filetype off

" source /usr/share/vim/google/google.vim

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

set maxmempattern=10000

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'bling/vim-airline'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'fatih/vim-go'
Plugin 'google/vim-jsonnet'
Plugin 'majutsushi/tagbar'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-fugitive'
Plugin 'google/vim-maktaba'
Plugin 'bazelbuild/vim-bazel'
Plugin 'easymotion/vim-easymotion'
Plugin 'qpkorr/vim-bufkill'
Plugin 'davidhalter/jedi-vim'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'

" Required for LSP
Plugin 'prabirshrestha/async.vim'
Plugin 'prabirshrestha/vim-lsp'
Bundle 'chase/vim-ansible-yaml'

Plugin 'google/vim-codefmt'
call vundle#end()


filetype plugin indent on
" Config
let mapleader = "\<space>"
filetype on

set foldmethod=syntax
"color slate
" set ts=4 sts=4 sw=4 expandtab
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=4 sts=4 sw=4 noexpandtab
autocmd Filetype makefile setlocal sts=4 ts=8  sw=4 noexpandtab
autocmd Filetype jsonnet setlocal sts=4 ts=4  sw=4 expandtab
autocmd Filetype sh setlocal sts=2 ts=2  sw=2 expandtab
autocmd Filetype yaml setlocal sts=2 ts=2  sw=2 expandtab
autocmd Filetype python setlocal sts=2 ts=2  sw=2 expandtab
autocmd Filetype cpp setlocal sts=4 ts=4  sw=2 noexpandtab
autocmd Filetype bazel setlocal ts=4 sts=4 sw=4 expandtab
autocmd Filetype lua setlocal sts=2 ts=2  sw=2 expandtab

" autocmd Filetype yml setlocal sts=2 ts=2  sw=2 expandtab
set background=dark
"set colorcolumn=81,82,83

set hlsearch

set wildmode=longest,list,full
set wildmenu
" set list

" airline
let g:airline#extensions#tabline#enabled = 1
set laststatus=2

" CtrlP
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']

" Use deoplete.
" let g:deoplete#enable_at_startup = 1

" vim-go
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

" codefmt
" call glaive#Install()
" Glaive codefmt plugin[mappings]
" autocmd BufWritePost *.cc FormatCode
" autocmd BufWritePost *.h FormatCode

" my map
if has('nvim')
  nnoremap <leader>t    :terminal<CR>
  tnoremap <Esc>        <C-\><C-n>
endif

set hidden
nnoremap <leader>ba   :badd<space>
nnoremap <leader>bd   :ls<CR>:bdelete<space>
nnoremap <leader>bl   :ls<CR>:buffer<space>
nnoremap <leader>bn   :bnext<CR>
nnoremap <leader>bp   :bprevious<CR>

"nnoremap <leader>tp   :tabprevious<CR>
"nnoremap <leader>tn   :tabnext<CR>
"nnoremap <leader>tl   :tabs<CR>
"nnoremap <leader>tm   :tabm<space>
"nnoremap <leader>tt   :tabnew<space>

nnoremap <leader>q    :BD<CR>
nnoremap <leader>x    :x<CR>
nnoremap <leader>s    :s<CR>
nnoremap <leader>e    :e <C-R>=expand('%:p:h') . '/'<CR>

nnoremap <leader>wt   :TagbarToggle<CR>
nnoremap <leader>wn   :NERDTreeToggle<CR>
nnoremap <leader>wp   :CtrlP<CR>

nnoremap <leader>ss   <C-W>
nnoremap <leader>sh   :split<CR>
nnoremap <leader>sv   :vsplit<CR>
nnoremap <leader>s]   :vsplit<CR> <C-]>
set splitbelow
set splitright

" --- EasyMotion
" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1
" <leader>f{char} to move to {char}
map  <leader>f <Plug>(easymotion-bd-f)
nmap <leader>f <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <leader>j <Plug>(easymotion-j)
map <leader>k <Plug>(easymotion-k)
map <leader>L <Plug>(easymotion-bd-jk)
nmap <leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <leader>w <Plug>(easymotion-bd-w)
nmap <leader>w <Plug>(easymotion-overwin-w)
" --- End EasyMotion

nnoremap <leader>ag   :Ag ''<left>

" set mouse=a
if !has('nvim')
  " set ttymouse=xterm2
endif

set foldlevelstart=20
autocmd Syntax c,cpp,vim,xml,html,xhtml setlocal foldmethod=indent

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto AutoFormatBuffer clang-format
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType jslayout AutoFormatBuffer jslfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType python AutoFormatBuffer pyformat
  autocmd FileType markdown AutoFormatBuffer mdformat
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab foldmethod=indent
augroup END

augroup go_custom
  autocmd FileType go set tabstop=2
  autocmd FileType go set list
  autocmd FileType go set listchars=tab:»\ ,trail:°,extends:>,precedes:<,nbsp:+
augroup END

augroup cpp_custom
  autocmd FileType cpp set tabstop=2
  autocmd FileType cpp set softtabstop=0
  autocmd FileType cpp set expandtab
  autocmd FileType cpp set list
  autocmd FileType cpp set listchars=tab:»\ ,trail:°,extends:>,precedes:<,nbsp:+
augroup END

function RunGazel(dir)
  echom a:dir
endfunction

set number
set wildmenu
set wildmode=list:longest,full
set ignorecase
set smartcase
set visualbell

set exrc
set secure
