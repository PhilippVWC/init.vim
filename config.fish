# Personal configuration for fish shell
# Philipp van Wickevoort Crommelin

# ------------------------------ Abbreviations{{{
abbr --add 'rss' 'pvwc@svr-rstudio-tools:/home/pvwc/'
abbr --add 'rci' 'R CMD INSTALL'
abbr --add 'tmuxconf' '$EDITOR /home/$USER/.tmux.conf'
abbr --add 'l' 'ls -lstha'
abbr --add 'vim' 'nvim'
abbr --add 'ivm' 'nvim'
abbr --add 'vi' 'nvim'
abbr --add 'k' "pkill -P $fish_pid" # kill all daughter processes belonging to the current PID
abbr --add 'untar' 'tar -xcf'
abbr --add 'ungzip' 'gzip -d'
abbr --add 'matrix' 'cmatrix -s'
abbr --add 'conf' '$EDITOR $__fish_config_dir/config.fish'
abbr --add 'settings' '$EDITOR /mnt/c/Users/pvwc/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'
abbr --add 'RR' 'source $__fish_config_dir/config.fish'
abbr --add 'e' "exit"
abbr --add 'mlr' "cd /home/philipp/Developer/R"
# }}}
# ------------------------------ function definitions{{{
# set_key_bindings {{{
# This function evaluates, wether the current
# fish shell was started from neovim.
# If true, then VI-Keybings are disabled,
# since this would conflict with neovim.
function set_key_bindings
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
# }}}
# is_ssh_login {{{
# Check wether current fish session 
# is a remote ssh login session
# returns 0 if yes or 1 otherwise
function is_ssh_login
    if test -z $SSH_LOGIN
        set ppid (ps -p (echo $fish_pid) -o ppid=)
        set ppid (string trim $ppid)
        set ppcmd (ps -p (echo $ppid) -o comm=)
        set ppcmd (string trim $ppcmd)
        if test "$ppcmd" -eq "sshd"
            set -Ux SSH_LOGIN 0
        else
            set -Ux SSH_LOGIN 1
        end
        return $SSH_LOGIN
    else
        return $SSH_LOGIN
    end
end
# }}}
# start_ssh_agent {{{
# Start openSSH authentication agent if 
# has not happened yet
function start_ssh_agent
    set e /home/$USER/.ssh/agent.env
    eval ssh-add -l >/dev/null 2>&1
    set s $status
    switch $s
        case 1
            echo "OpenSSH authentication agent running but with wrong keys"
            echo "Key will now be added."
            ssh-add
        case 2
            echo "Launch openSSH authentication agent:"
            ssh-agent -c >$e 2>/dev/null
            source $e
            set -xU SSH_AUTH_SOCK $SSH_AUTH_SOCK
            set -xU SSH_AGENT_PID $SSH_AGENT_PID
            ssh-add
            rm $e
    end
end
# }}}
# fish_prompt {{{
# Display a powerline command prompt
function fish_prompt
    set_key_bindings
    powerline-shell --shell bare $status
    #     eval $GOPATH/bin/powerline-go -error $status -jobs (jobs -p | wc -l)
end
# }}}
# }}}
# ------------------------------ Function calls{{{
start_ssh_agent
is_ssh_login
# }}}
# ------------------------------ Variable definitions{{{
set -gx EDITOR "nvim"
set -gx theme_nerd_fonts yes
# set -gx fish_user_paths /home/philipp/Developer/Vimscript/init.vim/bin /home/philipp/.local/bin /home/philipp/Developer/Shell/shiny_setup 
set -gx PATH $HOME{/Developer/Vimscript/init.vim/bin, /.local/bin, /Developer/Shell/shiny_setup, /neovim/bin} $PATH
# set -gx PATH $PATH /home/philipp/Developer/Vimscript/init.vim/bin /home/philipp/.local/bin /home/philipp/Developer/Shell/shiny_setup /usr/local/lib/ruby/gems/3.0.0/bin

set -gx GOPATH $HOME/go
# disable fish greeting on startup
set -g fish_greeting
# }}}
