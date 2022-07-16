#!/bin/bash


kill_process(){
    if [ $# -ne 1 ]
    then
        echo "Please enter the name of the process that should be killed"
        exit 1
    fi
    pids=$( ps -ef | grep $1 | tr -s ' ' | grep -v grep| cut -d ' ' -f3 )
    for pid in $pids
    do
        kill $pid
    done
}

start_python_script(){
    if [ $# -ne 1 ]
    then 
        echo "You did not give a script name to the function <start_python_script>"
        exit 1
    fi
    echo "starting $1"
    python $programs_path$1 &
}

main(){
    echo "Starting automation scripts!"
    prg_name=$( echo $0 |rev |cut -f 1 -d "/" |rev |cut -f 1 -d "." )
    programs_path=$HOME/automation-scripts/
    for file in $programs_path*
    do 
        file=$( echo $file |rev |cut -f 1 -d "/"| rev)
        if [ $( echo $file |cut -f 1 -d ".") != $prg_name ]
        then
            case "$file" in 
                *.py) 
                    kill_process $file
                    start_python_script $file;;
                *) echo "Skipping '$file', because it has an unknown File type";;
            esac
        fi
    done
}


main