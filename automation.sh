#!/bin/bash


setup(){
    echo "Starting setup..."
    program_path=$dir_path/automation.sh
    program_name=automation

    python3 --version > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo $'\e[1;31m'ERROR:$'\e[0m python3 is not installed.'
        echo 'Please install python3 before running the setup again.'
        exit 1
    fi 

    if [ ! -L "/usr/local/bin/$program_name" ]; then
        ln -s $program_path /usr/local/bin/$program_name > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Successfully created a symlink"
            echo "You can run the automation scripts by using the command <$program_name> from your terminal!"
        else
            echo $'\e[1;31m'ERROR:$'\e[0m Symlink creation failed!'
            if [ $USER != "root" ]; then
                echo "Probably due to the setup not being run with root permissions."
            fi
            echo "To manually create the symlink use the following command: "
            echo $'\e[1;33m'Command:$'\e[0m' "sudo ln -s $program_path /usr/local/bin/$program_name"
        fi
    fi

    for file in $absolute_requirements_path*
    do
        absolute_file_path=$file
        file=$( echo $file |rev |cut -f 1 -d "/"| rev )
        case "$( echo $file |cut -f 1 -d "_" )" in
            python)
                python3 -m pip install -r $absolute_file_path > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "Successfully installed python requirements!"
                else
                    echo $'\e[1;31m'ERROR:$'\e[0m an unexpected error occured while installing python requirements'
                fi;;
            *) 
                echo "Skipping requirements file: '$file', Unkown type!";;
        esac
    done
}

kill_process(){
    if [ $# -ne 1 ]; then
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
    if [ $# -ne 1 ]; then 
        echo "You did not give a script name to the function <start_python_script>"
        exit 1
    fi
    echo "starting $1"
    python3 $1 &
}

start(){
    echo "Starting automation scripts!"
    for script in $absolute_scripts_path*; do 
        absolute_script_path=$script
        script=$( echo $script |rev |cut -f 1 -d "/"| rev)
        case "$script" in 
            *.py) 
                kill_process $script
                start_python_script $absolute_script_path;;
            *) echo "Skipping script: '$script', Unknown script type!";;
        esac
    done
}

usage(){
    echo "USAGE: <$( echo $0 |rev |cut -f 1 -d '/' |rev )> setup|run"
    exit 1
}

dir_path=$( readlink -f $0 |rev |cut -f2- -d "/" |rev )
absolute_scripts_path=$dir_path/scripts/
absolute_requirements_path=$dir_path/requirements/



case "$1" in
    setup)
        setup;;
    run)
        start;;
    *)
        usage
esac