#!/bin/bash

echo "Running Network Benchmark..."

iperf3 -c 192.168.1.105 -t 30

iperf3 -c 192.168.1.105 -t 30 -P 4
