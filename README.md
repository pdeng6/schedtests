# schedtests

A lightweight benchmarking framework primarily aimed at Linux kernel scheduler
testing. It provides a reasonable coverage within one night, to compare the
difference between a baseline kernel and a testing kernel.

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
