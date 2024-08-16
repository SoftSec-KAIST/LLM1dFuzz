from common import *

def main():

    client = initialize_openai_client()

    ### Stage 1 ###
    # 1. Prompt GPT with the program-specific prompt
    # 2. Save the response to a file

    stage = "stage1"
    for program in SUPPORTED_PROGRAMS:
        for i in range (1, 11):
            stage1_prompt = open_prompt(stage, program)
            
            stage1_message = [
                {"role": "user", "content": stage1_prompt}
            ]

            # 1. Prompt GPT with the program-specific prompt
            response = send_prompt(client, stage1_message, i)
            print("\n\n[*] Stage1 Response: \n", response)

            # 2. Save the response to a file
            save_response(stage, program, response, i)


if __name__ == "__main__":
    main()
