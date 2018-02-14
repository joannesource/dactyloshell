#!/bin/bash
bash dependencies.sh

CURL_HEADER="Authorization: token"
GITHUB_USER=""

choice()
{
    select choice in "$@"; do if [[ "$choice" || "$choise" -eq 0 ]]; then echo "$choice"; break; fi; done
}

function open_gist()
{
	if [[ "$1" == "http://"* ]]; then
		gist_return=$(curl -H "$CURL_HEADER" -sS "$1")
	else
		gist_return=$(curl -H "$CURL_HEADER" -sS https://api.github.com/gists/$1)
	fi
	#gist_files=$(echo "$gist_return" | jq '.files|keys|.|join("|")' -r)
	gist_files=$(echo "$gist_return" | jq '.files[]|select(.filename|endswith(".sh")).filename' -r)
        if [[ -z $gist_files ]]; then
                echo "No valid files."
                break
        fi
	echo -e "\nChose a file or 0 to abort : "
	IFS=$'\n'
	chosen=$(choice $gist_files)
	if [[ -z $chosen ]]; then
		echo "Aborted."
		break
	fi
	echo -e "Selected File: $chosen\n\n"


	# Execute content
	file_content=$(echo "$gist_return" | jq '.files["'$chosen'"]|.content' -r)
	echo "$file_content"
	echo -e "Executing : $file_content\n<<<\n"
	eval "$file_content"
	echo -e "\n\n>>>"
	break
}

function gist_browser()
{

	# List Gists for user
	gists_return=$(curl -H "$CURL_HEADER" -sS https://api.github.com/users/"$GITHUB_USER"/gists)
	gists=$(echo "$gists_return" | jq '.[].description' -r)
	ids=$(echo "$gists_return" | jq '.[].id' -r)

	while true; do
	  IFS=$'\n'

	  while true; do
	    # Chose a gist
	    echo -e "\nChose a Gist : "
	    chosen=$(choice $gists)
	    if [[ -z $chosen ]]; then
			continue
	    fi
	    index=$(echo "$gists"|grep -nr "$chosen" -|head -1|cut -d: -f1)
	    id=$(echo "$ids" | sed "$index"'q;d')
	    if [[ ! -z id ]]; then
			echo -e "Selected Gist: $chosen ($id)\n\n"
			break
	    fi
	  done

	  # Chose a file
	  while true; do
		open_gist $id
	  done
	done
}

function boot()
{
	RCFILE=~/.dactyloshellrc
	if [ ! -f $RCFILE ]; then
		echo "No Gist OAUTH configured!"
		read -p "Please input your GitHub OAUTH personal access token: " token
		echo "github_token=\"$token\"" > $RCFILE

		read -p "Please input your GitHub username " user
		echo "GITHUB_USER=\"$user\"" >>  $RCFILE
	fi
	. $RCFILE
	CURL_HEADER="$CURL_HEADER $github_token"
	echo $CURL_HEADER
}

boot

if [[ -z $1 ]]; then
	gist_browser
else
	open_gist $1
fi
