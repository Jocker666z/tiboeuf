#!/usr/bin/env bash
# shellcheck disable=SC2002
# tiboeuf

# Setup
mpv_bin() {
local bin_name
local system_bin_location

bin_name="mpv"
system_bin_location=$(command -v $bin_name)

if test -n "$system_bin_location"; then
	mpv_bin="$system_bin_location"
else
	echo "Break, $bin_name is not installed."
	exit
fi
}
radio_db_test() {
if ! [[ -f "$radio_db_path" ]]; then
	echo "Break, $radio_db_path file not exist."
	exit
fi
if [[ -f "$radio_db_path" ]] && [[ -z $(< "$radio_db_path") ]] ; then
	echo "Break, $radio_db_path file is empty."
	exit
fi
}

# Tools
echo_separator() {
tput dim
printf "%*s" "$term_width" "" | tr ' ' "-"; echo
tput sgr0
}
kill() {
stty sane
exit
}

# main
array_radio() {
# Title
mapfile -t lst_radio_title < <( cat "$radio_db_path" | awk -F'|' '{print $1}')
# URL
mapfile -t lst_radio_url < <( cat "$radio_db_path" | awk -F'|' '{print $NF}')
}
print_radio_list() {
tput bold sitm
echo "  < tiboeuf Radio List >"
tput sgr0
cat "$radio_db_path" | column -s $'|' -t | nl -v 0
}
radio_choice() {
while :; do
	read -r -e -p "  -> " radio

	if [[ "$radio" =~ ^[0-9]+$ ]]; then

		# Test result with db
		for i in "${!lst_radio_url[@]}"; do
			if [[ "$i" = "$radio" ]]; then
				valid_number="1"
			fi
		done
		# Result & play
		if [[ "$valid_number" = "1" ]]; then

			# Title
			echo_separator
			echo "Listen ${lst_radio_title[$radio]}: ${lst_radio_url[$radio]}"

			# Listen
			"$mpv_bin" "${lst_radio_url[$radio]}"

			# If quit
			echo_separator
			print_radio_list

		else
			echo "This radio number is not in list."
		fi
		# Reset test
		unset valid_number

	elif [[ "$radio" = "q" ]]; then
		echo "Goodbye Space Cowboy."
		exit
	else
		echo "Enter an integer."

	fi

done
}

trap 'kill' SIGINT
export PATH=$PATH:/home/$USER/.local/bin
term_width=$(stty size | awk '{print $2}')
tiboeuf_path="$( cd "$( dirname "$0" )" && pwd )"
radio_db_path="${tiboeuf_path}/radio.db"

# Setup
mpv_bin
radio_db_test
# main
array_radio
print_radio_list
radio_choice
