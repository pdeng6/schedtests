#!/bin/bash

./pepc_config.sh
echo 1 | sudo tee /proc/sys/kernel/sched_exp_last_idle_cpu

# ICX 80..240
BASE=80

for index in {0..20}
do
	offset=$(($index * 8))
	num_thread=$(($offset + $BASE))
	netperf_work_mode=TCP_RR
	. ./netperf_manual.sh
done
