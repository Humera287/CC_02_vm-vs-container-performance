# Experiment 2: Performance Analysis of Virtual Machines and Containers (Docker)

[![Environment](https://img.shields.io/badge/OS-Ubuntu%2022.04%20LTS-purple.svg)](#)
[![Docker](https://img.shields.io/badge/Container%20Engine-Docker%20CE-blue.svg)](#)
[![Status](https://img.shields.io/badge/Benchmark-Complete%20(Infra%20%2B%20FastAPI)-brightgreen.svg)](#)

---

## 1. Executive Summary

Experiment 2 compares the performance of **Virtual Machines (VMware / KVM)** and **Docker Containers** using CPU, memory, storage, network, and FastAPI tests.

The same type of workloads were tested in both environments. The main tools used in this experiment are:

- **CPU:** `sysbench`
- **Memory:** `sysbench memory`
- **Storage:** `fio`
- **Network:** `iperf3`
- **Application:** FastAPI with `uvicorn`
- **API Testing:** ApacheBench (`ab`)
- **Monitoring:** `htop` and `docker stats`

The experiment helps us understand how Virtual Machines and Containers behave under different workloads.

---

## 2. Objectives

- To compare the performance of Virtual Machines and Docker Containers.
- To measure CPU performance using `sysbench`.
- To measure memory performance.
- To compare storage read and write performance using `fio`.
- To measure network performance using `iperf3`.
- To compare FastAPI application performance.
- To observe CPU and memory usage during the tests.
- To study the difference between VM-based and container-based environments.

---

## 3. Software and Tools Used

| Component | Tool / Technology |
|---|---|
| Operating System | Ubuntu 22.04 LTS |
| Virtualization | VMware / KVM |
| Container Engine | Docker CE |
| CPU Benchmark | Sysbench |
| Memory Benchmark | Sysbench |
| Storage Benchmark | fio |
| Network Benchmark | iperf3 |
| Application | FastAPI |
| Application Server | Uvicorn |
| API Testing | ApacheBench |
| Monitoring | htop, docker stats |
| Programming Language | Python |

---

## 3.1 Experimental Procedure

The experiment was completed step by step using the same workload and fixed configuration for both the Virtual Machine and Docker Container.

### Step 1: Prepare the Experimental Environment

- Create the project directory.
- Install the required benchmark tools.
- Verify the installed tools.
- Record CPU, memory, storage, and system information.

```bash
mkdir -p ~/vm-vs-container-performance
cd ~/vm-vs-container-performance

sudo apt update
sudo apt install -y sysbench fio iperf3 htop iotop sysstat python3 python3-pip git

sysbench --version
fio --version
iperf3 --version
python3 --version
git --version

lscpu
free -h
lsblk
df -h
uname -a
```

### Step 2: Configure the Virtual Machine

- Create an Ubuntu Virtual Machine using VMware Workstation.
- Allocate fixed CPU, memory, disk, and network resources.
- Start the VM and verify the assigned resources.
- Record the VM configuration.

```bash
nproc
free -h
lsblk
df -h
```

### Step 3: Configure Docker

- Install Docker if it is not already installed.
- Start the Docker service.
- Verify the Docker installation.
- Run the Docker `hello-world` test.

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker

docker --version
sudo docker run --rm hello-world
```

### Step 4: Create the Benchmark Docker Image

- Create the `docker` directory inside the project directory.
- Create the `Dockerfile`.
- Build the Docker benchmark image.
- Verify that the Docker image works.

#### Create the Docker Directory

```bash
cd ~/vm-vs-container-performance
mkdir -p docker
cd docker
nano Dockerfile
```

#### Dockerfile

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    sysbench \
    fio \
    iperf3 \
    python3 \
    python3-pip \
    procps \
    sysstat && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /benchmark
```

#### Build the Docker Image

Build the image from the project root:

```bash
cd ~/vm-vs-container-performance

docker build -t vm-container-benchmark -f docker/Dockerfile .
```

#### Verify the Docker Image

```bash
docker images
```

#### Test the Docker Image

```bash
docker run --rm -it vm-container-benchmark
```

Inside the container, verify the installed tools:

```bash
sysbench --version
fio --version
python3 --version
```

Exit the container:

```bash
exit
```

### Step 5: Establish the Baseline

- Run the CPU benchmark in the Virtual Machine.
- Use the same CPU workload for the later VM and Docker comparison.
- Save the baseline benchmark result.

#### Create the Baseline Results Directory

```bash
cd ~/vm-vs-container-performance

mkdir -p results/raw/baseline
```

#### Run the Baseline CPU Benchmark

```bash
sysbench cpu \
    --cpu-max-prime=20000 \
    --threads=4 \
    --time=30 \
    run
```

#### Save the Baseline Result

```bash
sysbench cpu \
    --cpu-max-prime=20000 \
    --threads=4 \
    --time=30 \
    run > results/raw/baseline/cpu.txt
```

The saved result is available at:

```text
results/raw/baseline/cpu.txt
```

### Step 6: Perform the CPU Benchmark

- Run the CPU benchmark in the Virtual Machine.
- Repeat the test 10 times.
- Run the same CPU benchmark inside the Docker container.
- Test CPU scalability using 1, 2, 4, and 8 threads.
- Record the CPU performance results.

#### VM CPU Benchmark

Create the VM results directory:

```bash
cd ~/vm-vs-container-performance
mkdir -p results/raw/cpu/vm
```

Run the CPU benchmark 10 times:

```bash
for i in {1..10}
do
    sysbench cpu \
        --cpu-max-prime=20000 \
        --threads=4 \
        --time=30 \
        run > results/raw/cpu/vm/run$i.txt
done
```

#### Docker CPU Benchmark

Create the Docker results directory:

```bash
mkdir -p results/raw/cpu/container
```

Run the same CPU benchmark 10 times:

```bash
for i in {1..10}
do
    docker run --rm \
        vm-container-benchmark \
        sysbench cpu \
        --cpu-max-prime=20000 \
        --threads=4 \
        --time=30 \
        run > results/raw/cpu/container/run$i.txt
done
```

#### CPU Scalability Test

The CPU workload was tested using 1, 2, 4, and 8 threads.

```bash
for threads in 1 2 4 8
do
    sysbench cpu \
        --cpu-max-prime=20000 \
        --threads=$threads \
        --time=30 \
        run
done
```

The CPU benchmark results are stored in:

```text
results/raw/cpu/vm/
results/raw/cpu/container/
```

### Step 7: Perform the Memory Benchmark

- Run the memory benchmark in the Virtual Machine.
- Use the same memory workload and parameters for Docker.
- Record the memory performance results.
- Repeat the test to obtain consistent measurements.

#### VM Memory Benchmark

Create the VM results directory:

```bash
cd ~/vm-vs-container-performance
mkdir -p results/raw/memory/vm
```

Run the memory benchmark:

```bash
sysbench memory \
    --memory-block-size=1M \
    --memory-total-size=10G \
    --threads=4 \
    run
```

Repeat the memory benchmark and save the results:

```bash
for i in {1..10}
do
    sysbench memory \
        --memory-block-size=1M \
        --memory-total-size=10G \
        --threads=4 \
        run > results/raw/memory/vm/run$i.txt
done
```

#### Docker Memory Benchmark

Create the Docker results directory:

```bash
mkdir -p results/raw/memory/container
```

Run the same memory benchmark inside Docker:

```bash
docker run --rm \
    vm-container-benchmark \
    sysbench memory \
    --memory-block-size=1M \
    --memory-total-size=10G \
    --threads=4 \
    run
```

Repeat the Docker memory benchmark:

```bash
for i in {1..10}
do
    docker run --rm \
        vm-container-benchmark \
        sysbench memory \
        --memory-block-size=1M \
        --memory-total-size=10G \
        --threads=4 \
        run > results/raw/memory/container/run$i.txt
done
```

The memory benchmark results are stored in:

```text
results/raw/memory/vm/
results/raw/memory/container/
```

### Step 8: Monitor Resource Usage

- Monitor CPU and memory usage during the benchmark experiments.
- Use `htop` and `vmstat` for system and VM monitoring.
- Use `docker stats` to monitor Docker container resources.
- Record the CPU and memory usage during the tests.

#### Monitor VM/System Resources

Open `htop`:

```bash
htop
```

Monitor system statistics using `vmstat`:

```bash
vmstat 1
```

#### Monitor Docker Container Resources

Run the Docker container:

```bash
docker run -d \
    --name benchmark-monitor \
    vm-container-benchmark \
    sleep 300
```

Monitor the container:

```bash
docker stats benchmark-monitor
```

Stop and remove the container after monitoring:

```bash
docker stop benchmark-monitor
docker rm benchmark-monitor
```

The resource monitoring results were observed during the CPU, memory, storage, and application benchmark tests.

### Step 9: Perform the Disk I/O Benchmark

- Create the disk test directory.
- Perform sequential write and read tests.
- Perform random read and write tests.
- Use the same workload for both the Virtual Machine and Docker.
- Record the disk performance results.

#### Create the Disk Test Directory

```bash
cd ~/vm-vs-container-performance

mkdir -p ~/fio-test
mkdir -p results/raw/disk
```

#### Sequential Write Test

```bash
docker run --rm \
    -v ~/fio-test:/fio-test \
    vm-container-benchmark \
    fio --name=seq-write \
    --filename=/fio-test/testfile \
    --size=2G \
    --bs=1M \
    --rw=write \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based
```

#### Sequential Read Test

```bash
fio --name=seq-read \
    --filename=~/fio-test/testfile \
    --size=2G \
    --bs=1M \
    --rw=read \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based
```

#### Random Read Test

```bash
fio --name=random-read \
    --filename=~/fio-test/testfile \
    --size=2G \
    --bs=4k \
    --rw=randread \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based
```

#### Random Write Test

```bash
fio --name=random-write \
    --filename=~/fio-test/testfile \
    --size=2G \
    --bs=4k \
    --rw=randwrite \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based
```

#### Docker Disk I/O Test

The same disk workload was executed inside Docker using a bind mount.

Sequential write:

```bash
docker run --rm \
    -v ~/fio-test:/fio-test \
    vm-container-benchmark \
    fio --name=seq-write \
    --filename=/fio-test/testfile 
    --size=2G 
    --bs=1M 
    --rw=write 
    --direct=1 
    --iodepth=16 
    --runtime=30 
    --time_based
```

Sequential read:

```bash
docker run --rm \
    -v ~/fio-test:/fio-test \
    vm-container-benchmark \
    fio --name=seq-read \
    --filename=/fio-test/testfile \
    --size=2G \
    --bs=1M \
    --rw=read \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based
```

Random read:

```bash
docker run --rm \
    -v ~/fio-test:/fio-test \
    vm-container-benchmark \
    fio --name=random-read \
    --filename=/fio-test/testfile \
    --size=2G \
    --bs=4k \
    --rw=randread \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based
```

Random write:

```bash
docker run --rm \
    -v ~/fio-test:/fio-test \
    vm-container-benchmark \
    fio --name=random-write \
    --filename=/fio-test/testfile \
    --size=2G \
    --bs=4k \
    --rw=randwrite \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based
```

The disk I/O results were recorded for:

- Sequential Read
- Sequential Write
- Random Read
- Random Write

The results were then used to compare Virtual Machine and Docker storage performance.

### Step 10: Perform the Network Benchmark

- Start the `iperf3` server.
- Find the server IP address.
- Run the `iperf3` client test.
- Perform a parallel stream test.
- Record network throughput and TCP retransmissions.
- Use the same network configuration for the VM and Docker tests.

#### Start the iperf3 Server

On the server machine:

```bash
iperf3 -s
```

#### Find the Server IP Address

Open another terminal and run:

```bash
ip addr
```

Note the IP address of the network interface being used.

#### Run the Basic Network Test

On the client machine:

```bash
iperf3 -c <SERVER-IP> -t 30
```

Replace `<SERVER-IP>` with the actual IP address of the iperf3 server.

#### Run the Parallel Network Test

```bash
iperf3 -c <SERVER-IP> -t 30 -P 4
```

The `-P 4` option runs four parallel TCP streams.

#### Record the Results

The following metrics were recorded:

- Sender throughput
- Receiver throughput
- TCP retransmissions

The same test configuration was used for both the Virtual Machine and Docker Container to compare their network performance.

### Step 11: Create and Test the FastAPI Application

- Create the `api` directory inside the project directory.
- Create the FastAPI application file `main.py`.
- Install FastAPI and Uvicorn.
- Start the FastAPI application.
- Test the `/health`, `/compute`, and `/memory` endpoints.

#### Create the API Directory

```bash
cd ~/vm-vs-container-performance

mkdir -p api
cd api
```

#### Install FastAPI and Uvicorn

```bash
python3 -m pip install fastapi uvicorn
```

#### Create the FastAPI Application

Create the `main.py` file:

```bash
nano main.py
```

Add the following code:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/compute")
def compute():
    total = 0
    for i in range(1_000_000):
        total += i * i
    return {"result": total}

@app.get("/memory")
def memory():
    data = [i for i in range(1_000_000)]
    return {
        "elements": len(data)
    }
```

#### Start the FastAPI Application

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

#### Test the Health Endpoint

Open another terminal and run:

```bash
curl http://localhost:8000/health
```

Expected output:

```text
{"status":"healthy"}
```

#### Test the Compute Endpoint

```bash
curl http://localhost:8000/compute
```

#### Test the Memory Endpoint

```bash
curl http://localhost:8000/memory
```

The FastAPI application was successfully created and tested using the three endpoints.

### Step 12: Containerize the FastAPI Application

- Create the `requirements.txt` file.
- Create the FastAPI Dockerfile.
- Build the Docker image.
- Run the FastAPI application inside the Docker container.
- Test the containerized API.

#### Create `requirements.txt`

Inside the `api` directory, create:

```bash
cd ~/vm-vs-container-performance/api
nano requirements.txt
```

Add:

```text
fastapi
uvicorn
```

#### Create the FastAPI Dockerfile

Create the Dockerfile:

```bash
nano Dockerfile
```

Add:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Build the FastAPI Docker Image

Build the image from the project root:

```bash
cd ~/vm-vs-container-performance

docker build -t performance-api -f api/Dockerfile api
```

#### Run the FastAPI Container

```bash
docker run --rm \
    --cpus=4 \
    --memory=8g \
    -p 8000:8000 \
    performance-api
```

#### Test the Containerized API

Open another terminal and run:

```bash
curl http://127.0.0.1:8000/health
```

Expected output:

```text
{"status":"healthy"}
```

The FastAPI application was successfully containerized and executed using Docker.

### Step 13: Benchmark the FastAPI Application

- Install Apache Benchmark (`ab`).
- Test the `/health` endpoint.
- Test the `/compute` endpoint.
- Test the `/memory` endpoint.
- Record requests per second, latency, and failed requests.
- Use the same benchmark settings for both the Virtual Machine and Docker Container.

#### Install Apache Benchmark

```bash
sudo apt install -y apache2-utils
```

#### Benchmark the Health Endpoint

```bash
ab -n 10000 -c 100 http://127.0.0.1:8000/health
```

The test uses:

- **Requests:** 10,000
- **Concurrency:** 100

Record the following results:

- Requests per second
- Time per request
- Failed requests
- Connection times

#### Benchmark the Compute Endpoint

```bash
ab -n 1000 -c 10 http://127.0.0.1:8000/compute
```

The test uses:

- **Requests:** 1,000
- **Concurrency:** 10

#### Benchmark the Memory Endpoint

```bash
ab -n 1000 -c 10 http://127.0.0.1:8000/memory
```

The test uses:

- **Requests:** 1,000
- **Concurrency:** 10

#### Record the Results

The FastAPI benchmark results were recorded for:

- Requests per second
- Time per request
- Failed requests
- API latency

The same benchmark configuration was used for the Virtual Machine and Docker Container for comparison.

### Step 14: Measure Startup Time

- Measure the Docker application startup time.
- Record the time required to start the FastAPI container.
- Check when the application becomes ready.
- Repeat the test and record the startup measurements.

#### Measure Basic Docker Startup Time

```bash
time docker run --rm performance-api
```

#### Perform the Controlled Startup Test

```bash
time docker run --rm \
    -d \
    --name startup-test \
    -p 8000:8000 \
    performance-api
```

#### Check the Running Container

```bash
docker ps
```

#### Stop the Container

```bash
docker stop startup-test
```

#### Record the Results

The startup test was used to observe the Docker container startup behavior.

The following measurements can be recorded:

- Container startup time
- Application ready time

VM startup time was not included in the measured benchmark table unless an equivalent VM startup measurement was recorded.

### Step 15: Perform the Scalability Test

- Increase the CPU thread count from 1 to 8.
- Measure CPU performance at each thread level.
- Increase the API workload using different thread and connection counts.
- Record throughput, latency, CPU usage, and memory usage.

#### CPU Scalability Test

Run the CPU benchmark with 1, 2, 4, and 8 threads:

```bash
for threads in 1 2 4 8
do
    sysbench cpu \
        --cpu-max-prime=20000 \
        --threads=$threads \
        --time=30 \
        run
done
```

The CPU performance was recorded in terms of events per second for each thread count.

#### API Scalability Test

The FastAPI health endpoint can be tested with different workload levels using wrk:
```bash
wrk -t1 -c10 -d30s http://127.0.0.1:8000/health
```

```bash
wrk -t2 -c50 -d30s http://127.0.0.1:8000/health
```

```bash
wrk -t4 -c100 -d30s http://127.0.0.1:8000/health
```

```bash
wrk -t4 -c200 -d30s http://127.0.0.1:8000/health
```

Where:

- `-t` = number of threads
- `-c` = number of connections
- `-d` = test duration

The scalability results were recorded for:

- Throughput
- Latency
- CPU usage
- Memory usage

### Step 16: Collect and Process the Results

- Collect the output from all benchmark experiments.
- Store the raw benchmark results in the `results/raw/` directory.
- Store processed data in CSV files under `results/processed/`.
- Calculate statistical values such as mean, median, minimum, maximum, and standard deviation.
- Compare the measured performance of the Virtual Machine and Docker Container.

#### Create the Results Directories

```bash
cd ~/vm-vs-container-performance

mkdir -p results/raw
mkdir -p results/processed
mkdir -p results/figures
```

#### Store Raw Results

The raw benchmark outputs were stored in:

```text
results/raw/
```

The results include:

- CPU benchmark results
- Memory benchmark results
- Disk I/O results
- Network benchmark results
- FastAPI benchmark results
- Startup measurements
- Scalability results

#### Create the Processed CSV File

Example CPU results file:

```bash
nano results/processed/cpu_results.csv
```

The CSV file contains:

```text
environment,threads,execution_time,events_per_second
VM,1,<value>,<value>
Docker,1,<value>,<value>
VM,2,<value>,<value>
Docker,2,<value>,<value>
VM,4,<value>,<value>
Docker,4,<value>,<value>
VM,8,<value>,<value>
Docker,8,<value>,<value>
```

Replace `<value>` with the actual measured benchmark values.

#### Install Python Analysis Libraries

```bash
pip install pandas matplotlib numpy jupyter
```

#### Run the Analysis Script

```bash
python3 scripts/analyze_results.py
```

The processed results were used to calculate:

- Mean
- Median
- Minimum
- Maximum
- Standard deviation

The processed data was then used for generating graphs and comparing VM and Docker performance.

### Step 17: Generate Graphs and Tables

- Generate graphs for CPU, memory, disk, network, application, startup, and scalability results.
- Use the actual measured values from the experiments.
- Add clear titles, axis labels, units, and legends to the graphs.
- Prepare the final VM vs Docker comparison table.

#### Generate the Graphs

Make sure the project directory is correct:

```bash
cd ~/vm-vs-container-performance
```

Run the graph generation script:

```bash
python3 scripts/generate_plots.py
```

The generated graphs are stored in:

```text
results/figures/
```

The graphs include:

```text
cpu_scalability.png
memory_performance.png
disk_io_performance.png
network_performance.png
fastapi_performance.png
overall_performance_dashboard.png
```

#### Prepare the Final Comparison Table

The final comparison table contains the measured results for:

| Metric | Virtual Machine | Docker Container |
|---|---:|---:|
| CPU Performance (4 threads) | 928.17 EPS | 900.45 EPS |
| Memory Performance (1 thread) | 9,541.97 MiB/s | 5,152.43 MiB/s |
| Sequential Read | 461 MiB/s | 500 MiB/s |
| Sequential Write | 358 MiB/s | 291 MiB/s |
| Random Read | 1,313 IOPS | 1,767 IOPS |
| Random Write | 1,331 IOPS | 1,346 IOPS |
| Network Throughput | 14.1 Gbits/s | 13.7 Gbits/s |
| API Requests/sec | 419.79 req/s | 371.07 req/s |
| API Latency | 238.21 ms | 269.49 ms |

The final graphs and comparison table were used to analyze the performance differences between the Virtual Machine and Docker Container.

### Step 18: Complete the GitHub Repository

- Keep the README, scripts, source files, raw results, processed results, and graphs in the project structure.
- Initialize Git from the project root.
- Add and commit the project files.
- Connect the project to the GitHub repository.
- Push the project to GitHub.

#### Navigate to the Project Directory

```bash
cd ~/vm-vs-container-performance
```

#### Initialize Git

```bash
git init
```

#### Check the Repository Status

```bash
git status
```

#### Add Project Files

```bash
git add .
```

Check the files again:

```bash
git status
```

#### Commit the Project

```bash
git commit -m "Initial project setup"
```

#### Set the Main Branch

```bash
git branch -M main
```

#### Connect the GitHub Repository

```bash
git remote add origin <GITHUB-REPOSITORY-URL>
```

Verify the remote repository:

```bash
git remote -v
```

#### Push the Project to GitHub

```bash
git push -u origin main
```

The complete project, including the README, source files, benchmark results, analysis, and generated graphs, was pushed to the GitHub repository.

---

# 4. CPU Performance Test

CPU performance was tested using `sysbench cpu`.

The workload used the following settings:

- Prime number calculation
- 1, 2, 4 and 8 threads
- Same workload for VM and Docker
- Performance measured in events per second (EPS)

---

## 4.1 CPU Baseline

The baseline CPU test was first executed in the VM.

### Screenshot Evidence

<img width="1502" height="863" alt="Baseline_CPU_Benchmark" src="https://github.com/user-attachments/assets/2ffd2367-961d-4edc-9e30-3eb3ddcf98cb" />

```text
results/screenshots/Baseline_CPU_Benchmark.png
```

The baseline output was used as the starting point for comparing CPU performance.

---

## 4.2 VM CPU Benchmark

The CPU benchmark was executed inside the Virtual Machine.

### Screenshot Evidence

<img width="1424" height="863" alt="VM_CPU_Run1" src="https://github.com/user-attachments/assets/2768b3c7-b770-40b4-a4cd-21728dc5b08e" />

```text
results/screenshots/VM_CPU_Run1.png
```

The VM CPU benchmark was used as the reference for comparing Docker CPU performance.

---

## 4.3 Docker CPU Benchmark

The same CPU workload was executed inside the Docker container.

### Screenshot Evidence

<img width="1669" height="747" alt="Container_CPU_Run1" src="https://github.com/user-attachments/assets/4261ea1d-0b13-4d62-8467-ffc85b1eb809" />

```text
results/screenshots/Container_CPU_Run1.png
```

The Docker container produced CPU results close to the VM results.

---

## 4.4 CPU Scalability Test

The CPU test was repeated using different thread counts.

### 1 Thread

<img width="1132" height="1000" alt="CPU_Scalability_1_Thread" src="https://github.com/user-attachments/assets/d0204563-c78a-441d-84de-bbdcb51e5d62" />

```text
results/screenshots/CPU_Scalability_1_Thread.png
```

**VM:** 515.84 EPS  
**Docker:** 517.19 EPS

---

### 2 Threads

<img width="1049" height="992" alt="CPU_Scalability_2_Thread" src="https://github.com/user-attachments/assets/b5f098a8-13bf-48c7-b3f9-fb7246bf062a" />

```text
results/screenshots/CPU_Scalability_2_Thread.png
```

**VM:** 883.55 EPS  
**Docker:** 894.38 EPS

---

### 4 Threads

<img width="976" height="925" alt="CPU_Scalability_3_Thread" src="https://github.com/user-attachments/assets/9c9013f5-cbbe-46a1-9a06-a22760983c27" />

```text
results/screenshots/CPU_Scalability_3_Thread.png
```

**VM:** 928.17 EPS  
**Docker:** 900.45 EPS

---

### 8 Threads

<img width="961" height="939" alt="CPU_Scalability_4_Thread" src="https://github.com/user-attachments/assets/a3ddb795-91d7-4ec6-8cab-1fa0c71fb6ec" />

```text
results/screenshots/CPU_Scalability_4_Thread.png
```

**VM:** 905.17 EPS  
**Docker:** 914.42 EPS

---

## 4.5 CPU Performance Comparison

| Threads | VM EPS | Docker EPS | Difference |
|---:|---:|---:|---:|
| 1 | 515.84 | 517.19 | +0.26% |
| 2 | 883.55 | 894.38 | +1.23% |
| 4 | 928.17 | 900.45 | +3.08% |
| 8 | 905.17 | 914.42 | +1.02% |

The CPU results are close between the VM and Docker container for most thread counts.

---

# 5. Docker Image and Container Setup

The benchmark Docker image was created before running the container tests.

### Docker Image Screenshot

<img width="1701" height="847" alt="Docker_image" src="https://github.com/user-attachments/assets/b660d87f-82ef-4048-aea1-124a61342c74" />

```text
results/screenshots/Docker_image.png
```

This screenshot shows the Docker image created for the benchmark.

---

### Docker Container Success Screenshot

<img width="1666" height="890" alt="Docker_Success" src="https://github.com/user-attachments/assets/581aa535-64aa-40cc-a649-e8e263fe7f04" />

```text
results/screenshots/Docker_Success.png
```

This confirms that the Docker container was created and executed successfully.

---

# 6. Memory Performance Test

Memory performance was tested using `sysbench memory`.

The test used a memory block size of 1 MB and measured memory write bandwidth.

---

## 6.1 VM Memory Test

The memory benchmark was executed inside the Virtual Machine.

### Screenshot Evidence

<img width="1741" height="918" alt="Section_10_VM_htop" src="https://github.com/user-attachments/assets/c3f2233e-6098-4e20-8b1d-0da654eab0f6" />

```text
results/screenshots/Section_10_VM_htop.png
```

The `htop` output was used to observe CPU and memory usage in the VM.

---

## 6.2 Docker Memory Test

The memory benchmark was also executed inside the Docker container.

### Screenshot Evidence

<img width="955" height="917" alt="Section_9_Container_Memory_Run1" src="https://github.com/user-attachments/assets/094af7da-e3f3-4b51-b31d-07f6a7759f0e" />

```text
results/screenshots/Section_9_Container_Memory_Run1.png
```

## 6.3 Memory Monitoring

Docker resource usage was checked using `docker stats`.

### Screenshot Evidence

<img width="1253" height="795" alt="Section_10_Docker_Stats" src="https://github.com/user-attachments/assets/0d4328a5-a8fc-4b01-b869-ca6e8da3edfe" />

```text
results/screenshots/Section_10_Docker_Stats.png
```

## 6.4 Memory Performance Results

| Threads | VM Bandwidth | Docker Bandwidth | Difference |
|---:|---:|---:|---:|
| 1 | 9,541.97 MiB/s | 5,152.43 MiB/s | +85.19% |
| 2 | 9,880.38 MiB/s | 6,970.16 MiB/s | +41.75% |

The VM showed higher memory write bandwidth in the measured tests.

---

# 7. Storage I/O Performance

Storage performance was tested using the `fio` tool.

The following workloads were tested:

- Sequential Read
- Sequential Write
- Random Read
- Random Write

---

## 7.1 VM Random Read

### Screenshot Evidence

<img width="1353" height="905" alt="Section_11_VM_Random_Read" src="https://github.com/user-attachments/assets/d14e220c-96e7-4424-8ae9-3fa85eec92e0" />

```text
results/screenshots/Section_11_VM_Random_Read.png
```

**VM Random Read:** 1,313 IOPS

---

## 7.2 VM Random Write

### Screenshot Evidence

<img width="1291" height="919" alt="Section_11_VM_Random_Write" src="https://github.com/user-attachments/assets/cfcfcda3-27e1-4463-8a07-58b1f08573cd" />

```text
results/screenshots/Section_11_VM_Random_Write.png
```

**VM Random Write:** 1,331 IOPS

---

## 7.3 VM Sequential Read

### Screenshot Evidence

<img width="1331" height="894" alt="Section_11_VM_Seq_Read" src="https://github.com/user-attachments/assets/a2fefa4c-a3e5-475d-b06d-8bd8d07c4019" />

```text
results/screenshots/Section_11_VM_Seq_Read.png
```

**VM Sequential Read:** 461 MiB/s

---

## 7.4 VM Sequential Write

### Screenshot Evidence

<img width="1549" height="936" alt="Section_11_VM_Seq_Write" src="https://github.com/user-attachments/assets/5b2aa489-639a-4f8d-ac79-5afed890362d" />

```text
results/screenshots/Section_11_VM_Seq_Write.png
```

**VM Sequential Write:** 358 MiB/s

---

## 7.5 Docker Random Read

### Screenshot Evidence

<img width="967" height="909" alt="Section_12_Docker_Random_Read" src="https://github.com/user-attachments/assets/045595e9-645e-40c7-9601-963a227e972b" />

```text
results/screenshots/Section_12_Docker_Random_Read.png
```

**Docker Random Read:** 1,767 IOPS

---

## 7.6 Docker Random Write

The Docker random write output is included in the storage benchmark results.

**Docker Random Write:** 1,346 IOPS

---

## 7.7 Docker Sequential Read

The Docker sequential read output is included in the storage benchmark results.

**Docker Sequential Read:** 500 MiB/s

---

## 7.8 Docker Sequential Write

### Screenshot Evidence

<img width="1383" height="927" alt="Section_12_Docker_Seq_Write" src="https://github.com/user-attachments/assets/4212ab98-b412-4956-a97c-261ba7fe347d" />

```text
results/screenshots/Section_12_Docker_Seq_Write.png
```

**Docker Sequential Write:** 291 MiB/s

---

## 7.9 Storage Performance Comparison

| Storage Test | VM | Docker | Difference |
|---|---:|---:|---:|
| Sequential Read | 461 MiB/s | 500 MiB/s | +8.46% |
| Sequential Write | 358 MiB/s | 291 MiB/s | +23.02% |
| Random Read | 1,313 IOPS | 1,767 IOPS | +34.58% |
| Random Write | 1,331 IOPS | 1,346 IOPS | +1.13% |

The results show that the two environments have different storage performance for different workloads.

---

# 8. Network Performance Test

Network performance was tested using `iperf3`.

The test measured:

- Sender bitrate
- Receiver bitrate
- TCP retransmissions
- Parallel network performance

---

## 8.1 iperf3 Server

### Screenshot Evidence

<img width="960" height="905" alt="Section_13_iperf3_Server" src="https://github.com/user-attachments/assets/ee636016-2ef7-406e-a9c4-fb75b1e79e99" />

```text
results/screenshots/Section_13_iperf3_Server.png
```

The server was started using the `iperf3 -s` command.

---

## 8.2 iperf3 Client

### Screenshot Evidence

<img width="914" height="880" alt="Section_13_iperf3_Client" src="https://github.com/user-attachments/assets/c50534aa-ca43-4fca-bdd6-fd3f07dbb5a3" />

```text
results/screenshots/Section_13_iperf3_Client.png
```

The client connected to the iperf3 server and measured the network throughput.

---

## 8.3 Parallel Network Test

### Screenshot Evidence

<img width="912" height="867" alt="Section_13_iperf3_Parallel" src="https://github.com/user-attachments/assets/71bc53e7-2e7e-432f-8b70-a8d824bef6a4" />

```text
results/screenshots/Section_13_iperf3_Parallel.png
```

The parallel test was performed using multiple TCP streams.

---

## 8.4 Network Performance Results

| Metric | VM | Docker | Difference |
|---|---:|---:|---:|
| Sender Bitrate | 14.1 Gbits/s | 13.7 Gbits/s | +2.92% |
| Receiver Bitrate | 14.1 Gbits/s | 10.3 Gbits/s | +36.89% |
| TCP Retransmissions | 3 packets | 13 packets | +333% |

The Docker bridge network uses virtual interfaces such as `veth` and `docker0`, which adds extra network processing.

---

# 9. FastAPI Application Test

A simple FastAPI application was used to compare application performance.

The application contains three endpoints:

```text
/health
/compute
/memory
```

The application was executed in both the VM and Docker environment.

---

## 9.1 FastAPI Health Endpoint

### Screenshot Evidence

<img width="892" height="878" alt="Section_14_API_Health" src="https://github.com/user-attachments/assets/51388fe3-9802-4682-a5ea-2082e38a6f4c" />

```text
results/screenshots/Section_14_API_Health.png
```

The `/health` endpoint returned the expected healthy status.

### Result

- **VM:** 419.79 req/s
- **Docker:** 371.07 req/s
- **VM Latency:** 238.21 ms
- **Docker Latency:** 269.49 ms
- **Failed Requests:** 0

---

## 9.2 FastAPI Compute Endpoint

### Screenshot Evidence

<img width="897" height="886" alt="Section_14_API_Compute" src="https://github.com/user-attachments/assets/b943e4c2-02cd-4e1b-a3b5-e463dd82d113" />

```text
results/screenshots/Section_14_API_Compute.png
```

The `/compute` endpoint performs a CPU-based calculation.

### Result

- **VM:** 12.24 req/s
- **Docker:** 10.76 req/s
- **Requests:** 1,000
- **Concurrency:** 10
- **Failed Requests:** 0

---

## 9.3 FastAPI Memory Endpoint

### Screenshot Evidence

<img width="915" height="884" alt="Section_14_API_Memory" src="https://github.com/user-attachments/assets/27b233d8-a551-49b5-b445-553a785ad73a" />

```text
results/screenshots/Section_14_API_Memory.png
```

The `/memory` endpoint creates and processes a large list in memory.

### Result

- **VM:** 16.43 req/s
- **Docker:** 14.40 req/s
- **Requests:** 1,000
- **Concurrency:** 10
- **Failed Requests:** 0

---

## 9.4 FastAPI Performance Comparison

| Endpoint | VM | Docker | Difference |
|---|---:|---:|---:|
| `/health` | 419.79 req/s | 371.07 req/s | +13.13% |
| `/compute` | 12.24 req/s | 10.76 req/s | +13.75% |
| `/memory` | 16.43 req/s | 14.40 req/s | +14.10% |

---

# 10. Additional Experiment Outputs

The following screenshots contain additional executed outputs from the experiment.

### Experiment Output 1

<img width="1344" height="887" alt="Experiment2_Output1" src="https://github.com/user-attachments/assets/399a40b8-d553-43a7-8252-b315cb7668fd" />

```text
results/screenshots/Experiment2_Output1.png
```

### Experiment Output 2

<img width="1344" height="879" alt="Experiment2_Output2" src="https://github.com/user-attachments/assets/7b7df58c-9ca6-4f60-bf4a-a2a6e8b9b972" />

```text
results/screenshots/Experiment2_Output2.png
```

---

### Experiment Output 3

<img width="1197" height="858" alt="Experiment2_Output3" src="https://github.com/user-attachments/assets/cb5f5dbe-5676-4d9b-a30f-4e20839ef071" />

```text
results/screenshots/Experiment2_Output3.png
```

---

### Experiment Output 4

<img width="1247" height="879" alt="Experiment2_Output4" src="https://github.com/user-attachments/assets/8cbd2511-e6b4-43be-b6b6-991e88bb2522" />

```text
results/screenshots/Experiment2_Output4.png
```


These screenshots can be kept as additional proof of the commands and outputs obtained during the experiment.

---

# 11. Overall Performance Comparison

| Subsystem / Metric | Virtual Machine (VM) | Docker Container | Empirical Delta |
|---|---:|---:|---:|
| CPU 1-Thread Throughput | 515.84 EPS | 517.19 EPS | +0.26% |
| CPU 2-Thread Throughput | 883.55 EPS | 894.38 EPS | +1.23% |
| CPU 4-Thread Throughput | 928.17 EPS | 900.45 EPS | +3.08% |
| CPU 8-Thread Throughput | 905.17 EPS | 914.42 EPS | +1.02% |
| Memory Bandwidth (1-Thread) | 9,541.97 MiB/s | 5,152.43 MiB/s | +85.19% |
| Memory Bandwidth (2-Thread) | 9,880.38 MiB/s | 6,970.16 MiB/s | +41.75% |
| Storage Sequential Read | 461 MiB/s | 500 MiB/s | +8.46% |
| Storage Sequential Write | 358 MiB/s | 291 MiB/s | +23.02% |
| Storage Random Read | 1,313 IOPS | 1,767 IOPS | +34.58% |
| Storage Random Write | 1,331 IOPS | 1,346 IOPS | +1.13% |
| Network Sender Bitrate | 14.1 Gbits/s | 13.7 Gbits/s | +2.92% |
| Network Receiver Bitrate | 14.1 Gbits/s | 10.3 Gbits/s | +36.89% |
| Network TCP Retransmissions | 3 packets | 13 packets | +333% |
| FastAPI `/health` | 419.79 req/s | 371.07 req/s | +13.13% |
| FastAPI `/compute` | 12.24 req/s | 10.76 req/s | +13.75% |
| FastAPI `/memory` | 16.43 req/s | 14.40 req/s | +14.10% |

---

# 12. Graphs and Charts

The measured values were also used to create graphs for easier comparison.

## 12.1 CPU Scalability

<img width="1044" height="635" alt="cpu_scalability" src="https://github.com/user-attachments/assets/036fb1af-98ec-4da8-8b19-17825e17efe0" />

*Figure 1: CPU throughput comparison for 1, 2, 4 and 8 threads.*

---

## 12.2 Memory Performance

<img width="1046" height="632" alt="memory_performance" src="https://github.com/user-attachments/assets/7af64708-ef67-45ec-8afb-3f170cf7cbf4" />

*Figure 2: Memory bandwidth comparison between VM and Docker.*

---

## 12.3 Disk I/O Performance

<img width="1047" height="631" alt="disk_io_performance" src="https://github.com/user-attachments/assets/04c013d7-c104-4091-8c89-b9a4014b4d37" />

*Figure 3: Sequential and random storage performance comparison.*

---

## 12.4 Network Performance

<img width="1043" height="634" alt="network_performance" src="https://github.com/user-attachments/assets/07479646-8ed3-4205-8a8f-45cc151a81ca" />

*Figure 4: Network bitrate and retransmission comparison.*

---

## 12.5 FastAPI Performance

<img width="1049" height="633" alt="fastapi_performance" src="https://github.com/user-attachments/assets/8239f584-b600-480b-bd76-6a053218c266" />

*Figure 5: FastAPI request throughput and latency comparison.*

---

## 12.6 Overall Performance Dashboard

<img width="1119" height="512" alt="overall_performance_dashboard" src="https://github.com/user-attachments/assets/310dfe00-d544-4484-a071-488af4797a81" />

*Figure 6: Overall comparison of the tested VM and Docker workloads.*

---

# 13. Why the Results Are Different

## CPU

Docker containers run processes directly on the Linux host kernel. They use namespaces and `cgroups` for isolation and resource control.

Because there is no complete guest operating system inside the container, CPU processing can remain close to the VM performance.

---

## Memory

Memory performance can change because of the way memory is managed by the VM and Docker environment.

The measured results showed higher memory bandwidth in the VM for the tested workloads.

---

## Storage

A VM normally accesses storage through its virtual hardware and hypervisor layer.

Docker containers use the host Linux filesystem and Docker storage system. This can reduce some extra layers for certain storage operations.

The random read test showed:

- VM: **1,313 IOPS**
- Docker: **1,767 IOPS**

---

## Network

Docker's default bridge network uses:

- `docker0`
- `veth`
- Network namespaces
- NAT and packet filtering

These additional network layers can affect throughput and retransmissions.

---

## FastAPI

FastAPI performance depends on CPU, memory, networking, and the application server.

The `/health`, `/compute`, and `/memory` tests showed different request rates between the VM and Docker environments.

---

# 14. Screenshot Evidence List

All experiment screenshots should be stored inside:

```text
results/screenshots/
```

The screenshot names from the experiment are:

```text
Baseline_CPU_Benchmark.png
benchmark.png
benchmark_Docker_container.png
Container_CPU_Run1.png

CPU_Scalability_1_Thread.png
CPU_Scalability_2_Thread.png
CPU_Scalability_3_Thread.png
CPU_Scalability_4_Thread.png

Docker_image.png
Docker_Success.png

Experiment2_Output1.png
Experiment2_Output2.png
Experiment2_Output3.png
Experiment2_Output4.png

Section_9_Container_Memory_Run1.png
Section_10_Docker_Stats.png
Section_10_VM_htop.png

Section_11_VM_Random_Read.png
Section_11_VM_Random_Write.png
Section_11_VM_Seq_Read.png
Section_11_VM_Seq_Write.png

Section_12_Docker_Random_Read.png
Section_12_Docker_Seq_Write.png

Section_13_iperf3_Client.png
Section_13_iperf3_Parallel.png
Section_13_iperf3_Server.png

Section_14_API_Compute.png
Section_14_API_Health.png
Section_14_API_Memory.png

VM_CPU_Run1.png
```

> **Note:** The `Type1_Type2` folder is not included because it belongs to the other experiment.

---

# 15. Project Structure

```text
vm-vs-container-performance/
│
├── README.md
├── .gitignore
│
├── docs/
│   ├── architecture.png
│   ├── cpu-info.txt
│   ├── memory-info.txt
│   ├── storage-info.txt
│   └── methodology.md
│
├── vm/
│   ├── setup.sh
│   └── benchmark.sh
│
├── docker/
│   ├── Dockerfile
│   └── benchmark.sh
│
├── api/
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── workloads/
│   ├── cpu/
│   ├── memory/
│   ├── disk/
│   └── network/
│
├── scripts/
│   ├── run_cpu.sh
│   ├── run_memory.sh
│   ├── run_disk.sh
│   ├── run_network.sh
│   ├── collect_metrics.py
│   ├── analyze_results.py
│   └── generate_plots.py
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

---

# 16. Conclusion

Experiment 2 compared **Virtual Machines and Docker Containers** using CPU, memory, storage, network, and FastAPI workloads.

The CPU results were close between the two environments. Differences were observed in memory bandwidth, storage performance, network performance, and FastAPI throughput.

Docker showed higher performance in some storage tests, while the VM showed higher values in several memory, network, and FastAPI tests.

The screenshots, measured values, tables, and graphs together provide the complete performance comparison for the experiment.
