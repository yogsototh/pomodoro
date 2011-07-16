#!/usr/bin/env zsh

# Here how it is intended to work
# When you start the script, it asks you the name of the task
# Then you work for 25 min. 
# Once finished you are notified it is time to take a break (5 min).
# After 4 work sessions, you take a longer break (30 min).
# Each work session require you enter a name.
# At the end of the day, all your tasks are keep into ~/Documents/Podomoro

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

# show timer
function timer() {
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

# Where to keep trak of your documents?
[[ -e $HOME/.podomoro ]] && source $HOME/.podomoro
if ((NO_LOGS)); then
    logfile=/dev/null
else
    logfiledir=$HOME/Documents/Podomoro
    logfilename=$(date +"tasks-%Y-%m-%d.txt")
    logfile=$logfiledir/$logfilename
    while [[ ! -d $logfiledir ]]; do 
        print -- "$logfiledir does not exists. Would you want to create it? (Y/N)"
        read answer
        case $answer in
            Y|YES|y|yes) mkdir -p $logfiledir || exit 1;;
            *) print -- "Enter a full path of directory to write logs or just enter NO to don't keep tasks."
            read answer
            case $answer in 
                N|n|NO|no) logfiledir=/dev; logfile=/dev/null;;
                *)  
                    logfiledir=$answer; 
                    NO_LOGS=1;
                    logfile=$logfiledir/$logfilename ;;
            esac
            {
                print -- "logfiledir=$logfiledir" 
                (( NO_LOGS )) && print -- "NO_LOGS=1" 
            } > $HOME/.podomoro
            ;;
        esac
    done
fi

nb=1
while (true) {
    notify "Enter the task"
    print -- "Title of the task: "
    read task
    print "$(date +"%H:%M: ") $task" >> $logfile
    print -n -- "WORK NOW! "
    timer $WORKING_TIME
    print -n "\nTime for a break."
    notify "Time for a break."
    if ((nb++ % 4 == 0)); then 
        RELAX_TIME=$LONG_RELAX_TIME
    else
        RELAX_TIME=$SHORT_RELAX_TIME
    fi
    timer $RELAX_TIME
}
