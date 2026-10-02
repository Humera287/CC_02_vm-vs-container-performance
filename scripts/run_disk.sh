#!/bin/bash

echo "Running Disk I/O Benchmark..."

fio --name=sequential-read \
    --filename=testfile \
    --size=1G \
    --rw=read \
    --bs=1M \
    --direct=1 \
    --runtime=30 \
    --time_based

fio --name=sequential-write \
    --filename=testfile \
    --size=1G \
    --rw=write \
    --bs=1M \
    --direct=1 \
    --runtime=30 \
    --time_based

fio --name=random-read \
    --filename=testfile \
    --size=1G \
    --rw=randread \
    --bs=4k \
    --direct=1 \
    --runtime=30 \
    --time_based

fio --name=random-write \
    --filename=testfile \
    --size=1G \
    --rw=randwrite \
    --bs=4k \
    --direct=1 \
    --runtime=30 \
    --time_based

rm -f testfile
