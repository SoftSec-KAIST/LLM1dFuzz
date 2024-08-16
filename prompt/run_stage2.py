from common import *
import json

def main():

    client = initialize_openai_client()

    ### Stage 2 ###
    # 1. Load the history from stage1: prompt and response
    # 2. Prompt GPT with the history from stage1 and stage2 prompt
    # 3. Save the response of stage2 to a file

    stage = "stage2"
    for program in SUPPORTED_PROGRAMS:
        for i in range (1, 11):
            # 1. Load the history from stage1: prompt and response
            stage1_prompt = open_prompt("stage1", program)
            stage1_response = open_response("stage1", program, i)

            # Stage2 prompt should contain:
            # a) stage1 prompt 
            # b) stage1 response 
            # c) stage1's ground truth if stage1 is incorrect
            # d) stage2 prompt 
            history = [
                {"role": "user", "content": stage1_prompt}, # a) stage1 prompt
                {"role": "assistant", "content": stage1_response}, # b) stage1 response
            ]

            # 2. Prompt GPT with the history from stage1
            stage2_prompt = open_prompt(stage, program) # d) stage2 prompt
            if is_stage1_incorrect(program, i):
                # Add the root cause to the prompt if stage1 incorrect
                root_cause = open_root_cause(stage, program) # c) stage1's ground truth if stage1 is incorrect
                stage2_prompt = root_cause + "\n\n"  + stage2_prompt 
                

            stage2_message = history.copy()
            stage2_message.append({"role": "user", "content": stage2_prompt})

            response = send_prompt(client, stage2_message, i)
            print("\n\n[*] Stage2 Response: \n", response)

            # 3. Save the response to a file
            save_response(stage, program, response, i)


if __name__ == "__main__":
    main()
