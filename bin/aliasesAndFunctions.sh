alias l='ls -lsth'
alias vim='nvim'
alias ivm='nvim'
alias vi='nvim'
alias k='pkill -P $$'   # kill all daughter processes belonging to the current PID
alias untar='tar -xcf'
alias ungzip='gzip -d' 
alias ls='ls -AFG'
alias rm='rm -R'
alias matrix='cmatrix -s'
alias RR='source ~/.bashrc'
alias swap="cd /home/philipp/.local/share/nvim/swap"
alias wh="cd /mnt/c/Users/pvwc/"

alias hist='nvim /home/philipp/.bash_history'
alias conf='nvim /home/philipp/aliasesAndFunctions.sh'
alias e="exit"
alias mlr="cd /home/philipp/Developer/R"
alias vimrc="cd /home/philipp/Developer/Vimscript/init.vim"
BLOCKSIZE=1024
export EDITOR=nvim 
export PATH="$PATH:/home/philipp/bin/"
export DYLD_LIBRARY_PATH="$MAGICK_HOME/lib/"

function mkd () {
	if [ $# -eq 0 ]; then
		echo "Usage: mkd directoryName"
	else
		mkdir "$1"
		cd "$1"
	fi
}

function remount() {
	if [ $# -eq 0 ]; then
		echo "Usage: remount /dev/diskU , (U: Unit Number)"
	else
		diskutil unmount "$1"
		diskutil mount "$1"
	fi
}

function swap()         
{
  if [ $# -ne 2 ]; then
    echo "Usage: swap file1 file2"
  else
    local TMPFILE=$(mktemp)
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
  fi
}
# prints the whole path including the filename to the standart output prompt and pastes it to the clipboard
# $ in combination with paranthesis means using the output of command
# $ without paranthesis means using the content of a variable
function pth()
{	if [ $# -eq 0 ]; then
		echo $(pwd)
		echo -n $(pwd) | pbcopy
	else
		local fileName=$1
		local wholePath=$(pwd)/$fileName
		echo $wholePath
		echo -n $wholePath | xclip # -n flag: "do not copy the new line character into the clipboard"
	fi
}


