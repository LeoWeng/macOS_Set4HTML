#!/bin/bash
###################################################
#       macOS Dev toolbox script
#
#       Author: Sheng-Hung Weng
#       E-mail: goodog008@gmail.com
#       Reversion: v20190607.1.0.0
#
###################################################
exists()
{
        command -v "$1" >/dev/null 2>&1
}

settingPOW2INIT()
{
	touch ~/.bash_profile
	cat << EOF >> ~/.bash_profile
POWERLINE_PATH=$1
POWERLINE_SCRIPT=\$POWERLINE_PATH/powerline/bindings/bash/powerline.sh
if [ -f \$POWERLINE_SCRIPT ]; then
	\$POWERLINE_PATH/scripts/powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1
	source \$POWERLINE_SCRIPT
fi
EOF
	mkdir -p ~/.config/powerline
	cp -r $1/powerline/config_files ~/.config/powerline
}

install_powerlineFont()
{
	POWERLINE=`pip3 show powerline-status | grep Location | awk -F:\  '{print$2}'`
	if [ ! -d ${POWERLINE}/scripts ]; then
        	pushd ~/
        	        git clone https://github.com/powerline/fonts.git
        	        pushd fonts
        	                ./install.sh
        	        popd
        	        rm -rf fonts
        	popd
		pushd ${POWERLINE}
			mkdir scripts
			cp ../../../bin/* ./scripts/
		popd
		settingPOW2INIT ${POWERLINE}
	else
		echo "Font have been ready for use!"
	fi
}

install_powerline()
{
	if exists pip3; then
		echo "pip3 ready"
	else
		sudo easy_install pip3
	fi
	POWERLINE=`pip3 show powerline-status | grep Location | awk -F:\  '{print$2}'`
	if [ -z "$POWERLINE" ]; then
		pip3 install --user git+git://github.com/powerline/powerline
	else
		echo "powerline ready"
	fi
	install_powerlineFont	
}

install_cscope()
{
	if exists cscope; then
		echo "cscope ready"
	else
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
		brew install cscope
	fi
}

build_vimrc()
{
	if exists ctags; then
		echo "ctags ready"
	else
		brew install ctags
	fi
	POWERLINE=`pip3 show powerline-status | grep Location | awk -F:\  '{print$2}'`
	rm -rf ~/.vimrc ~/.vim
	mkdir -p ~/.vim/autoload ~/.vim/bundle && \
		curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	read -p "請輸入英文全名： " -r NAME
	
	cat << EOF > ~/.vimrc
"""""""""""""""""""""""""""""""""
" VIM Setting Doc
"
" Author: Sheng-Hung Weng
" E-mail: goodog008@gmail.com
"""""""""""""""""""""""""""""""""
syntax enable
syntax on

" 檔案偵測開啟
filetype on

" 根據開啟的檔案附加指定plugin
filetype plugin on

" 根據不同语言的智慧縮排
filetype indent on

" Powerline plugin
set rtp+=$POWERLINE/powerline/bindings/vim
set laststatus=2
set t_Co=256
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

" pathogen plugin <套件管理器>
execute pathogen#infect()

" 管理vim的plugin Vim-Plug

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source \$MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'scrooloose/nerdtree'
Plug 'chazy/cscope_maps'
Plug 'Rip-Rip/clang_complete'
Plug 'vim-scripts/STL-Syntax'
Plug 'majutsushi/tagbar'
call plug#end()

filetype plugin indent on

" Colors-solarized plugin
" ------------------------------
if has('gui_running')
        set background=light
else
        set background=dark
endif

let g:solarized_termcolors=256
let g:solarized_termtrans=1
let g:solarized_contrast="high"
let g:solarized_visibility="high"
colorscheme solarized
" ------------------------------

" NERDTree plugin
" ------------------------------
nnoremap <silent> <F5> :NERDTree<CR>
" ------------------------------

" Cscope plugin
" ------------------------------
" tag creat from ./ {only C langurage}
map <Leader>r1 :!ctags -R -h ".h.c"<CR>
map <Leader>r2 :!find . -name "*.h" -o -name "*.c" > cscope.files<CR>
map <Leader>r3 :!cscope -Rbq cscope.files<CR>
"搜尋快捷鍵
"<ctrl-]> goto defined
"<ctrl-t> go back
"
"cscope_maps.vim
"Ctrl+\\ s "s表Symbol，列出所有參考到游標所在字串的地方，包含定義和呼叫。
"ctrl+\\ g "g表Global，與ctags的Ctrl+]相同。
"ctrl+\\ c "c表Call，列出所有以游標所在字串當函數名的地方。
"ctrl+\\ t "t表Text，列出專案中所有出現游標所在字串的地方。
"ctrl+\\ f "f表File，以游標所在字串當檔名，開啟之。
"ctrl+\\ i "i表Include，以游標所在字串當檔名，列出所有include此檔的檔案。
"ctrl+\\ d "d表calleD，以游標所在字串當函式名，列出所有此函式呼叫的函式。
" ------------------------------ 

" Clang plugin
" ------------------------------
let g:clang_use_library = 1
let g:clang_library_path = '/Library/Developer/CommandLineTools/usr/lib'
" ------------------------------

" Tagbar plugin
" ------------------------------
let g:tagbar_width=30
map <F8> :TagbarToggle<CR>
" ------------------------------

" 顯示行號
set number

" 捲動時保留底下 5 行
set scrolloff=5

" 高亮當前行 (水平)
set cursorline

" 高亮當前列 (垂直)
set cursorcolumn

" 以變色方式顯示搜索结果
set hlsearch

" 自動換行
set wrap

" 滑鼠調整啟動於normal mode and visual mode
set mouse=nv

" enable backspace
set backspace=indent,eol,start

"  加入程式碼收折
set foldmethod=syntax
set nofoldenable

" 開啟即時搜尋功能
set incsearch

" 搜尋不分大小寫
set ignorecase

" 關閉相容模式
set nocompatible

" vim 命令列指令自動補齊
set wildmenu

" 禁止顯示Bar
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

" 禁止顯示工具欄
set guioptions-=m
set guioptions-=T

" 顯示狀態欄
set laststatus=2

" 顯示游標位址
set ruler

" 定義快捷鍵 <Leader>
let mapleader=";"

map <Leader>w :w<CR>
map <Leader>q :q<CR>

" Copy
vmap <Leader>c y

" Paset
map <Leader>v p

" 收程式碼
map <Leader>] zo

" 開程式碼
map <Leader>[ zc

" 開啟行號功能
map <Leader>+n :set number<CR>

" 關閉行號功能
map <Leader>-n :set nonumber<CR>

" 刪除目前所在行數游標以前的字元（不含游標字元）
map <Leader>6 d^

" 刪除目前所在行數游標以後的字元（含游標字元）
map <Leader>4 d$

" Join 下一行到目前這行
map <Leader>j J

" 分割視窗
" :sp [filename] 往上新增水平分割視窗，如未輸入
"       [filename]，新視窗的內容跟原視窗相同
map <Leader>- :sp<CR>

" :vs [filename] 往左新增垂直分割視窗，如未輸入
"       [filename]，新視窗的內容跟原視窗相同
map <Leader>\\ :vs<CR>

" 註解新增
" /*
"  * File:
"  * Author: $NAME
"  *
"  * Created on:
"  */
map <Leader>i1 i/*<CR>File:<CR>Author: $NAME<CR>Created on:<CR>/<CR><ESC>

" #
" # Author: $NAME
" # Date:
" #
map <Leader>i2 i#<CR> Author: $NAME<CR>Date:<CR>

" #ifndef _H
" #define _H
"
" #endif /* _H */
map <Leader>ih i#ifndef _H<CR>#define _H<CR><CR>#endif /* _H  */

" /********************************************************************
"  * Subroutine name:
"  * Brief:
"  *
"  * Input parameter:
"  *
"  * Output parameter:
"  *
"  * Author:
"  *    $NAME
"  * Date:
"  ********************************************************************/
map <Leader>ia i/********************************************************************<CR>Subroutine name:<CR>Brief:<CR><CR>Input parameter:<CR><CR>Output parameter:<CR><CR>Author:<CR><Tab>$NAME<CR><BS>Date:<CR><CR>*******************************************************************/<CR><ESC>

EOF
}

install_vim4powerline()
{
	if exists vim; then
		echo "vim ready"
	else
		brew install vim
		build_vimrc
	fi
}

cat << EOF
        macOS 專用開發用工具箱安裝腳本
                by Sheng-Hung Weng
                E-mail: goodog008@gmail.com
EOF

if exists python3; then
	echo "python3 ready"
else
	brew install python3
fi

read -p "你需要安裝Powerline相關工具嗎？(y/n) " -r INSTALL
if [ "$INSTALL" == "y" ]; then
	install_powerline
fi

read -p "你需要安裝VIM相關工具嗎？(y/n) " -r INSTALLVIM
if [ "$INSTALLVIM" == "y" ]; then
	install_vim4powerline
	install_cscope
	build_vimrc
fi

exit 0
