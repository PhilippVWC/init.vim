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
abbr --add 'e' "exit 0"
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
# set_tmux_prefix {{{
# This function sets an exportet environment variable
# "TMUX_PREFIX" according to wether current fish 
# session is remote (SSH) or local
function set_tmux_prefix
    # set variable $SSH_LOGIN
    if ! test -e $HOME/.prefix.tmux.conf
        #         set_ssh_login
        if test -n "$SSH_TTY"
            # remote session
            set -Ux TMUX_PREFIX "w"
        else
            # local session
            set -Ux TMUX_PREFIX "^"
        end
        printf "set -g prefix C-$TMUX_PREFIX\nunbind C-$TMUX_PREFIX\nbind C-$TMUX_PREFIX send-prefix" >$HOME/.prefix.tmux.conf

	# If tmux runs at the moment configure new prefix
        if test -n "$TMUX"
            tmux source-file "$HOME/.prefix.tmux.conf"
	    echo "New tmux prefix set to \"$TMUX_PREFIX\" in running tmux client session"
        end
	echo "prefix set to \"$TMUX_PREFIX\""
	echo "Tmux prefix configuration stored in $HOME/.prefix.tmux.conf"
    else
        echo "Tmux prefix already set to \"$TMUX_PREFIX\""
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
set_tmux_prefix
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
