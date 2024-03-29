# 
# NOTE: I wouldn't recommend adding new variables (or anything) here
# 
# (but the existing vars can be changed, and you can add custom logic with settings/extensions/YOUR_THING/#initialize.sh)


# 
# find this file
# 
path_to_file=""
file_name="settings/projectr_core"
folder_to_look_in="$PWD"
while :
do
    # check if file exists
    if [ -f "$folder_to_look_in/$file_name" ]
    then
        path_to_file="$folder_to_look_in/$file_name"
        break
    else
        if [ "$folder_to_look_in" = "/" ]
        then
            break
        else
            folder_to_look_in="$(dirname "$folder_to_look_in")"
        fi
    fi
done
if [ -z "$path_to_file" ]
then
    #
    # what to do if file never found
    #
    echo "Im a script running with a pwd of:$PWD"
    echo "Im looking for settings/projectr_core in a parent folder"
    echo "Im exiting now because I wasnt able to find it"
    echo "thats all the information I have"
    exit
fi

# 
# set main vars
# 
export PROJECTR_FOLDER="$(dirname "$(dirname "$path_to_file")")"
export PROJECTR_HOME="$PROJECTR_FOLDER/settings/home/"
export PROJECTR_COMMANDS_FOLDER="$PROJECTR_FOLDER/commands/"
export DEBUG_PROJECTR="false"

# 
# run the setup for each of the extensions (if the flag it not set)
# 
if ! [ "$PROJECTR_NEXT_RUN_ONLY_DO_BASIC_INIT" = "true" ]
then
    # this loop is so stupidly complicated because of many inherent-to-shell reasons, for example: https://stackoverflow.com/questions/13726764/while-loop-subshell-dilemma-in-bash
    for_each_item_in="$PROJECTR_FOLDER/settings/extensions"; [ -z "$__NESTED_WHILE_COUNTER" ] && __NESTED_WHILE_COUNTER=0;__NESTED_WHILE_COUNTER="$((__NESTED_WHILE_COUNTER + 1))"; trap 'rm -rf "$__temp_var__temp_folder"' EXIT; __temp_var__temp_folder="$(mktemp -d)"; mkfifo "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER"; (find "$for_each_item_in" -maxdepth 1 ! -path . -print0 2>/dev/null | sort -z > "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER" &); while read -d $'\0' each
    do
        # check if file exists
        if [ -f "$each/#initialize.sh" ]
        then
            if [ "$DEBUG_PROJECTR" = "true" ]
            then
                echo "loading: $each/#initialize.sh"
            fi
            # tell the scripts what file they're inside of
            export __THIS_PROJECTR_EXTENSION_FILEPATH__="$each/#initialize.sh"
            export __THIS_PROJECTR_EXTENSION_FOLDERPATH__="$each"
            source "$each/#initialize.sh"
        fi
    done < "$__temp_var__temp_folder/pipe_for_while_$__NESTED_WHILE_COUNTER";__NESTED_WHILE_COUNTER="$((__NESTED_WHILE_COUNTER - 1))"
fi
# reset basic init
PROJECTR_NEXT_RUN_ONLY_DO_BASIC_INIT=""

