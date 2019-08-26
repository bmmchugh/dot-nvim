" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" call pathogen#infect()

let g:python2_host_prog = 'python2'
let g:python3_host_prog = 'python3'

call plug#begin('~/.local/share/nvim/plugged')
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'https://github.com/godlygeek/tabular.git'
Plug 'https://github.com/kana/vim-textobj-user.git'
Plug 'https://github.com/nelstrom/vim-textobj-rubyblock.git'
Plug 'https://github.com/altercation/vim-colors-solarized.git'
Plug 'https://github.com/majutsushi/tagbar.git'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'https://github.com/skammer/vim-css-color.git'
Plug 'https://github.com/vim-ruby/vim-ruby.git'
Plug 'https://github.com/tpope/vim-rake.git'
Plug 'https://github.com/tpope/vim-markdown.git'
Plug 'https://github.com/vim-scripts/groovy.vim--Ruley.git'
Plug 'https://github.com/oscarh/vimerl.git'
Plug 'https://github.com/tpope/vim-haml.git'
Plug 'https://github.com/benmills/vimux'
Plug 'https://github.com/Valloric/YouCompleteMe.git'
Plug 'https://github.com/vimwiki/vimwiki.git'
Plug 'https://github.com/scrooloose/nerdcommenter.git'
Plug 'https://github.com/tfnico/vim-gradle.git'
Plug 'https://github.com/tpope/vim-dispatch.git'
Plug 'https://github.com/vim-syntastic/syntastic.git'
Plug '~/.local/share/nvim/eclim'
call plug#end()

call glaive#Install()
Glaive codefmt plugin[mappings]
"Glaive codefmt google_java_executable='java -jar /home/bryce/.local/share/applications/google-java-format/current/google-java-format.jar'
Glaive codefmt google_java_executable='google-java-format'

augroup autoformat_settings
  autocmd FileType java AutoFormatBuffer google-java-format
augroup END

runtime macros/matchit.vim

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

"set t_Co=16
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
" if &t_Co > 2 || has("gui_running")
"   syntax on
"   set hlsearch
" endif
syntax enable
"set background=dark
"let g:solarized_termcolors=16
"colorscheme solarized

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  " filetype plugin on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

highlight ExtraWhitespace ctermbg=Red guibg=Red
match ExtraWhitespace /\s\+$\| \+\ze\t/
"hi link ExtraWhitespace Error
"au Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/ display

let mapleader=','

function! StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
autocmd BufWritePre *.java,*.rb,*.js,*.md :call StripTrailingWhitespaces()

nmap <Leader>s :call StripTrailingWhitespaces()<CR>

nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>a, :Tabularize /,\zs<CR>
vmap <Leader>a, :Tabularize /,\zs<CR>

inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

function! WrapParameters()
" let line = getline('.')
" let row = strlen(substitute(getline('.')[0:col('.')],',\W?',',<CR>','g'))
  .,.s/,\W?/<CR>/g
  normal! 0
endfunction

nnoremap <silent> <Leader>t :TagbarToggle<CR>
let g:EclimCompletionMethod = 'omnifunc'
set clipboard=unnamed
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

