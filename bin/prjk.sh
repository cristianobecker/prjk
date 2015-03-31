#!/bin/bash

# variables
UP=$'\033[A'
DOWN=$'\033[B'
COMMAND='prjk'

# functions
display_options() {
    SELECTED=0

    enter_fullscreen
    display_options_with_selected 0

    trap handle_sigint INT
    trap handle_sigtstp SIGTSTP

    while true; do
        read -n 3 c
        case "$c" in
            $UP)
                clear
                local next=`expr $SELECTED - 1`
                display_options_with_selected $next
		;;
            $DOWN)
                clear
                local next=`expr $SELECTED + 1`
                display_options_with_selected $next
                ;;
            *)
                leave_fullscreen
                exit
                ;;
        esac
    done
}

display_options_with_selected() {
    echo $1
    local n=0
    for folder in ${LIST[@]}; do
        if test $n -eq $1; then
            printf "  \033[36mο\033[0m $folder\033[0m\n"
	    SELECTED=$1
        else
            printf "    \033[90m$folder\033[0m\n"
        fi
        let n=n+1
    done
    echo
}

filter_result() {
    LIST=( $(ls $1 | egrep $2) )
}

enter_fullscreen() {
    tput smcup
    stty -echo
}

handle_sigint() {
    leave_fullscreen
    exit $?
}

handle_sigtstp() {
    leave_fullscreen
    kill -s SIGSTOP $$
}

leave_fullscreen() {
    tput rmcup
    stty echo 
}

create_alias() {
    cat <<EOF
$1() {
    if test \$# -eq 0; then cd $2;
    else cd \$($COMMAND go $2 \$1); fi
}
EOF
}

go_to_path() {
    if test $# -eq 2; then
        filter_result $1 $2
        if test ${#LIST[@]} -gt 1; then
            display_options
            sleep 1
            echo 'hello'
            echo "$1/$SELECTED"
        elif test ${#LIST[@]} -eq 1; then
            echo "$1/${LIST[0]}"
        fi
    else        
        echo $1
    fi
}

# handle arguments
if test $# -gt 0; then
    case $1 in
        create|alias) create_alias $2 $3;;
        go) go_to_path $2 $3;;
        help) echo 'show help';;
    esac
fi 
