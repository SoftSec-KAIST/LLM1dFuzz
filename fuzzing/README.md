# Fuzzing Artifact

This is the artifact for the fuzzing experiments used in our paper.
The artifact is built on top of DAFL benchmark, and its usage is very similar to that of DAFL.

## System requirements

To run the experiments in the paper, we used a 88-core (Intel Xeon E5-2699 v4, 2.2 GHz) machine with 512 GB of RAM and Ubuntu 18.04. Out of 88 cores, We utilized 40 cores with 4 GB of RAM assigned for each core.

The system requirements depend on the desired experimental throughput.
For example, if you want to run 10 fuzzing sessions in parallel, we recommend using a machine with at least 16 cores and 64 GB of RAM.

You can set the number of iterations to be run in parallel and the amount of RAM to assign to each fuzzing session by modifying the `MAX_INSTANCE_NUM` and `MEM_PER_INSTANCE` variables in `scripts/common.py`. The default values are 40 and 4, respectively.


To reproduce the results, we assume that you have the following system requirements:

- Ubuntu 18.04
- Docker
- python 3.8+
- pip3

For the python dependencies, you can install them by running the following command:

```bash
$ yes | pip3 install -r requirements.txt
```

&nbsp;

## System configuration

To run AFL-based fuzzers, you should first fix the core dump name pattern.

```
$ echo core | sudo tee /proc/sys/kernel/core_pattern
```

If your system has `/sys/devices/system/cpu/cpu*/cpufreq` directory, AFL may also complain about the CPU frequency scaling configuration. Check the current
configuration and remember it if you want to restore it later. Then, set it to `performance`, as requested by AFL.

```
$ cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
powersave
powersave
powersave
powersave
$ echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

&nbsp;

## Preparing the Docker image

Our fuzzing experiments are all done in a dockerized environment.
You can build the Docker image by running the following command:

```
./build.sh
```

or

```
docker build -t llm1dfuzz-artifact -f Dockerfile .
```

This will build the Docker image with the name `llm1dfuzz-artifact` in your local environment within 2 hours.
Note that the size of the Docker image is about 5GB.

&nbsp;

## __Directory structure__


### __Local framework structure__

```
├─ README.md                     <- The top-level README (this file)
│
├─ docker-setup                  <- All scripts and data required to build the Docker image
│  │
│  ├─ benchmark-project          <- Directory to build each benchmark project-wise
│  │  ├─ binutils-2.26
│  │  │  ├─ poc                  <- POC files for each target in binutils-2.26
│  │  │  ├─ seed                 <- Initial seeds for each target in binutils-2.26
│  │  │  └─ build.sh             <- The build script to build binutils-2.26
│  │  ├─ ...
│  │  │
│  │  └─ build-target.sh         <- A wrapper script to build each benchmark project
│  │
│  ├─ target                     <- Target program locations for each target
│  │  └─ line                    <- Target lines
│  │
│  ├─ pre-builts/
│  │  └─ SelectFuzz              <- Implementation of SelectFuzz from GitHub
│  │                                (cuhk-seclab/SelectFuzz: Commit hash 6da35e0)
│  │
│  ├─ tool-script                <- Directory for fuzzing scripts
│  │  └─ run_*.sh                <- The fuzzing scripts to run each fuzzing tool
│  │
│  ├─ build_bench_*.sh           <- The build scripts to build the target programs
│  └─ setup_*.sh                 <- The setup scripts to setup each fuzzing tool
│
├─ output                        <- Directory where outputs are stored
│
├─ scripts                       <- Directory for scripts
│
├─ build.sh                      <- Script to build the Docker image
│
├─ update_seeds.sh               <- Script to update the initial seeds for each target
│
├─ Dockerfile                    <- Docker file used to build the Docker image
│
└─ requirements.txt              <- Python requirements for the scripts
```


### Docker directory structure

```
├─ benchmark                     <- Directory for benchmark data
│  │
│  ├─ bin                        <- Target binaries built for each fuzzing tool
│  │  ├─ AFLpp
│  │  ├─ ASAN
│  │  └─ SelectFuzz
│  │
│  ├─ driver                     <- Fuzz drivers for each target
│  │
│  ├─ target                     <- Target program locations for each target
│  │  └─ line                    <- Target lines
│  │
│  │
│  ├─ poc                        <- Proof of concept inputs for each target
│  │
│  ├─ seed                       <- Seed inputs for each target
│  │
│  ├─ build_bench_*.sh           <- The build scripts to build the target programs
│  │                                for each fuzzing tool
│  │
│  └─ update_seeds.sh            <- The script to update the initial seeds for each target
│
│
├─ fuzzer                        <- Directory for fuzzing tools
│  ├─ AFLpp                      <- AFL++ (v4.07c)
│  ├─ SelectFuzz                 <- SelectFuzz (commit 6da35e0d)
│  └─ setup_*.sh                 <- The setup scripts to setup each fuzzing tool
│
│
└─ tool-script                   <- Directory for fuzzing scripts
   ├─ common_*.sh                <- The files for preparing/processing fuzzing
   └─ run_*.sh                   <- The fuzzing scripts to run each fuzzing tool
