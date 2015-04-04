#!/bin/bash

_prjk_alias() {
    local folder=`cd $2 && pwd`
    
    echo "alias $1=\". prjk go $folder\"" >> ~/.bash_profile
    source ~/.bash_profile
    
    _prjk_unset
}

_prjk_find() {
    if test $# -eq 2; then
        _prjk_filter $1 $2
        if test ${#LIST[@]} -gt 1; then
            _prjk_options $1
        elif test ${#LIST[@]} -eq 1; then
            _prjk_cd "$1/${LIST[0]}"
        fi
    else        
        _prjk_cd $1
    fi
}

_prjk_help() {
    echo 'help'
    _prjk_unset
}

_prjk_options() {
    _prjk_fullscreen
    _prjk_select 0

    local up=$'\033[A'
    local down=$'\033[B'
    local selected=0
    local total=${#LIST[@]}
    
    #trap _prjk_sigint INT
    trap '' INT

    while read -n 3 c; do
        case $c in
            $up)
                let selected=`expr $selected - 1`
                if test $selected -lt 0; then let selected=0; fi
                
                _prjk_select $selected
	    	    ;;
            $down)
                let selected=`expr $selected + 1`
                if test `expr $selected + 1` -ge $total; then let selected=`expr $total - 1`; fi
                
                _prjk_select $selected
                ;;
            *)
                break
                ;;
        esac
    done
   
    _prjk_leave
    
    if test $selected -gt -1; then
        _prjk_cd "$1/${LIST[$selected]}" 
    else 
        echo "cancel"
        _prjk_unset
    fi
}

_prjk_select() { 
    local n=0
    for folder in ${LIST[@]}; do
        if test $n -eq $1; then
            printf "  \033[32m√\033[0m $folder\033[0m\n"
        else
            printf "    \033[90m$folder\033[0m\n"
        fi
        let n=n+1
    done
    tput cuu ${#LIST[@]}
}

_prjk_filter() {
    local oldifs="$IFS"
    IFS=$'\n'
    LIST=(`ls -1 $1 | egrep -i $2`)
    IFS="$oldifs"
}

_prjk_cd() {
    local list=$LIST
    _prjk_unset

    echo "cd $1"
    
    cd $1 
}

_prjk_fullscreen() {
    tput civis
    stty -echo
}

_prjk_leave() {
    tput cud ${#LIST[@]}
    tput cnorm
    stty echo 
}

#_prjk_sigint() {
#    _prjk_leave
#    echo 'sigint'
#}


_prjk_unset() {
    trap - INT
    
    unset _prjk_filter
    unset _prjk_cd
    unset _prjk_find
    unset _prjk_help
    unset _prjk_options
    #unset _prjk_sigint
    unset _prjk_alias
    unset _prjk_fullscreen
    unset _prjk_leave
    unset _prjk_select
    unset _prjk_unset
   
    unset LIST 
}


# handle arguments

if test $# -gt 0; then
    case $1 in
        create|alias) _prjk_alias $2 $3 ;;
        go|find) _prjk_find $2 $3 ;;
        help) _prjk_help ;;
        *) _prjk_unset ;;
    esac
fi 
