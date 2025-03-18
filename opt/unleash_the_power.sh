#!/bin/zsh

#if [ ! -w /sys/devices/system/cpu1/online ]; then
#	sudo -- "$0" "$@"
#fi
echo 1 >/sys/fs/cgroup/blocker/cgroup.kill
rmdir /sys/fs/cgroup/blocker

cd /sys/devices/system/cpu/
for f in cpu*; do
	pushd "$f" >/dev/null \
		&& echo 1 >online 2>/dev/null || :
	popd >/dev/null
done

echo 0 >/sys/devices/system/cpu/intel_pstate/no_turbo

cd /sys/devices/system/cpu/cpufreq/

for f in *; do
	pushd "$f" >/dev/null \
		&& (cat cpuinfo_max_freq >scaling_max_freq; echo balance_power >energy_performance_preference)
	popd >/dev/null
done

echo 0 >/sys/devices/system/cpu/intel_pstate/no_turbo

