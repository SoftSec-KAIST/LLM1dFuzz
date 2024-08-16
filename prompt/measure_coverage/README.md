# Measure Coverage of Seeds

> This directory contains the seeds used in the paper and scripts to measure the coverage of the seeds.

## Directory Structure

```
├── minimal_seeds/              <- Minimal seeds created by the authors
├── modified_seeds/             <- Seeds modified from the minimal seeds by the LLM
│   ├── cxxfilt/
│   │   └── seeds/              <- Seeds that can be used for fuzzing
│   ├── libjpeg/
│   │   ├── generate_bmps.sh    <- Script to convert hex in txt files to BMP
│   │   ├── hex_to_bmp.py       <- Script to convert hex in txt files to BMP
│   │   ├── seeds/              <- Seeds that can be used for fuzzing
│   │   └── trials/             <- Text files containing hexadecimals of each trial
│   ├── ...
│   └── sqlite3/
│       └── seeds/              <- Seeds that can be used for fuzzing
└── scripts/
    ├── measure_all.sh          <- Script to measure coverage of all seeds
    ├── build_targets/          <- Scripts to build targets
    └── coverage_summaries/     <- Summaries of coverage measurements
```

## How to Measure Coverage of Seeds

Super simple! Just run the following command in the scripts directory:

```bash
$ ./measure_all.sh
```

It will build the seeds and measure the coverage of each seed. The coverage summaries will be saved in the `coverage_summaries/` directory. Note that it will take a while to finish the process.


## How to Convert Hexadecimals in Text to Binary

You can use the script named `generate_*.sh` to convert hexadecimals in text to binary.

For example, to convert hexadecimals in `libjpeg/trials/` to bmp files, run the following command:

```bash
$ modified_seeds/libjpeg/generate_bmps.sh
```

The script will convert all the hexadecimals stored in the txt files in `libjpeg/trials/` to bmp files by running `hex_to_bmp.py` script.

