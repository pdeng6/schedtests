# schedtests

A lightweight benchmarking framework primarily aimed at Linux kernel scheduler
testing. It provides a reasonable coverage within one night time, to compare
the difference between a baseline kernel and a testing kernel.

## Basic Installation

### schedtests includes 4 benchmarks:
- hackbench (apt install rt-tests)
- netperf (apt install netperf)
- tbench (apt install dbench)
- schbench (https://git.kernel.org/pub/scm/linux/kernel/git/mason/schbench.git)

Note, schbench is expected to be installed at /usr/bin.

### result process and report:
- python3 (apt install python3.x)
- numpy (pip3 install numpy)
- pandas (pip3 install pandas)

### [optional] email notification:
- mutt (apt install mutt)
- msmtp (apt install msmtp)

mutt and msmtp is expected to be properly configured.

## Configuration

There are 3 global variables to configure:
- joblist: load levels of a benchmark case
- runtime: how long to run a benchmark case before exiting
- iterations: how many times to run a benchmark case

The job list is specified by [50% 100% 200%] number of CPUs in the
system by default, This list is not accurately mapped to the system
utilization and can be adjusted individually for benchmarks.
For example:
- hackbench_job_list="2 3 4" #number of send/recv groups
- schbench_jost_list="2 4 8" #number of message threads

Ususally, runtime >= 100seconds andn iterations >= 10 is the compliant
setting for the valid result.

## Invocation

It is recommended to run the script as root to avoid unexpected issues.

Run all benchmarks in one time:
- #./run-schedtests.sh

Run one benchmark in one time:
- #./run-schedtests.sh hackbench

The global variable $run_name is assigned to the kernel release
string by default.

## Automation

To eliminate the interaction between different benchmarks, it is recommended
to restart the system between two benchmarks.

Place cron.sh into "crontab -e" as follows:

	@reboot /home/aubrey/work/schedtests/cron.sh

It will run at boot time and automatically run all benchmarks, system restart
between the two benchmarks is done by kexec by default.

Optionally, if the variable $email_address is set, cron.sh will send out the
automation progress notification.

## Report

Once the testing has completed both on the baseline kernel and the compared
kernel, the report is generated by:

### raw data of a single benchmark

	#./report.py --testname tbench --baseline v5.11.0-rc6
	tbench
	==========
	case            	load    	      Tput/s	    std%
	loopback        	thread-48	    12116.09	(  0.53)
	loopback        	thread-96	    21213.47	(  0.50)
	loopback        	thread-144	    15677.74	(  0.72)
	loopback        	thread-192	    13294.49	(  0.59)

### data comparison of a single benchmark

	#./report.py --testname tbench --baseline v5.11.0-rc6 --compare v5.11.0-rc6-icmv8
	tbench
	==========
	case            	load    	baseline(std%)	compare%( std%)
	loopback        	thread-48	 1.00 (  0.53)	 -1.13 (  0.70)
	loopback        	thread-96	 1.00 (  0.50)	 -7.01 (  0.52)
	loopback        	thread-144	 1.00 (  0.72)	 +1.13 (  0.68)
	loopback        	thread-192	 1.00 (  0.59)	 +0.26 (  0.33)

### a complete report includes all benchmarks

	#./report.py --baseline v5.11.0-rc6 --compare v5.11.0-rc6-icmv8

	hackbench
	==========
	case            	load    	baseline(std%)	compare%( std%)
	process-pipe    	group-3 	 1.00 ( 22.52)	 +6.81 ( 28.71)
	process-pipe    	group-6 	 1.00 ( 10.75)	 -1.75 ( 11.13)
	process-pipe    	group-9 	 1.00 (  4.32)	 +1.45 (  7.91)
	process-pipe    	group-12	 1.00 (  2.03)	 -2.95 (  1.90)
	process-sockets 	group-3 	 1.00 (  3.12)	 -0.17 (  3.69)
	process-sockets 	group-6 	 1.00 (  0.83)	 -4.97 (  0.95)
	process-sockets 	group-9 	 1.00 (  0.55)	 -4.10 (  0.67)
	process-sockets 	group-12	 1.00 (  0.40)	 -4.23 (  0.50)
	threads-pipe    	group-3 	 1.00 ( 13.03)	 -7.77 ( 17.38)
	threads-pipe    	group-6 	 1.00 (  5.41)	 -2.45 (  6.73)
	threads-pipe    	group-9 	 1.00 (  6.02)	 -3.65 (  3.47)
	threads-pipe    	group-12	 1.00 (  1.33)	 -2.99 (  0.96)
	threads-sockets 	group-3 	 1.00 (  3.54)	 -0.38 (  1.60)
	threads-sockets 	group-6 	 1.00 (  1.60)	 -1.48 (  1.50)
	threads-sockets 	group-9 	 1.00 (  0.97)	 -3.91 (  0.81)
	threads-sockets 	group-12	 1.00 (  0.74)	 -3.80 (  0.49)

	netperf
	==========
	case            	load    	baseline(std%)	compare%( std%)
	TCP_RR          	thread-48	 1.00 (  6.95)	 -0.86 (  5.43)
	TCP_RR          	thread-96	 1.00 (  5.80)	 +3.04 (  7.11)
	TCP_RR          	thread-144	 1.00 (  6.69)	 +0.39 (  7.37)
	TCP_RR          	thread-192	 1.00 (  6.12)	 -0.16 (  8.04)
	UDP_RR          	thread-48	 1.00 (  6.39)	 -2.04 (  9.16)
	UDP_RR          	thread-96	 1.00 ( 10.35)	 +0.78 (  8.76)
	UDP_RR          	thread-144	 1.00 ( 28.18)	 -0.33 ( 27.92)
	UDP_RR          	thread-192	 1.00 ( 21.23)	 +1.73 ( 28.87)

	tbench
	==========
	case            	load    	baseline(std%)	compare%( std%)
	loopback        	thread-48	 1.00 (  0.53)	 -1.13 (  0.70)
	loopback        	thread-96	 1.00 (  0.50)	 -7.01 (  0.52)
	loopback        	thread-144	 1.00 (  0.72)	 +1.13 (  0.68)
	loopback        	thread-192	 1.00 (  0.59)	 +0.26 (  0.33)

	schbench
	==========
	case            	load    	baseline(std%)	compare%( std%)
	normal          	mthread-3	 1.00 ( 14.34)	 -5.78 (  6.92)
	normal          	mthread-6	 1.00 ( 27.58)	 +2.40 ( 39.29)
	normal          	mthread-9	 1.00 (  2.75)	 +5.50 (  4.45)
	normal          	mthread-12	 1.00 (  8.02)	 -2.61 (  7.39)
