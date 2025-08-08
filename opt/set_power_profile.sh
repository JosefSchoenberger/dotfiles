#!/bin/bash

if [ "$#" != 1 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Usage: $0 [ save | normal | performance | bench ]" >&2
	[ "$#" = 1 ]; exit
fi

if [ "$1" != "save" ] && [ "$1" != "normal" ] && [ "$1" != "performance" ] && [ "$1" != "bench" ]; then
	echo "Error: argument must be one of: save, normal, performance, bench" >&2
	exit 1
fi

if [ "$(id -u)" != 0 ]; then
	echo "Error: Not privilged.\nPlease run as root" >&2
	exit 1
fi


# Core frequency

set_max_freq_for_core() {
	# $1 -> core number
	# $2 -> freq in kHz or string "min" or "max"
	cd "/sys/devices/system/cpu/cpufreq/policy$1" || return
	MAX_FREQ="$2"
	if [ "$MAX_FREQ" = "max" ]; then
		MAX_FREQ="$(cat cpuinfo_max_freq)"
	elif [ "$MAX_FREQ" = "min" ]; then
		MAX_FREQ="$(cat cpuinfo_min_freq)"
	fi
	echo "$MAX_FREQ" >scaling_max_freq || echo "WARN: Could not set max freq of core $1 to $2 ($MAX_FREQ kHz)"
}

if [ "$1" = "save" ]; then
	# Limit P-cores to min freq (they will be blocked anyway, just deal with interrupts etc. as efficiently as possible)
	for c in {0..11}; do
		set_max_freq_for_core "$c" min
	done
	for c in {12..21}; do
		#set_max_freq_for_core "$c" max
		set_max_freq_for_core "$c" 1000000
	done
elif [ "$1" = "bench" ]; then
	for c in {6..11}; do
		set_max_freq_for_core "$c" max
	done
	# Limit other cores to somewhat low performance to prevent them from heating the system and throtteling the bench cores
	for c in {0..5}; do
		set_max_freq_for_core "$c" 2600000
	done
	for c in {12..19}; do
		set_max_freq_for_core "$c" 2600000
	done
	for c in {20..21}; do
		set_max_freq_for_core "$c" max
	done
else
	for c in {0..21}; do
		set_max_freq_for_core "$c" max
	done
fi 


set_governor_for_core() {
	# $1 -> core number
	# $2 -> governor
	cd "/sys/devices/system/cpu/cpufreq/policy$1" || return
	echo "$2" >scaling_governor || echo "WARN: Could not set scaling governor for core $1 to $2" >&2
}

if [ "$1" = "performance" ]; then
	for c in {0..21}; do
		set_governor_for_core "$c" "performance"
	done
elif [ "$1" = "bench" ]; then
	for c in {0..5}; do
		set_governor_for_core "$c" "powersave"
	done
	for c in {6..11}; do
		set_governor_for_core "$c" "performance"
	done
	for c in {12..21}; do
		set_governor_for_core "$c" "powersave"
	done
else
	for c in {0..21}; do
		set_governor_for_core "$c" "powersave"
	done
fi


# Energy Performance Preference

set_epp_for_core() {
	# $1 -> core number
	# $2 -> EPP (string like "power", "balance_power", etc. or number from 0 to 255)
	cd "/sys/devices/system/cpu/cpufreq/policy$1" || return

	# The EPP can not be set for the performance governor and would be ignored anyway
	[ "$(cat scaling_governor)" != performance ] && \
		(echo "$2" >energy_performance_preference || echo "WARN: Could not set EPP for core $1 to $2" >&2)
}

if [ "$1" = "save" ]; then
	for c in {0..21}; do
		set_epp_for_core "$c" power
	done
else
	# Note: the performance governor ignores the EPP, so this is only relevant for the normal setting, anyway.
	for c in {0..21}; do
		set_epp_for_core "$c" balance_power
	done
fi


# cgroup for reserving cores

kill_cgroup() {
	cd "/sys/fs/cgroup/" || return
	[ -d "$1" ] && (echo 1 >"$1/cgroup.kill" && rmdir "$1" || echo "WARN: Could not kill cgroup $1")
}

# Do not kill and recreate the bench cgroup to prevent processes from dying unnecessarily.
[ -d /sys/fs/cgroup/bench/ ] && [ "$1" = "bench" ] && exit 0

kill_cgroup blocker
kill_cgroup bench

if [ "$1" = "normal" ] || [ "$1" = "performance" ]; then
	exit 0
fi

cd /sys/fs/cgroup

if [ "$1" = "save" ]; then
	mkdir blocker || (echo "Error: Could not create blocker cgroup" >&2 ; exit )
	cd blocker
	echo '0-11' >cpuset.cpus || echo "Could not write '0-11' into blocker/cpuset.cpus" >&2
	echo 'root' >cpuset.cpus.partition || echo "Could not write 'root' into blocker/cpuset.cpus.partiton" >&2
	echo $$ >cgroup.procs
	sleep infinity &
	disown
else # bench
	mkdir bench || (echo "Error: Could not create bench cgroup" >&2 ; exit )
	cd bench
	echo '6-11' >cpuset.cpus
	echo 'root' >cpuset.cpus.partition
fi
