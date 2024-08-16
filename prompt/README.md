# Prompt Artifact

> This is the artifact for the 3-stage prompt used in our paper.

## System Requirements

To reproduce the results, we assume that you have the following system requirements:

- Ubuntu 18.04
- python 3.8+
- pip3

For the python dependencies, you can install them by running the following command:

```bash
$ yes | pip3 install -r requirements.txt
```

### Inserting the OpenAI API Key

Once you have obtained the OpenAI API key, you should insert it into the `.env` file in this directory.

The `.env` file should contain the following line:

```bash
OPENAI_API_KEY=<YOUR_API_KEY>
```

If you do not have an OpenAI API key, you can obtain one from [OpenAI's website](https://platform.openai.com/docs/overview).


## Directory Structure

This project is organized into several stages, each containing prompts, responses, and other relevant files necessary for processing. Below is a high-level overview of the directory structure.

```
├── common.py               <- Contains common functions used across stages
├── requirements.txt        <- Contains the dependencies required to run the code
├── run_stage1.py           <- Script to run the stage 1 prompt
├── run_stage2.py           <- Script to run the stage 2 prompt
├── run_stage3.py           <- Script to run the stage 3 prompt
├── measure_coverage/       <- Contains files for measuring coverage
│ ├── README.md             <- Contains instructions for measuring coverage
│ ├── minimal_seeds/        <- Contains minimal seeds for fuzzing
│ ├── modified_seeds/       <- Contains generated seeds for fuzzing
| └── scripts/              <- Contains scripts for measuring coverage
├── stage1/                 <- Contains files for stage 1
│ ├── prompts/              <- Contains prompts for stage 1
│ ├── responses/            <- Contains responses for stage 1
│ └── relevant_files/       <- Contains relevant files for stage 1
├── stage2/                 <- Contains files for stage 2
│ ├── prompts/              <- Contains prompts for stage 2
│ ├── responses/            <- Contains responses for stage 2
│ ├── root_causes/          <- Contains root causes for stage 2
│ └── stage1_result/        <- Contains responses generated for stage 1
├── stage3/                 <- Contains files for stage 3
│ ├── prompts/              <- Contains prompts for stage 3
│ ├── responses/            <- Contains generated respronses with stage 3 prompts
│ └── relevant_fields/      <- Contains ground truths of stage 2 prompts
```

## Reproducing the Results

After installing the dependencies, you can run the code for each stage by executing the corresponding script.

For example, to run the code for stage 1, you can use the following command:

```bash
$ python3 run_stage1.py
```

Similarly, you can run the code for stage 2 and stage 3 by executing the following commands:

```bash
$ python3 run_stage2.py
$ python3 run_stage3.py
```

Please note that you need to check the correctness of the responses generated for each stage by comparing them with the ground truth provided in the `root_causes` and `relevant_fields` directories before running the next stage prompts.

To be specific, you should compare the responses generated for stage 1 in the `stage2/stage1_result` directory  with the ground truth provided in the `stage2/root_causes` directory before running stage 2.

Similarly, you should compare the responses generated for stage 2 in the `stage3/stage2_result` directory with the ground truth provided in the `stage3/relevant_fields` directory before running stage 3.


## Processing the Seeds for Fuzzing

Once you have executed the code for all the stages, you can use seeds for fuzzing by processing the hexadecimal values from the responses generated in stage 3.

Since these text files do not consist solely of hexadecimal values, you'll need to extract the relevant hexadecimal portions from them.

You can extract the hexadecimal values into files named `trial-*.txt` located in the `measure_coverage/modified_seeds/program/trials` directory. For detailed instructions on how to perform the extraction, please refer to the `measure_coverage/README.md` file.

For programs that receive text as input, you can extract the generated text inputs into `measure_coverage/modified_seeds/program/seeds` directory.

If you would like to see the seeds that were used in the paper, you can find them in the `measure_coverage/modified_seeds/program/seeds` directory. For minimal seeds, you can refer to the `measure_coverage/minimal_seeds` directory.

