#!/bin/zsh

cd /sys/devices/system/cpu/cpufreq/

	#  0-11 -> P-Cores
	# 12-19 -> E-Cores
	# 20-21 -> LPE-Cores
	#for f in policy{0..20}; do
	#for f in policy{0..17}; do
for f in policy{0..11}; do
	pushd "$f" >/dev/null \
		&& cat cpuinfo_min_freq >scaling_max_freq
	popd >/dev/null
done
for f in policy{0..21}; do
	pushd "$f" >/dev/null \
		&& echo power >energy_performance_preference
	popd >/dev/null
done

#echo 1 >/sys/devices/system/cpu/intel_pstate/no_turbo

cd /sys/devices/system/cpu/
#for f in cpu{1..11}; do
#for f in cpu{1..17}; do
#for f in cpu{1..20}; do
#	pushd "$f" >/dev/null \
#		&& echo 0 >online
#	popd >/dev/null
#done

mkdir -p /sys/fs/cgroup/blocker
echo '1' >/sys/fs/cgroup/blocker/cgroup.kill
echo '0-11' >/sys/fs/cgroup/blocker/cpuset.cpus
echo 'root' >/sys/fs/cgroup/blocker/cpuset.cpus.partition
echo $$ >/sys/fs/cgroup/blocker/cgroup.procs
sleep infinity &
disown
