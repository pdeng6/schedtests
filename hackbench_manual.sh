#!/bin/bash -x

hackbench_num_fds=$(($(nproc) / 8))

group=1

# process | thread
worker_type=process

loops=300000

size=100

# sockets: ""
# pipe: "--pipe"
ipc="--pipe"


cmd="hackbench -g ${group} --${worker_type} ${ipc} -l ${loops} -s ${size} -f $hackbench_num_fds"

echo 0 | sudo tee /proc/sys/kernel/sched_autogroup_enabled

echo 0 | sudo tee /proc/sys/kernel/sched_exp_last_idle_cpu

for i in {1..3}
do
    $cmd
    sleep 3
done

sleep 10

echo 1 | sudo tee /proc/sys/kernel/sched_exp_last_idle_cpu
for i in {1..3}
do
    $cmd
    sleep 3
done

echo 0 | sudo tee /proc/sys/kernel/sched_exp_last_idle_cpu
