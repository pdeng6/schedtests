#!/bin/bash -x

sudo yum install realtime-tests netperf dbench pepc
sudo ln -s /usr/bin/pepc /usr/bin/pepc.standalone

git clone https://git.kernel.org/pub/scm/linux/kernel/git/mason/schbench.git
cd schbench
git checkout -b schedtests e4aa540e1d709eeccbbb89686571fecca960d127
make && sudo cp ./schbench /usr/bin/

pip3 install numpy pandas

