# Experiment 2: Performance Analysis of Virtual Machines and Containers (Docker)

[![Environment](https://img.shields.io/badge/OS-Ubuntu%2022.04%20LTS-purple.svg)](#)
[![Docker](https://img.shields.io/badge/Container%20Engine-Docker%20CE-blue.svg)](#)
[![Status](https://img.shields.io/badge/Benchmark-Complete%20(Infra%20%2B%20FastAPI)-brightgreen.svg)](#)

---

## 1. Project Overview

This project compares the performance of a **Virtual Machine (VM)** and a **Docker Container** using CPU, memory, disk I/O, network, and FastAPI benchmarks.

The experiment measures performance, throughput, IOPS, latency, and resource usage.

---

## 2. Objectives

- Compare CPU and memory performance.
- Compare disk I/O and network performance.
- Compare FastAPI application performance.
- Analyze performance differences between VMs and containers.

---

## 3. VM vs Container

### Virtual Machine

A VM runs a complete guest operating system on virtualized hardware.

```text
Application
     ↓
Guest OS
     ↓
Virtual Hardware
     ↓
Hypervisor
     ↓
Host OS
     ↓
Physical Hardware
```

### Container

A container isolates applications while sharing the host OS kernel.

```bash
Application
     ↓
Container
     ↓
Host OS Kernel
     ↓
Physical Hardware
```

Containers generally require fewer resources because they do not need a separate guest operating system.

---

## 4. Experimental Setup

### VM

- Virtualization: Virtual Machine
- OS: Ubuntu
- CPU and RAM: According to the configured VM
- Storage: VM virtual disk

### Docker

- Container Technology: Docker
- Base Image: Ubuntu 24.04
- Benchmark Image: vm-container-benchmark
- FastAPI Image: performance-api

### Tools Used

Sysbench, FIO, iPerf3, Docker, ApacheBench, FastAPI, Uvicorn, Python, Git, and Linux monitoring tools.

---

## 5. Experimental Methodology

The same or equivalent workloads were executed in both environments.

### Step 1 — Prepare the Environment

Required tools were installed and verified.

```bash
sudo apt update

sudo apt install -y \
sysbench fio iperf3 htop iotop sysstat \
python3 python3-pip git
```

### Step 2 — Record System Information

```bash
lscpu
free -h
lsblk
df -h
uname -a
```

### Step 3 — Run CPU Benchmark

```bash
sysbench cpu \
--cpu-max-prime=20000 \
--threads=4 \
--time=30 run
```

CPU scalability was tested using 1, 2, 4 and 8 threads.

### Step 4 — Run Memory Benchmark

```bash
sysbench memory \
--memory-block-size=1M \
--memory-total-size=10G \
--threads=4 run
```

### Step 5 — Run Disk I/O Benchmark

FIO was used for sequential and random read/write workloads.

### Step 6 — Run Network Benchmark

```bash
iperf3 -c <SERVER-IP> -t 30
iperf3 -c <SERVER-IP> -t 30 -P 4
```

### Step 7 — Run FastAPI Benchmark

ApacheBench was used to test the /health, /compute, and /memory endpoints.

```bash
ab -n 10000 -c 100 http://127.0.0.1:8000/health
ab -n 1000 -c 10 http://127.0.0.1:8000/compute
ab -n 1000 -c 10 http://127.0.0.1:8000/memory
```

### Step 8 — Monitor Resources

```bash
htop
vmstat 1
docker stats
```

---

## 6. Docker Benchmark Image

A Docker image based on Ubuntu 24.04 was created with the required benchmarking tools.

```bash
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    sysbench fio iperf3 python3 python3-pip \
    procps sysstat && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /benchmark
```

Build and run:

```bash
docker build -t vm-container-benchmark -f docker/Dockerfile .
docker run --rm vm-container-benchmark
```

<img width="1666" height="890" alt="Docker_Success" src="https://github.com/user-attachments/assets/1c970700-1278-49f0-9a81-00b187b5bb04" />

---

## 7. CPU Performance Test

CPU performance was measured using Sysbench.

### CPU Results

| Threads | VM (Events/sec) | Docker (Events/sec) |
|---:|---:|---:|
| 1 | 515.84 | 517.19 |
| 2 | 883.55 | 894.38 |
| 4 | 928.17 | 900.45 |
| 8 | 905.17 | 914.42 |

### CPU Scalability

<img width="1044" height="635" alt="cpu_scalability" src="https://github.com/user-attachments/assets/ccabc1dd-39aa-4320-890e-f91db0a3b253" />

### Screenshot

<img width="1669" height="747" alt="Container_CPU_Run1" src="https://github.com/user-attachments/assets/a09a76a8-1fd7-46a4-80f1-e4809a0cc7b8" />

---

## 8. Memory Performance Test

Memory performance was measured using Sysbench.

### Memory Results

| Threads | VM (MiB/s) | Docker (MiB/s) |
|---:|---:|---:|
| 1 | 9541.97 | 5152.43 |
| 2 | 9880.38 | 6970.16 |

### Memory Performance

<img width="1046" height="632" alt="memory_performance" src="https://github.com/user-attachments/assets/71a6442e-d1c0-4b92-aa0e-b3e4f05f13a4" />

---

## 9. Disk I/O Performance

FIO was used to measure sequential and random disk performance.

### Disk Results

| Metric | VM | Docker |
|---|---:|---:|
| Sequential Read | 461 MiB/s | 500 MiB/s |
| Sequential Write | 358 MiB/s | 291 MiB/s |
| Random Read | 1313 IOPS | 1767 IOPS |
| Random Write | 1331 IOPS | 1346 IOPS |

### Disk I/O Performance

<img width="1047" height="631" alt="disk_io_performance" src="https://github.com/user-attachments/assets/bfc4a56d-2c8a-474e-ad82-1e63144852b4" />

---

## 10. Network Performance

Network performance was tested using iPerf3.

### Network Results

| Metric | VM | Docker |
|---|---:|---:|
| Sender | 14.1 Gbits/s | 13.7 Gbits/s |
| Receiver | 14.1 Gbits/s | 10.3 Gbits/s |
| TCP Retransmissions | 3 | 13 |

### Network Performance

<img width="1043" height="634" alt="network_performance" src="https://github.com/user-attachments/assets/c7312def-97c5-4f7e-a794-1c9d28f23790" />

### Screenshot

<img width="912" height="867" alt="Section_13_iperf3_Parallel" src="https://github.com/user-attachments/assets/94297d5c-f25e-4495-888e-cf985d301151" />

---

## 11. FastAPI Application Test

A FastAPI application with /health, /compute, and /memory endpoints was tested using ApacheBench.

### FastAPI Results

| Test | VM (req/s) | Docker (req/s) |
|---|---:|---:|
| Health | 419.79 | 371.07 |
| Compute | 12.24 | 10.76 |
| Memory | 16.43 | 14.40 |

All recorded tests completed with 0 failed requests.

### FastAPI Performance

<img width="1049" height="633" alt="fastapi_performance" src="https://github.com/user-attachments/assets/88b7f414-46db-4e62-9ee5-17fc5e3ff468" />

---

## 12. Resource Monitoring

Resource usage was monitored using Linux and Docker tools.

```bash
htop
vmstat 1
docker stats
```

### VM Screenshot:

<img width="1741" height="918" alt="Section_10_VM_htop" src="https://github.com/user-attachments/assets/5a8c29ba-dba3-4927-be6b-96c3f680f9d0" />

### Docker Screenshot: 

<img width="1253" height="795" alt="Section_10_Docker_Stats" src="https://github.com/user-attachments/assets/42ce89f8-7652-4758-9a0f-015fb3b937ed" />

---

## 13. Performance Analysis

### CPU

CPU performance was relatively close between VM and Docker across the tested thread counts.

### Memory

A larger difference was observed in memory throughput.

### Disk I/O

Docker recorded higher sequential read and random read performance, while the VM recorded higher sequential write performance. Random write performance was close.

### Network

Sender throughput was close, while receiver throughput and TCP retransmissions showed larger differences.

### FastAPI

The VM recorded higher requests per second for the tested FastAPI endpoints. Both environments completed the tests without failed requests.

---

## 14. Overall Comparison

| Metric | Virtual Machine | Docker Container |
|---|---:|---:|
| CPU – 4 threads | 928.17 EPS | 900.45 EPS |
| Memory – 1 thread | 9541.97 MiB/s | 5152.43 MiB/s |
| Sequential Read | 461 MiB/s | 500 MiB/s |
| Sequential Write | 358 MiB/s | 291 MiB/s |
| Random Read | 1313 IOPS | 1767 IOPS |
| Random Write | 1331 IOPS | 1346 IOPS |
| Network Throughput | 14.1 Gbits/s | 13.7 Gbits/s |
| API Requests/sec | 419.79 req/s | 371.07 req/s |

### Overall Performance Dashboard

<img width="1119" height="512" alt="overall_performance_dashboard" src="https://github.com/user-attachments/assets/656c2b1d-f1f7-4339-8c22-d64ec82cec68" />

The results show that performance varies depending on the workload and system configuration.

---

## 15. Screenshots and Graphs

All experiment evidence is stored in:

```bash
results/screenshots/
results/figures/
```

### Main Screenshots

- Docker_Success.png
- Container_CPU_Run1.png
- Section_10_VM_htop.png
- Section_10_Docker_Stats.png
- Section_13_iperf3_Parallel.png

### Graphs

- cpu_scalability.png
- memory_performance.png
- disk_io_performance.png
- network_performance.png
- fastapi_performance.png
- overall_performance_dashboard.png

Additional screenshots and outputs remain available in the project folders.

---

## 16. Project Structure

```
vm-vs-container-performance/
│
├── README.md
├── .gitignore
├── docs/
├── vm/
├── docker/
├── api/
├── workloads/
├── scripts/
│
├── results/
│   ├── raw/
│   ├── processed/
│   ├── figures/
│   └── screenshots/
│
└── analysis/
    └── analysis.ipynb
```

The project separates VM setup, Docker setup, application code, benchmark results, screenshots, graphs, and analysis.

---

## 17. Conclusion

This experiment evaluated VM and Docker performance using CPU, memory, disk I/O, network, and FastAPI workloads.

The results show that performance differences depend on the workload and system configuration.

The experiment provides practical data for understanding the performance characteristics of traditional virtual machines and container-based virtualization.


### The main difference

Your **old version** had lots of repeated material:

> command → screenshot → individual output → graph → another screenshot → explanation

The shortened version is:

> **method → result table → one useful graph → only important evidence**

So you still have **all 17 headings**, all your **real numerical results**, all **6 graphs**, and enough screenshots to prove the experiment was actually performed.

And importantly, **don't delete the unused screenshots from GitHub**. Keep them inside `results/screenshots/`; we're only removing them from the README itself.

---
