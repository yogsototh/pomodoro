#!/usr/bin/env zsh

# in minutes
WORKING_TIME=25
SHORT_RELAX_TIME=5
LONG_RELAX_TIME=30

function notify() {
    local DELAY=5 # in seconds
    local ICON=/usr/share/icons/Tango/32x32/actions/appointment.png

    case $(uname) in
        Darwin) # On Mac
                growlnotify -m "Pomodory says $*"
                ;;
        Linux) # on Ubuntu => sudo apt-get install libnotify-bin
               # on other systems libnotify
               notify-send \
                   --urgency=critical \
                   --expire-time=$(( DELAY * 1000 )) \
                   --icon=$ICON "Pomodoro says" $*
               ;;
    esac
}

function ysleep() {
    m=$1
    s=00
    while (( m+s > 0 )); do
        ((s--))
        if ((s<0)); then 
            ((s=59)) 
            ((m--))
        fi
        printf "$rem%02d:%02d" $m $s
        rem="\b\b\b\b\b"
        sleep 1
    done
}

nb=1
tasks=()
logfile=$(date +"podomoro-%Y-%m-%d.tasks")
while (true) {
    notify "Enter the task"
    print -- "Title of the task: "
    read task
    print "$(date +"%H:%M: ") $task" >> $logfile
    print -n -- "WORK NOW! "
    ysleep WORKING_TIME
    notify "Time to take break"
    if ((nb % 4 == 0)); then 
        RELAX_TIME=$SHORT_RELAX_TIME
    else
        RELAX_TIME=$LONG_RELAX_TIME
    fi
    ysleep $RELAX_TIME
}
