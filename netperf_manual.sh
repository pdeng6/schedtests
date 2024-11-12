#!/bin/bash -x

: ${min_job:=$(($(nproc) / 4))}

# min_job * 1..8
: ${num_thread:=$(($min_job * 2))}

# TCP_RR UDP_RR
: ${netperf_work_mode:="UDP_RR"}

netperf_host_ip=127.0.0.1
netperf_run_time=10
netperf_log_path=netperf_log
iteration_interval=10

log_file=netperf_${netperf_work_mode}_${num_thread}.log
score_file=netperf_${netperf_work_mode}_${num_thread}.score
netperf_pattern_cmd="grep $netperf_run_time\.00"

run_netperf_pre()
{
	echo "start netperf server"
	pgrep netserver && killall netserver
	sleep 1
	netserver &> /dev/null
	if [ $? -ne 0 ]; then
		echo "[schedtests]: netperf server not found or version not compatible"
		exit 1
	fi
	sleep 1

    mkdir $netperf_log_path
	rm -rf $netperf_log_path/$log_file
	rm -rf $netperf_log_path/$score_file
    touch $netperf_log_path/$log_file

}

run_netperf_single()
{
    for i in {1..3}
    do
        for i in $(seq 1 $num_thread); do
            netperf -4 -H $netperf_host_ip -t $netperf_work_mode -c -C -l $netperf_run_time &
        done
        wait
		sleep $iteration_interval
    done
}

run_netperf_post()
{
	cat $netperf_log_path/$log_file | $netperf_pattern_cmd | awk '{print $6}' > $netperf_log_path/$score_file
	cat $netperf_log_path/$score_file | awk '{sum+=$1} END {print "count:", NR ", Average TRS(HIB):", sum/NR}'
}

run_netperf_pre

run_netperf_single >>$netperf_log_path/$log_file

run_netperf_post