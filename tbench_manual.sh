#!/bin/bash -x

min_job=$(($(nproc) / 4))

# min_job * 1..8
num_thread=$(($min_job * 4))

tbench_host_ip=127.0.0.1
tbench_run_time=10
tbench_log_path=tbench_log
iteration_interval=10

log_file=tbench_${tbench_run_time}s_${num_thread}.log
score_file=tbench_${tbench_run_time}s_${num_thread}.score
tbench_pattern_cmd="grep Throughput"

run_tbench_pre()
{
	echo "start tbench server"
	pgrep tbench_srv && killall tbench_srv
	sleep 1
	tbench_srv &> /dev/null &
	if [ $? -ne 0 ]; then
		echo "[schedtests]: tbench server not found or version not compatible"
		exit 1
	fi
	sleep 1
    mkdir $tbench_log_path
	rm -rf $tbench_log_path/$log_file
	rm -rf $tbench_log_path/$score_file
    touch $tbench_log_path/$log_file
}

run_tbench_single()
{
    for i in {1..3}
    do
        tbench -t $tbench_run_time $num_thread $tbench_host_ip
		sleep $iteration_interval
    done
}

run_tbench_post()
{
	cat $tbench_log_path/$log_file | $tbench_pattern_cmd | awk '{print $2}' > $tbench_log_path/$score_file
	cat $tbench_log_path/$score_file | awk '{sum+=$1} END {print "count:", NR ", Average Throughput(MB/s HIB):", sum/NR}'
}

run_tbench_pre

run_tbench_single >>$tbench_log_path/$log_file

run_tbench_post