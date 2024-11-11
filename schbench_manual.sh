#!/bin/bash -x

# message thread# 1 2 4 8
num_msg_thread=8

num_worker_thread_per_msg_thread=$(($(nproc) / 4))

schbench_run_time=10
schbench_log_path=schbench_log
iteration_interval=10

log_file=schbench_${schbench_run_time}s_${num_msg_thread}.log
score_file=schbench_${schbench_run_time}s_${num_msg_thread}.score

schbench_old_pattern="99.0000th"
schbench_pattern="99.0th"
schbench_pattern2="Latency percentiles (usec) runtime $schbench_run_time (s)"

run_schbench_pre()
{
    mkdir $schbench_log_path
	rm -rf $schbench_log_path/$log_file
	rm -rf $schbench_log_path/$score_file
    touch $schbench_log_path/$log_file
}

run_schbench_single()
{
    for i in {1..3}
    do
        schbench -m $num_msg_thread -t $num_worker_thread_per_msg_thread -r $schbench_run_time
		sleep $iteration_interval
    done
}

run_schbench_post()
{

    if grep -q $schbench_old_pattern $schbench_log_path/$log_file; then
    	schbench_pattern=$schbench_old_pattern
    fi
    cat $schbench_log_path/$log_file | grep -e "$schbench_pattern2" -e "$schbench_pattern" | grep -A 1 "$schbench_pattern2" | grep \
    	"$schbench_pattern" | awk '{print $2}' > $schbench_log_path/$score_file
	cat $schbench_log_path/$score_file | awk '{sum+=$1} END {print "count:", NR ", Average P99 Latency(usec LIB):", sum/NR}'
}

run_schbench_pre

run_schbench_single &>>$schbench_log_path/$log_file

run_schbench_post