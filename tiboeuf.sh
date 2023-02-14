#!/usr/bin/env bash
# shellcheck disable=SC2002
# tiboeuf

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

array_radio_url() {
mapfile -t lst_radio_url < <( cat "$radio_db_path" | awk -F'|' '{print $NF}' | column -t )
}

radio_choice() {
cat "$radio_db_path" | column -s $'|' -t | nl -v 0

while :; do
	read -r -e -p "-> " radio

	if [[ "$radio" =~ ^[0-9]+$ ]]; then

		# Test result with db
		for i in "${!lst_radio_url[@]}"; do
			if [[ "$i" = "$radio" ]]; then
				valid_number="1"
			fi
		done
		# Result
		if [[ "$valid_number" = "1" ]]; then
			"$mpv_bin" "${lst_radio_url[$radio]}" --display-tags=icy-title
		else
			echo "This radio is not in list."
		fi
		# Reset test
		unset valid_number

	else
		echo "Enter an integer."
	fi

done
}

export PATH=$PATH:/home/$USER/.local/bin
tiboeuf_path="$( cd "$( dirname "$0" )" && pwd )"
radio_db_path="${tiboeuf_path}/radio.db"

mpv_bin
radio_db_test

array_radio_url
radio_choice
