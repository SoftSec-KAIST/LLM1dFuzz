from openai import OpenAI
from pathlib import Path
import requests
import json
import os
from dotenv import load_dotenv

DAFL_BENCHMARK = ["libming", "lrzip", "libxml2", "libjpeg", "cxxfilt", "objcopy", "readelf"]
MAGMA_BENCHMARK = ["libpng", "libtiff", "libsndfile", "openssl", "lua", "php", "sqlite3", "poppler"]
SUPPORTED_PROGRAMS = DAFL_BENCHMARK + MAGMA_BENCHMARK
# SUPPORTED_PROGRAMS = ["libming"] # For debugging

def initialize_openai_client():
    # Load OpenAI API key from the .env file
    load_dotenv()  

    api_key = os.getenv("OPENAI_API_KEY")
    client = OpenAI(api_key=api_key)

    return client


def open_prompt(stage, program):
    # './stage1/prompts/libming.txt'
    file_path = './' + stage + '/prompts/' + program + '.txt'
    with open(file_path, 'r') as file:
        prompt = file.read().strip()

    return prompt


def open_response(stage, program, iter_num):
    # './stage1/responses/libming/response-1.txt'
    file_path = './' + stage + '/responses/' + program + '/response-' + str(iter_num) + '.txt'
    with open(file_path, 'r') as file:
        response = file.read().strip()

    return response


def open_root_cause(stage, program):
    # './stage2/root_causes/libming.txt'
    file_path = './' + stage + '/root_causes/' + program + '.txt'
    with open(file_path, 'r') as file:
        root_cause = file.read().strip()

    return root_cause


def open_relevant_field(stage, program):
    # './stage2/relevant_fields/libming.txt'
    file_path = './' + stage + '/relevant_fields/' + program + '.txt'
    with open(file_path, 'r') as file:
        relevant_field = file.read().strip()

    return relevant_field


def send_prompt(client, prompt, seed_value):

    print("[*] Sending Prompt: \n", json.dumps(prompt, indent=4))

    # Send the prompt to GPT-4-0125-preview Turbo model
    completion = client.chat.completions.create(
        model="gpt-4-0125-preview", # GPT-4 Turbo
        messages=prompt,
        seed=seed_value,
        temperature=1, # default value
        top_p=1, # default value
    )

    return completion.choices[0].message.content


def save_response(stage, program, response, iter_num):
    # Make a directory if there isn't
    Path('./' + stage + '/responses/' + program).mkdir(parents=True, exist_ok=True)

    filename = "response-" + str(iter_num) + ".txt"
    filepath = './' + stage + '/responses/' + program + '/' + filename
    with open(filepath, "w") as file:
        file.write(str(response))

    print("\n[*] Saved response to " + filename + "\n")


def is_stage1_incorrect(program, iter_num):
    # './stage2/stage1_result/libming.txt'
    file_path = './stage2/stage1_result/' + program + '.txt'
    with open(file_path, 'r') as file:
        result = file.read().splitlines()
    
    result = ["dummy"] + result

    return result[iter_num] == "incorrect"


def is_stage2_incorrect(program, iter_num):
    # './stage3/stage2_result/libming.txt'
    file_path = './stage3/stage2_result/' + program + '.txt'
    with open(file_path, 'r') as file:
        result = file.read().splitlines()
    
    result = ["dummy"] + result

    return result[iter_num] == "incorrect"
