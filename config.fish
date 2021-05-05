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

function setKeybindings
    # This function evaluates, wether the current
    # fish shell was started from neovim.
    # If true, then VI-Keybings are disabled,
    # since this would conflict with neovim.
    set ppid (ps -q (echo $fish_pid) -o ppid=)
    set pcmd (ps -q $ppid -o comm=)
    if echo $pcmd | grep -q "^nvim\$"
        fish_default_key_bindings
    else
        fish_vi_key_bindings
    end
end
setKeybindings

# go powerline prompt
function fish_prompt
    eval $GOPATH/bin/powerline-go -error $status -jobs (jobs -p | wc -l)
end
