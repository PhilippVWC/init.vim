alias l='ls -lsth'
alias finance='cd "/Users/Philipp/Documents/Masterarbeit/LogMap_Bayes"'
alias vim='nvim'
alias ivm='nvim'
alias vi='nvim'
alias k='pkill -P $$'   # kill all child processes belonging to the current PID
alias untar='tar -xcf'
alias ungzip='gzip -d' 
alias ls='ls -AFG'
alias rm='rm -R'
alias indico="cd /Users/Philipp/Documents/FriedrichChasin/MainIndico/indico"
alias matrix='cmatrix -s'
alias prog='cd /Users/Philipp/bin'
alias mov='hdiutil attach "/Users/Philipp/Documents/Documents ordered/DMG/.SDK_ll2934k239.dmg"'
alias mute='sudo osascript -e "set Volume 0"'
alias gid='dscacheutil -q group -a name'
alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
alias netbeans="/Applications/netbeans/bin/netbeans"

alias RR='source ~/.zshrc'

alias hist='vim /Users/Philipp/.zsh_history'
alias conf='vim /Users/Philipp/bin/aliasesAndFunctions.sh'
alias speedUpTimeMachine='sudo sysctl debug.lowpri_throttle_enabled=0'
alias dyld='/usr/lib/dyld'
alias e="exit"
latex="/usr/local/texlive/2019basic/texmf-dist/tex/latex"
BLOCKSIZE=1024
export MAGICK_HOME="/Users/Philipp/.oh-my-zsh/ImageMagick-7.0.7"
export EDITOR=nvim 
export PATH="$(pwd):/Users/Philipp/.oh-my-zsh/bin:/usr/libexec:$MAGICK_HOME:$PATH:/Users/Philipp/anaconda3/bin" 
export VIMRC="/Users/Philipp/Developer/Vimscript/init.vim/init.vim"
export DVIMRC="/Users/Philipp/Developer/Vimscript/init.vim"
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
		echo -n $wholePath | pbcopy # -n flag: "do not copy the new line character into the clipboard"
	fi
}


#outputs wireless keyboard battery percentage to standart output
function keyboard()
{	if [ $# -ne 0 ];
	then 
		echo "Function does not accept arguments nor options"
	else
		local percentage=$(ioreg -l | grep -Ei '"batteryPercent" =' | tr -d "|" | tr -s "[:blank:]" | cut -c 21-24)
		echo "Your battery percentage is $percentage %"
	fi
}
