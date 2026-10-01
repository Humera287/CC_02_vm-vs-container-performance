#!/bin/bash

echo "Starting VM benchmark..."

echo "=============================="
echo "CPU Benchmark"
echo "=============================="

for threads in 1 2 4 8
do
    echo "Running CPU test with $threads threads"

    sysbench cpu \
        --cpu-max-prime=20000 \
        --threads=$threads \
        --time=30 \
        run
done

echo "=============================="
echo "Memory Benchmark"
echo "=============================="

sysbench memory \
    --memory-block-size=1M \
    --memory-total-size=10G \
    --threads=4 \
    run

echo "=============================="
echo "VM benchmark completed."
echo "=============================="
