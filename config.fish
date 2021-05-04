# Personal configuration for fish shell
# Philipp van Wickevoort Crommelin

set -gx EDITOR "nvim"
set -x theme_nerd_fonts yes
set -U fish_user_paths /home/philipp/Developer/Vimscript/init.vim/bin $fish_user_paths
set -U fish_user_paths /home/philipp/.local/bin $fish_user_paths
set -U fish_user_paths /home/philipp/Developer/Shell/shiny_setup $fish_user_paths
set -U GOPATH /home/philipp/go
# disable fish greeting on startup
set fish_greeting

abbr --add 'l' 'ls -lstha'
abbr --add 'vim' 'nvim'
abbr --add 'ivm' 'nvim'
abbr --add 'vi' 'nvim'
abbr --add 'k' "pkill -P $fish_pid"   # kill all daughter processes belonging to the current PID
abbr --add 'untar' 'tar -xcf'
abbr --add 'ungzip' 'gzip -d' 
abbr --add 'matrix' 'cmatrix -s'
abbr --add 'conf' '$EDITOR $__fish_config_dir/config.fish'
abbr --add 'settings' '$EDITOR /mnt/c/Users/pvwc/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'
abbr --add 'RR' 'source $__fish_config_dir/config.fish'
abbr --add 'e' "exit"
abbr --add 'mlr' "cd /home/philipp/Developer/R"

fish_vi_key_bindings

# launchSshAgent # Skript to launch an ssh agend
# fish_default_key_bindings # return to normal keybindings
# python pwerline prompt
# function fish_prompt
#     powerline-shell --shell bare $status
# end
# go powerline prompt
function fish_prompt
    eval $GOPATH/bin/powerline-go -error $status -jobs (jobs -p | wc -l)
end
