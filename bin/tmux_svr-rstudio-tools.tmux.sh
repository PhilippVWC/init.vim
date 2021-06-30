#!/usr/bin/bash
ssh=ssh
portForw=portForw
port1=3252
port2=3253
tmux has-session -t $ssh &> /dev/null
if [ $? != 0 ]; then
	tmux new -s $ssh -d
	tmux send-keys -t $ssh:0.0 'ssh pvwc@svr-rstudio-tools -t tmux attach' C-m
fi
tmux has-session -t $portForw &> /dev/null
if [ $? != 0 ]; then
	tmux new -s $portForw -d
	tmux split-window -v -t $portForw:0.0
	tmux select-layout -t $portForw even-vertical
	tmux send-keys -t $portForw:0.0 "ssh -vvvNL $port1:localhost:$port1 pvwc@svr-rstudio-tools" C-m
	tmux send-keys -t $portForw:0.1 "ssh -vvvNL $port2:localhost:$port2 pvwc@svr-rstudio-tools" C-m
	tmux set-option -t $portForw:0 synchronize-panes
fi
tmux attach -t $ssh
