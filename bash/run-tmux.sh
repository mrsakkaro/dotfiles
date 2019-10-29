#!/bin/bash
cd ~/Repository/mmt-server/services

tmux new-session -d -s mmt2 \; \
    split-window -h -p 10 \; \
    select-pane -t 1 \; \
    split-window -v -p 80 \; \
    select-pane -t 1 \; \
    split-window -h -p 70 \; \
    select-pane -t 2 \; \
    send-keys 'htop' C-m \;
    
