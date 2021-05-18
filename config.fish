# Personal configuration for fish shell
# Philipp van Wickevoort Crommelin

set -gx EDITOR "nvim"
set -x theme_nerd_fonts yes
set -U fish_user_paths /home/philipp/Developer/Vimscript/init.vim/bin /home/philipp/.local/bin /home/philipp/Developer/Shell/shiny_setup 
set -U GOPATH $HOME/go
# disable fish greeting on startup
set fish_greeting

abbr --add 'tmuxconf' '$EDITOR /home/$USER/.tmux.conf'
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
    set ppid (ps -p (echo $fish_pid) -o ppid=)
    # remove leading whitespaces
    # that sometimes are produced by ps
    set ppid (string trim $ppid)
    set pcmd (ps -p (echo $ppid) -o comm=)
    set pcmd (string trim $pcmd)
    if echo $pcmd | grep -q "^nvim\$"
        fish_default_key_bindings
    else
        fish_vi_key_bindings
    end
end
setKeybindings



# Start openSSH authentication agent if 
# has not happened yet
function start_ssh_agent
    set e /home/$USER/.ssh/agent.env
    eval ssh-add -l > /dev/null 2>&1
    set s $status
    switch $s
        case 1
            echo "OpenSSH authentication agent running but with wrong keys"
            echo "Key will now be added."
            ssh-add
        case 2
            echo "Launch openSSH authentication agent:"
            ssh-agent -c > $e 2>/dev/null
            source $e
            set -xU SSH_AUTH_SOCK $SSH_AUTH_SOCK
            set -xU SSH_AGENT_PID $SSH_AGENT_PID
            ssh-add
            rm $e
        end
end
start_ssh_agent

# Display a powerline command prompt
function fish_prompt
    eval $GOPATH/bin/powerline-go -error $status -jobs (jobs -p | wc -l)
end
