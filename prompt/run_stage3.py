from common import *
import json

def main():

    client = initialize_openai_client()

    ### Stage 3 ###
    # 1. Load the history from stage1, stage2: prompts and responses
    # 2. Prompt GPT with the history from stage1, 2
    # 3. Save the response of stage3 to a file

    stage = "stage3"
    for program in SUPPORTED_PROGRAMS:
        for i in range (1, 11):
            # 1. Load the history from stage1: prompt and response
            stage1_prompt = open_prompt("stage1", program)
            stage1_response = open_response("stage1", program, i)

            # Build the stage2 prompt
            stage2_prompt = open_prompt("stage2", program)
            if is_stage1_incorrect(program, i):
                # Add the root cause to the prompt if stage1 incorrect
                root_cause = open_root_cause("stage2", program)
                stage2_prompt = root_cause + "\n\n" + stage2_prompt
                
            stage2_response = open_response("stage2", program, i)


            # Stage3 prompt should contain:
            # a) stage1 prompt 
            # b) stage1 response 
            # c) stage1's ground truth if stage1 is incorrect
            # d) stage2 prompt 
            # e) stage2 response
            # f) stage2's ground truth if stage2 is incorrect
            history = [
                {"role": "user", "content": stage1_prompt}, # a) stage1 prompt
                {"role": "assistant", "content": stage1_response}, # b) stage1 response
                {"role": "user", "content": stage2_prompt}, # c) stage1 ground truth, d) stage2 prompt
                {"role": "assistant", "content": stage2_response}, # e) stage2 response
            ]

            # 2. Prompt GPT with the history from stage1, 2
            stage3_prompt = open_prompt(stage, program)
            if is_stage2_incorrect(program, i):
                # Add the relevant field to the prompt if stage2 incorrect
                relevant_field = open_relevant_field(stage, program) # f) stage2's ground truth if stage2 is incorrect
                stage3_prompt = relevant_field + "\n\n" + stage3_prompt

            stage3_message = history.copy()
            stage3_message.append({"role": "user", "content": stage3_prompt})

            response = send_prompt(client, stage3_message, i)
            print("\n\n[*] Stage3 Response: \n", response)

            # 3. Save the response to a file
            save_response(stage, program, response, i)


if __name__ == "__main__":
    main()
