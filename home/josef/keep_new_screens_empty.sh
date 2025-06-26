#!/bin/sh

pull_outputs() {
	OUTPUTS="$(swaymsg -t get_outputs -r | jq 'map(.name)')"
}
pull_workspaces() {
	WORKSPACES="$(swaymsg -t get_workspaces -r)"
}
pull_focused_workspace() {
	FOCUSED_WORKSPACE="$(swaymsg -t get_workspaces -r | jq '.[] | select(.focused).num')"
}

pull_outputs
pull_workspaces
#pull_focused_workspace

while true; do
	# Wait for screen list to change
	PREV_OUTPUTS="$OUTPUTS"
	PREV_WORKSPACES="$WORKSPACES"
	#PREV_FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE"
	swaymsg -t subscribe '["output","workspace"]' >/dev/null 2>&1
	pull_outputs
	pull_workspaces
	pull_focused_workspace

	NEW_SCREENS="$(echo "[$PREV_OUTPUTS, $OUTPUTS]" | jq '(.[1] - .[0]).[]' -r)"

	for SCREEN in $NEW_SCREENS; do
		echo "new screen: $SCREEN"
		for workspace in $(echo $WORKSPACES | jq '.[] | select(.output == "'"$SCREEN"'") | .num'); do
			PREV_OUTPUT="$(echo $PREV_WORKSPACES | jq ".[] | select(.num == $workspace) | .output" -r)"
			echo " -> workspace on screen: $workspace (was on $PREV_OUTPUT), moving back..."
			if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
				swaymsg "move workspace to output $PREV_OUTPUT"
			else
				swaymsg "workspace number $workspace, move workspace to output $PREV_OUTPUT, workspace number $FOCUSED_WORKSPACE"
			fi
		done
	done
done
