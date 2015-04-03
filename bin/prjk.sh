#!/bin/bash

# variables

WHILE_HANDLER=0


# functions

_prjk_alias() {
    local COMMAND='prjk'
    local FOLDER=`cd $2 && pwd`
    
    echo "alias $1=\". $COMMAND go $FOLDER\"" >> ~/.bash_profile
    source ~/.bash_profile
    
    _prjk_unset
}

_prjk_find() {
    if test $# -eq 2; then
        _prjk_filter $1 $2
        if test ${#LIST[@]} -gt 1; then
            _prjk_options $1
        elif test ${#LIST[@]} -eq 1; then
            _prjk_unset
            cd "$1/${LIST[0]}"
        fi
    else        
        _prjk_unset
        cd $1
    fi
}

_prjk_help() {
    echo 'help'
}

_prjk_options() {
    _prjk_fullscreen
    _prjk_select 0

    trap _prjk_sigint INT
    trap _prjk_sigtstp SIGTSTP

    WHILE_HANDLER=0
    local UP=$'\033[A'
    local DOWN=$'\033[B'
    local SELECTED=0
    
    while test $WHILE_HANDLER -eq 0; do
        read -n 3 c
        case $c in
            $UP)
                clear
                let SELECTED=`expr $SELECTED - 1`
                _prjk_select $SELECTED
	    	    ;;
            $DOWN)
                clear
                let SELECTED=`expr $SELECTED + 1`
                _prjk_select $SELECTED
                ;;
            *)
                _prjk_leave
                WHILE_HANDLER=1
                ;;
        esac
    done
    
    if test $WHILE_HANDLER -eq 1; then 
        _prjk_unset
        cd "$1/${LIST[$SELECTED]}"
    fi
}

_prjk_select() {
    echo $1
    local n=0
    for folder in ${LIST[@]}; do
        if test $n -eq $1; then
            printf "  \033[36mο\033[0m $folder\033[0m\n"
        else
            printf "    \033[90m$folder\033[0m\n"
        fi
        let n=n+1
    done
    echo
}

_prjk_filter() {
    IFS=$'\n'
    LIST=(`ls -1 $1 | egrep -i $2`)
}

_prjk_fullscreen() {
    tput smcup
    stty -echo
}

_prjk_leave() {
    tput rmcup
    stty echo 
}

_prjk_sigint() {
    _prjk_leave
    WHILE_HANDLER=2
}

_prjk_sigtstp() {
    _prjk_leave
    _prjk_unset
    kill -s SIGSTOP $$
}

_prjk_unset() {
    unset _prjk_filter
    unset _prjk_find
    unset _prjk_help
    unset _prjk_options
    unset _prjk_sigint
    unset _prjk_sigtstp
    unset _prjk_alias
    unset _prjk_fullscreen
    unset _prjk_leave
    unset _prjk_select
    unset _prjk_unset
    
    unset IFS
    unset WHILE_HANDLER
}


# handle arguments

if test $# -gt 0; then
    case $1 in
        create|alias) _prjk_alias $2 $3 ;;
        go|find) _prjk_find $2 $3 ;;
        help) _prjk_help ;;
    esac
fi 
