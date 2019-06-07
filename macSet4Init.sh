#!/bin/bash
###################################################
#	macOS ssh connect script
#	
#	Author: Sheng-Hung Weng
#	E-mail: goodog008@gmail.com
#	Reversion: v20190607.1.0.0
#
###################################################
GITSRC=

exists()
{
	command -v "$1" >/dev/null 2>&1
}

cat << EOF
	macOS 專用gitHub 自動設定腳本
		by Sheng-Hung Weng
		E-mail: goodog008@gmail.com
EOF

if exists brew; then
	echo "brew ready"
else
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
if exists mate; then
        echo "mate ready"
else
        brew cask install textmate
fi
if exists p4merge; then
	echo "merge tool ready"
else
	brew cask install p4v
fi
if exists extMerge; then
	echo "extMerge ready"
else
	cat << EOF > extMerge
#!/bin/bash
/Applications/p4merge.app/Contents/MacOS/p4merge \$*
EOF
	sudo chmod +x extMerge
	sudo mv extMerge /usr/local/bin/extMerge
fi
if exists extDiff; then
	echo "extDiff ready"
else
	cat << EOF > extDiff
#!/bin/bash
[ \$# -eq 7 ] && /usr/local/bin/extMerge "\$2" "\$5"
EOF
	sudo chmod +x extDiff
	sudo mv extDiff /usr/local/bin/extDiff  
fi
if exists git; then
	echo "git ready"
else
	brew install git
fi

read -p "請問你需要修改git使用者設定嗎？(y/n) " -r SETGIT
if [ "$SETGIT" == "y" ]; then
	read -p "請輸入使用者名稱（只支援英文）: " -r AUTHOR
        read -p "請輸入使用者E-mail： " -r EMAIL
        git config --global user.name "$AUTHOR"
        git config --global user.email "$EMAIL"
	git config --global core.editor "mate -w"
	git config --global merge.tool extMerge
	git config --global mergetool.extMerge.cmd \
		'extMerge "$BASE" "$LOCAL" "$REMOTE" "$MERGED"'
	git config --global mergetool.trustExitCode false
	git config --global diff.external extDiff
        git config -l
fi

read -p "請問你要設定github連線嗎？(y/n)： " -r SETGITHUB
if [ "$SETGITHUB" == "y" ]; then
	read -p "請輸入使用者E-mail： " -r EMAIL
	cat << EOF
接下來需要新增與github連線用加密Key，流程如下：
	Step 1:
		輸入產生key後的存放位置「請用絕對位置」
	Step 2:
		會詢問額外密碼（如果有設定，每次連線時需要輸入密碼後才可使用此Key連線）
EOF
	ssh-keygen -t rsa -b 4096 -C "$EMAIL"	
	read -p "請輸入Key存放位置 （E.g ~/.ssh/id_rsa）: " -r KEYPATH
	ssh-add -K $KEYPATH
	pbcopy < $KEYPATH.pub
	cat << EOF
現在你可以根據以下網站從第2步開始進行操作：
	https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account
	
備註：
		當你按下「New SSH Key」後，你已經可以直接貼上內容到"Key"欄位，
	因為已經自動幫你把pub key放到剪貼簿上了。
	
	你需要做的只有：
		1. 在"Key"欄位上，點滑鼠右鍵並貼上。
		2. 在"Title"欄位上，填寫一個方便記憶此Key的名稱。（E.g Sheng-Hung Mac Key）
	
	點選「Add SSH key」後將在你的E-mail 接收到設定完成通知。

NEXT:
	你可以在你自己的Github帳戶新增自己的GitHub Repository相關操作。
	可參考此網頁內容操作：
		https://help.github.com/en/articles/create-a-repo	
EOF
fi

exit 0
