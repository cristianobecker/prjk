#!/bin/bash


# 1.1 
# CREATE AND CONFIGURE AN ALIAS

_prjk_alias() {
    # get the absolute path of destiny folder
    local folder=`cd $2 && pwd`
    
    # set the destiny file to ~/.bash_profile or ~/.bashrc
    local file=~/.bash_profile
    test -e ~/.bashrc && file=~/.bashrc

    # print the alias syntax
    echo "alias $1=\". prjk go $folder\"" >> $file
    
    # 'update' the file to allow to use the alias 
    # immediately after the creation
    source $file
    
    # unset the functions and variables to the current section (1.4)
    _prjk_unset
}



# 1.2
# MAKE THE SEARCH AND GO
# this is the funcion called by alias

_prjk_find() {
    # check if the number of arguments are 2
    if test $# -eq 2; then
        # make the filter (1.2.1)
        _prjk_filter $1 $2

        # check if there is more than one result to show the options menu
        if test $TOTAL -gt 1; then
            # show the options menu (1.2.2)
            _prjk_options $1
        elif test $TOTAL -eq 1; then
            # if only one result, go to that folder (1.2.3)
            _prjk_cd "$1/${LIST[0]}"
        else 
            # show error if the search didn't match
            echo 'sub-folder not found'

            # unset the functions and variables to the current section (1.4)
            _prjk_unset
        fi
    else
        # if only call the alias, without second parameter, 
        # just go the destiny folder (1.2.3)
        _prjk_cd $1
    fi
}



#   1.2.1
#   FILTER THE SUB-FOLDERS

_prjk_filter() {
    # save IFS to an variable and set \n
    # this is to keep folders with space
    OLDIFS="$IFS"
    IFS=$'\n'

    # makes the filter listing only folders of,
    # destiny folder, applying egrep for the filter
    # and limiting to 20 results
    LIST=(`cd $1 && ls -1d */ | egrep -i $2 | head -n 20`)
    TOTAL=${#LIST[@]}
}



#   1.2.2
#   ENTER IN MENU MODE

_prjk_options() {
    # enter in mode were echo is locked and the cursor
    # is hidden (fullscreen was the first name - 1.2.2.1)
    _prjk_fullscreen

    # show the menu with the fist item selected (1.2.2.2)
    _prjk_select 0
    
    # creating a temp file to store the value
    # selected in subshell
    local tmpf=`mktemp "/tmp/prjk.temp.XXXXX"`

    # creating a subshell for the read operation,
    # this is the only way to use 'exit' when the
    # user press ctrl+c without closing the current
    # section
    (   
        # variables
        ENTER=""
        ARROW=$'\033'
        UP="[A"
        DOWN="[B"

        SELECTED=0        
        
        # configuring the handler for the ctrl+c
        # which is the simple 'exit' command
        trap 'exit' INT

        # read one character and repeat
        while read -rsn1 c; do
            case $c in
                # if the character is the first part of the arrow 
                # button in keyboard enter in this cas
                $ARROW)
                    # read the second part of the key pressed
                    read -rsn2 -t 1 c2
                    case $c2 in
                        $UP) 
                            # is up? subtract
                            SELECTED=`expr $SELECTED - 1`
                            ;;
                        $DOWN)
                            # is down? sum
                            SELECTED=`expr $SELECTED + 1`
                            ;;
                        *)
                            # is other? cancel while and stop subshell
                            SELECTED=-1
                            break 
                            ;;
                    esac
                    
                    # verify max and min
                    test $SELECTED -lt 0 && SELECTED=0
                    test `expr $SELECTED + 1` -ge $TOTAL && SELECTED=`expr $TOTAL - 1`
                    
                    # update the menu (1.2.2.2)
                    test $SELECTED -ge 0 && _prjk_select $SELECTED 
                    ;;

                # if enter pressed, stop while and use current
                # SELECTED value
                $ENTER)
                    break 
                    ;;

                # other key? cancel while and stop subshel
                *)
                    SELECTED=-1
                    break 
                    ;;
            esac
        done

        # save the value to the temporary file
        # this is the only way I found to share
        # variables with subshell
        echo $SELECTED > $tmpf
    )
    
    # read the value of the temp file and remove it
    local selected=`cat $tmpf`
    rm $tmpf

    # leave the fullscreen mode (1.2.2.3)
    _prjk_leave
    
    # check if $selected is empty (exitted) 
    # or different -1 (cancelled)
    if test ! -z $selected && test $selected -ge 0; then
        # go (1.2.3)
        _prjk_cd "$1/${LIST[$selected]}" 
    else 
        # cancel and unset (1.4)
        echo "cancel"
        _prjk_unset
    fi
}



#       1.2.2.1
#       PREPARE MENU MODE

_prjk_fullscreen() {
    # hide cursor
    tput civis

    # avoid echo
    stty -echo
}



#       1.2.2.2
#       SHOW THE MENU OPTIONS

_prjk_select() { 
    local n=0

    # loop the list
    for folder in ${LIST[@]}; do
        # check if selected (passed as argument) 
        if test $n -eq $1; then
            # print a green √ and the folder's name in white
            printf "  \033[32m√\033[0m $folder\033[0m\n"
        else
            # print only the folder's name in gray
            printf "    \033[90m$folder\033[0m\n"
        fi

        # n++
        n=`expr $n + 1`
    done
    
    # move the cursor to the top of the list
    # to print all the list over in the next
    # keyboard interaction
    tput cuu $TOTAL
}



#       1.2.2.3
#       LEAVE MENU MODE

_prjk_leave() {
    # move cursor down the number of positions
    # of the filtered list
    tput cud $TOTAL

    # show cursor
    tput cnorm

    # allow echo
    stty echo 
}



#   1.2.3
#   GO TO THE FOLDER

_prjk_cd() {
    #unset the functions and variables to the current section (1.4)
    _prjk_unset

    # make the "cd" command and print the output
    echo "cd $1"
    cd "$1" 
}



# 1.3
# SHOW HELP

_prjk_help() {
    # show help string
    cat <<-EOF

  Usage: . prjk [COMMAND] [args]

  Commands:
    . prjk alias <name> <folder>     Configure an alias with the specific folder
    . prjk find <folder> <search>    The command called by the alias. Makes the search
                                     on folder and show a options menu if necessary
    prjk help                        Display help information

EOF

    # unset the functions and variables to the current section (1.4)
    _prjk_unset
}



# 1.4
# UNSET FUNCIONS AND VARIABLES
# clean the current section 

_prjk_unset() {
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



# -------------------------



# 1.
# HANDLE ARGUMENTS

# verify if more then 0 arguments
if test $# -gt 0; then
    case $1 in
        create|alias) _prjk_alias $2 $3 ;; # 1.1
        go|find) _prjk_find $2 $3 ;;       # 1.2
        help) _prjk_help ;;                # 1.3
        *) _prjk_unset ;;                  # 1.4
    esac
fi 
