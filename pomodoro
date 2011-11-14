#!/usr/bin/env zsh

# Here how it is intended to work
# When you start the script, it asks you the name of the task
# Then you work for 25 min. 
# Once finished you are notified it is time to take a break (5 min).
# After 4 work sessions, you take a longer break (30 min).
# Each work session require you enter a name.
# At the end of the day, all your tasks are keep into ~/Documents/Podomoro

PODOMORO_NO_LOGS=0
# in minutes
PODOMORO_WORKING_TIME=25
PODOMORO_SHORT_RELAX_TIME=5
PODOMORO_LONG_RELAX_TIME=30

function notify() {
    print -n -- "$*"

    if [[ "$PODOMORO_NOTIFY" != "" ]]; then
        eval $( echo $PODOMORO_NOTIFY | sed 's/%m/"'$message'"/g' )
        return
    fi

    case $(uname) in
        Darwin) # On Mac
                if [[ ! -x =growlnotify ]]; then 
                    {
                    print -- "Growl seems not installed"
                    print -- "If you want to have notifications you might want to install it"
                    } >&2
                else
                    growlnotify -m "Pomodory says $*"
                fi
                ;;
        Linux) # on Ubuntu => sudo apt-get install libnotify-bin
               # on other systems libnotify
               local DELAY=5 # in seconds
               local ICON=/usr/share/icons/Tango/32x32/actions/appointment.png
               notify-send \
                   --urgency=critical \
                   --expire-time=$(( DELAY * 1000 )) \
                   --icon=$ICON "Pomodoro says" $*
               ;;
        *) {
            print -- "I don't made a notification system for your system"
            print -- "You can use the \$HOME/.podomoro file to declare your own notification system"
            print -- "For example: "
            print -- "PODOMORO_NOTIFY=\"notify_cmd --message=%m\""
            print
            print -- "Then it will be executed as \"notify_cmd\" --message=\"notification message\""
            } >&2
    esac
}

# show timer
function timer() {
    local m=$1
    local s=00
    local rem=""
    local firsttime=1
    while (( m+s > 0 )); do
        ((s--))
        if ((s<0)); then 
            ((s=59)) 
            ((m--))
        fi
        printf "$rem%02d:%02d" $m $s
        (( $firsttime )) && {
            rem="\b\b\b\b\b"
            firsttime=0
        }
        read -t 1 && { 
            return 1
        }
    done
    print
    return 0
}
funtion posttimer() {
    local m=00
    local s=00
    local rem=""
    local firsttime=1
    while : ; do
        ((s++))
        if ((s>59)); then 
            ((s=0)) 
            ((m++))
            notify "\nTime for a break\n"
        fi
        printf "$rem+%02d:%02d" $m $s
        (( $firsttime )) && {
            rem="\b\b\b\b\b\b"
            firsttime=0
        }
        read -t 1 && break
    done
}

# Where to keep trak of your documents?

function initialize() {
    # read the .podomoro file if it exists
    [[ -e $HOME/.podomoro ]] && source $HOME/.podomoro
    if ((PODOMORO_NO_LOGS)); then
        logfile=/dev/null
    else
        logfiledir=$HOME/Documents/Podomoro
        logfilename=$(date +"week-%V.txt")
        logfile=$logfiledir/$logfilename
        while [[ ! -d $logfiledir ]]; do 
            print -- "$logfiledir does not exists. Would you want to create it? (y/n)"
            read answer
            case $answer in
                Y|YES|y|yes) mkdir -p $logfiledir || exit 1;;
                *) print -- "Enter a full path of directory to write logs or just enter NO to don't keep tasks."
                    read answer
                    case $answer in 
                        N|n|NO|no) logfiledir=/dev; logfile=/dev/null
                        ;;
                        *)  logfiledir=$answer; 
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
}

nb=1
initialize
while (true) {
    notify "Enter the title of the task: "
    read task
    startedTime=$(date +"%H:%M")
    # print "$(date +"%A (%F) %H:%M → ") $task" >> $logfile
    print -n -- "WORK NOW! "
    if timer $PODOMORO_WORKING_TIME; then
        notify "Time for a break. "
        posttimer 
    fi
    print "$(date +"%A (%F) $startedTime → %H:%M") $task" >> $logfile

    if ((nb++ % 4 == 0)); then 
        PODOMORO_RELAX_TIME=$PODOMORO_LONG_RELAX_TIME
    else
        PODOMORO_RELAX_TIME=$PODOMORO_SHORT_RELAX_TIME
    fi
    notify "PAUSE "
    timer $PODOMORO_RELAX_TIME
}
