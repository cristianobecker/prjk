#!/bin/bash

_prjk_alias() {
    local folder=`cd $2 && pwd`
    local file=~/.bash_profile
    test -e ~/.bashrc && file=~/.bashrc

    echo "alias $1=\". prjk go $folder\"" >> $file
    source $file
    
    _prjk_unset
}

_prjk_find() {
    if test $# -eq 2; then
        _prjk_filter $1 $2
        if test ${#LIST[@]} -gt 1; then
            _prjk_options $1
        elif test ${#LIST[@]} -eq 1; then
            _prjk_cd "$1/${LIST[0]}"
        else 
            echo 'sub-folder not found'
            _prjk_unset
        fi
    else        
        _prjk_cd $1
    fi
}

_prjk_help() {
    cat <<-EOF

  Usage: . prjk [COMMAND] [args]

  Commands:
    . prjk alias <name> <folder>     Configure an alias with the specific folder
    . prjk find <folder> <search>    The command called by the alias. Makes the search
                                     on folder and show a options menu if necessary
    prjk help                        Display help information

EOF
    _prjk_unset
}

_prjk_options() {
    _prjk_fullscreen
    _prjk_select 0
    
    local tmpf=`mktemp "/tmp/prjk.temp.XXXXX"`

    (   
        SELECTED=0        
        
        trap 'exit' INT

        while read -rsn1 c; do
            case $c in
                $'\x1b')
                    read -rsn2 -t 1 c2
                    case $c2 in
                        "[A") 
                            SELECTED=`expr $SELECTED - 1`
                            test $SELECTED -lt 0 && SELECTED=0
                            ;;
                        "[B")
                            SELECTED=`expr $SELECTED + 1`
                            test `expr $SELECTED + 1` -ge $TOTAL && SELECTED=`expr $TOTAL - 1`
                            ;;
                        *)
                            SELECTED=-1
                            break ;;
                    esac
                    test $SELECTED -ge 0 && _prjk_select $SELECTED 
                    ;;
                "")
                    echo enter
                    break 
                    ;;
                *)
                    SELECTED=-1
                    break 
                    ;;
            esac
        done

        echo $SELECTED > $tmpf
    )
    
    local selected=`cat $tmpf || echo -1`
    rm $tmpf

    
    _prjk_leave
    
    if test ! -z $selected && test $selected -ge 0; then
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
    tput cuu $TOTAL
}

_prjk_filter() {
    OLDIFS="$IFS"
    IFS=$'\n'

    LIST=(`cd $1 && ls -1d */ | egrep -i $2 | head -n 20`)
    TOTAL=${#LIST[@]}
}

_prjk_cd() {
    _prjk_unset

    echo "cd $1"
    cd "$1" 
}

_prjk_fullscreen() {
    tput civis
    stty -echo
}

_prjk_leave() {
    tput cud $TOTAL
    tput cnorm
    stty echo 
}

_prjk_unset() {
    trap - INT
    
    unset _prjk_filter
    unset _prjk_cd
    unset _prjk_find
    unset _prjk_help
    unset _prjk_options
    unset _prjk_sigint
    unset _prjk_alias
    unset _prjk_fullscreen
    unset _prjk_leave
    unset _prjk_select
    unset _prjk_unset
   
    unset LIST 
    unset TOTAL 
    
    if test -n "$OLDIFS"; then
        IFS="$OLDIFS"
        unset OLDIFS
    fi
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