```


## __Reproducing the results in the paper__

&nbsp;

### Running the experiment on specific targets

To run the experiment on specific targets, you can run the following command:

```
$ python3 ./scripts/reproduce.py run [target] [timelimit] [iteration] [tool list] [seed mode]
```

For example, to run the experiment on `CVE-2018-11496` in `swftophp-4.7` for `60` seconds with `5` iterations, starting with the initial seed mode `minimal`, and using the tools `AFL++` and `SelectFuzz`, you would use the following command:

```
$ python3 ./scripts/reproduce.py run swftophp-4.7-2016-9827 60 5 "AFLpp SelectFuzz" minimal
```

The result will be parsed and summarized in a CSV file, `swftophp-4.7-2016-9827.csv`, under `output/swftophp-4.7-2016-9827-60sec-5iters-minimal`.

For the available choices of targets, refer to the `FUZZ_TARGETS` and `SELECTFUZZ_TARGETS` in `scripts/benchmark.py`.

Note that to run both `AFL++` and `SelectFuzz` for a specific target, you should check if the target is included in both `FUZZ_TARGETS` and `SELECTFUZZ_TARGETS`.


&nbsp;

### Seed modes

There are 12 seed modes available for the experiment.

- minimal
- llm-best
- llm-worst
- random-1
- random-2
- ...
- random-8
- all

If you are to reproduce a table, you should use `all` for the seed mode.

Otherwise, you can use any of the modes.

&nbsp;

### Running the experiments in each table

To reproduce the results in each table, you can use the script `scripts/reproduce.py` as the following.

```
$ python3 ./scripts/reproduce.py run [table name] [timelimit in seconds] [iterations] all
```

First, the corresponding fuzzing experiment will be run.\
Then the results are saved under `output/[table]-[timelimit]sec-[iteration]iters-all`.\
Finally, the result will be parsed and summarized in a CSV file, `[table].csv`, under the corresponding output directory.

For example, by the following command,

```
$ python3 ./scripts/reproduce.py run table3 86400 5 all
```

`AFL++` will be run on all targets for `24` hours and `5` iterations to reproduce the results in Table 3. The results will be stored under `output/table3-86400sec-5iters-all` and parsed to `output/table3-86400sec-5iters-all/table3.csv`.

Similarly, for the fuzzing results with `SelectFuzz`, you can choose `table4` instead of `table3`.

With 40 fuzzing sessions in parallel, the required time for each experiment is as follows:

- Table 3: 20 days
- Table 4: 17 days

&nbsp;


&nbsp;

### Parsing the results

If you have already run the fuzzing sessions and only want to parse the results, you can run

```
$ python3 ./scripts/reproduce.py parse [table] [timelimit] [iteration] [seed mode]
```

If the corresponding output directory exists in the form of `[table/target]-[timelimit]sec-[iteration]iters-[seedmode]`, the existing fuzzing result will be parsed and summarized in a CSV file, `[table/target].csv`, under the corresponding output directory.
