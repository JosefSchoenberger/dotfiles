#!/bin/sh

pull_outputs() {
	OUTPUTS="$(swaymsg -t get_outputs -r | jq 'map(.name)')"
}
pull_workspaces() {
	WORKSPACES="$(swaymsg -t get_workspaces -r)"
}

pull_outputs
pull_workspaces

while true; do
	# Wait for screen list to change
	PREV_OUTPUTS="$OUTPUTS"
	PREV_WORKSPACES="$WORKSPACES"
	swaymsg -t subscribe '["output","workspace"]' >/dev/null 2>&1
	pull_outputs
	pull_workspaces

	NEW_SCREENS="$(echo "[$PREV_OUTPUTS, $OUTPUTS]" | jq '(.[1] - .[0]).[]' -r)"

	for SCREEN in $NEW_SCREENS; do
		echo "new screen: $SCREEN"
		for workspace in $(echo $WORKSPACES | jq '.[] | select(.output == "'"$SCREEN"'") | .num'); do
			PREV_OUTPUT="$(echo $PREV_WORKSPACES | jq ".[] | select(.num == $workspace) | .output" -r)"
			echo " -> workspace on screen: $workspace (was on $PREV_OUTPUT), moving back..."
			swaymsg "workspace number $workspace, move workspace to output $PREV_OUTPUT, workspace number $workspace" # currently requires workspace_auto_back_and_forth
		done
	done
done
