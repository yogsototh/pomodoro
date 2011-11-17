#!/usr/bin/awk -f
# number of minutes from str of hh:mm format
function minFromTime(str){
    h=str; 
    m=str; 
    gsub(/:.*$/,"",h); 
    gsub(/^.*:/,"",m); 
    return h*60+m;
} 
# take a number of minutes, return a xh xxm format
function timeFromMin(time) {
    m=time%60;
    h=(time -m )/60;
    if (m<10) {
        m="0"m;
    }
    return h"h "m"m";
}

# get the name of the task
function message(){
    msg=$6;
    for (i=7;i<=NF;i++) {msg=msg" "$i}
    return msg;
} 

# For each line
{
    m=message()
    time[m]=time[m]+minFromTime($5)-minFromTime($3);
} 

# Print the result
END {
    for(i in time) {
        print i"\t:\t"timeFromMin(time[i]);
    }
}
