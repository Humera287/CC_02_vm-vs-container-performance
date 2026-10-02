#!/bin/bash

echo "Running Memory Benchmark..."

sysbench memory \
  --memory-block-size=1M \
  --memory-total-size=10G \
  --threads=4 \
  run
