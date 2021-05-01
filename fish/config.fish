# Personal configuration for fish shell
# Philipp van Wickevoort Crommelin

set -x PATH "$PATH /home/philipp/Developer/Shell/shiny_setup/"
set -x PATH "$PATH /home/philipp/Developer/Vimscript/init.vim/bin/"
set -x EDITOR "nvim"

abbr --add 'l' 'ls -lsth'
abbr --add 'vim' 'nvim'
abbr --add 'ivm' 'nvim'
abbr --add 'vi' 'nvim'
abbr --add 'k' "pkill -P $fish_pid"   # kill all daughter processes belonging to the current PID
abbr --add 'untar' 'tar -xcf'
abbr --add 'ungzip' 'gzip -d' 
abbr --add 'matrix' 'cmatrix -s'
abbr --add 'conf' '$EDITOR $__fish_config_dir/config.fish'
abbr --add 'RR' 'source $__fish_config_dir/config.fish'
abbr --add 'e' "exit"
abbr --add 'mlr' "cd /home/philipp/Developer/R"
