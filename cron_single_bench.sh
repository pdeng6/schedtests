#!/bin/sh
rela_path=`dirname $0`
test_path=`cd "$rela_path" && pwd`
run_name=`uname -r`
task_list="hackbench netperf tbench schbench"
task_list="hackbench"
email_address="pan.deng@intel.com"
reboot_cmd="sudo systemctl reboot"

task_notify()
{
	local task=$1
	local status=$2
	if [ -z "$email_address" ]; then
		return
	fi

	if [ $status = "started" ]; then
		echo "Time:" $(date '+%F %T') "\nKernel:" `uname -r` "\nMachine:" `hostname` | \
			mutt -s "[schedtests]: $task $status" $email_address
	elif [ $task = "Testing" ]; then
		{
		echo "Time:" $(date '+%F %T') "\nKernel:" `uname -r` "\nMachine:" `hostname`
		./report.py --baseline $run_name
		} | mutt -s "[schedtests]: $task $status" $email_address
	else
		{
		echo "Time:" $(date '+%F %T') "\nKernel:" `uname -r` "\nMachine:" `hostname`
		./report.py --testname $task --baseline $run_name
		} | mutt -s "[schedtests]: $task $status" $email_address -a cron.log
	fi
}

#wait for the system boots up completely
sudo systemctl stop tuned
sudo pkill BESClient
sleep 30
echo 0 | sudo tee /proc/sys/kernel/sched_autogroup_enabled

cd $test_path
touch state_machine

for task in $task_list; do
	if [ `grep -c $task state_machine` -eq '0' ]; then
		#task_notify $task "started"
		./run-schedtests.sh $task >> cron.log 2>&1
		#task_notify $task "completed"
		echo "$task" >> state_machine
		# wait for the notification sent out
		sleep 10
		mv logs logs_ref
		$reboot_cmd
		exit
	elif [ `grep -c $task state_machine` -eq '1' ]; then
		echo 1 | sudo tee /proc/sys/kernel/sched_exp_last_idle_cpu
		#task_notify $task "started"
		./run-schedtests.sh $task >> cron.log 2>&1
		#task_notify $task "completed"
		echo "$task" >> state_machine
		# wait for the notification sent out
		sleep 10
		mv logs logs_opt
		$reboot_cmd
		exit
	fi
done

#task_notify "Testing" "completed"
