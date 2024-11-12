#!/bin/bash

sudo pepc.standalone pstates config --governor performance
sudo pepc.standalone pstates config --turbo off
sudo pepc.standalone cstates config --disable C6
echo 1 | sudo tee /proc/sys/kernel/numa_balancing
