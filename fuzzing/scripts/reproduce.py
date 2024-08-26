import sys, os, time, csv, shutil
from common import run_cmd, run_cmd_in_docker, check_cpu_count, fetch_works, MEM_PER_INSTANCE, IMAGE_NAME, SUPPORTED_TOOLS, SEED_MODES
from benchmark import generate_fuzzing_worklist, FUZZ_TARGETS, SELECTFUZZ_TARGETS, TEST_TARGETS
from parse_result import print_result
import copy

BASE_DIR = os.path.join(os.path.dirname(__file__), os.pardir)

def decide_outdir(target, timelimit, iteration, tool, seed_mode):
    name = "%s-%ssec-%siters-%s" % (target, timelimit, iteration, seed_mode)
    if target == "origin":
        outdir = os.path.join(BASE_DIR, "output", "origin")
    elif tool == "":
        outdir = os.path.join(BASE_DIR, "output", name) # We usually use this one.
    else:
        outdir = os.path.join(BASE_DIR, "output", name, tool)
    os.makedirs(outdir, exist_ok=True)
    return outdir


def spawn_containers(works):
    for i in range(len(works)):
        targ_prog, _, _, iter_id, seed_mode, _ = works[i]
        cmd = "docker run --tmpfs /box:exec --rm -m=%dg --cpuset-cpus=%d -it -d --name %s-%s-%s %s" \
                % (MEM_PER_INSTANCE, i, targ_prog, iter_id, seed_mode, IMAGE_NAME)
        run_cmd(cmd)


def run_fuzzing(works, tool, timelimit):
    for (targ_prog, cmdline, src, iter_id, seed_mode, additional_option) in works:
        cmd = "/tool-script/run_%s.sh %s \"%s\" %s %d %s %s" % \
                (tool, targ_prog, cmdline, src, timelimit, seed_mode, additional_option)
        run_cmd_in_docker("%s-%s-%s" % (targ_prog, iter_id, seed_mode), cmd, True)


def wait_finish(works, timelimit):
    time.sleep(timelimit)
    total_count = len(works)
    elapsed_min = 0
    while True:
        if elapsed_min > 120:
            break
        time.sleep(60)
        elapsed_min += 1
        print("Waited for %d min" % elapsed_min)
        finished_count = 0
        for (targ_prog, _, _, iter_id, seed_mode, _) in works:
            container = "%s-%s-%s" % (targ_prog, iter_id, seed_mode)
            stat_str = run_cmd_in_docker(container, "cat /STATUS", False)
            if "FINISHED" in stat_str:
                finished_count += 1
            else:
                print("%s-%s-%s not finished" % (targ_prog, iter_id, seed_mode))
        if finished_count == total_count:
            print("All works finished!")
            break


def store_outputs(works, outdir):
    for (targ_prog, _, _, iter_id, seed_mode, _) in works:
        container = "%s-%s-%s" % (targ_prog, iter_id, seed_mode)
        cmd = "docker cp %s:/output %s/%s" % (container, outdir, container)
        run_cmd(cmd)


def cleanup_containers(works):
    for (targ_prog, _, _, iter_id, seed_mode, _) in works:
        cmd = "docker kill %s-%s-%s" % (targ_prog, iter_id, seed_mode)
        run_cmd(cmd)


def main():
    if len(sys.argv) < 5:
        print("Usage: %s <run/parse> <table/target name> <time> <iterations> \"<tool list>\" <seed-mode> " % sys.argv[0])
        exit(1)

    check_cpu_count()

    action = sys.argv[1]
    if action not in ["run", "parse"]:
        print("Invalid action! Choose from [run, parse]" )
        exit(1)

    target = sys.argv[2]
    timelimit = int(sys.argv[3])
    iteration = int(sys.argv[4])
    target_list = ""
    tools_to_run = tools = []
    if sys.argv[5] not in SUPPORTED_TOOLS:
        seed_mode = sys.argv[5]
    else:
        seed_mode = sys.argv[6] # For single target program fuzzing

    # python3 ./reproduce.py parse origin-table3 86400 5
    if "origin" in target:
        if action == "run":
            print("Invalid action for origin!")
            exit(1)

        target_list = [x for (x,y,z,w,_) in FUZZ_TARGETS]
        target = target.split("-")[1]

        if target == "table3":
            benchmark = "all"
            tools += ["AFLpp"]
            seed_mode = "all"

        elif target == "table4":
            benchmark = "selectfuzz"
            tools += ["SelectFuzz"]
            seed_mode = "all"

        else:
            print("Invalid target!")
            exit(1)

    # python3 ./reproduce.py run test ~~
    elif target == "test":
        target = "lrzip-ed51e14-2018-11496"
        benchmark = target
        target_list = [target]
        tools += ["AFLpp", "DAFL"]
        seed_mode = "minimal"

    # python3 ./reproduce run swftophp-4.7-2016-9827 86400 10 "AFLpp DAFL" minimal
    elif target in [x for (x,y,z,w,_) in FUZZ_TARGETS]:
        benchmark = target
        target_list = [target]

        seed_mode = sys.argv[6]

        if len(sys.argv) == 7:
            tools += sys.argv[5].split()
            if not all([x in SUPPORTED_TOOLS for x in tools]):
                print("Invalid tool in the list! Choose from %s" % SUPPORTED_TOOLS)
                exit(1)
        else:
            tools += SUPPORTED_TOOLS

    # Run of Parse without origin data
    # python3 ./reproduce.py run table3 86400 5 all
    elif target == "table3":
#        benchmark = "all"
        benchmark = "test"
#        target_list = [x for (x,y,z,w,_) in FUZZ_TARGETS]
        target_list = [x for (x,y,z,w,_) in TEST_TARGETS]
        tools += ["AFLpp"]
        seed_mode = "all"

    elif target == "table4":
        benchmark = "selectfuzz"
        target_list = [x for (x,y,z,w,_) in SELECTFUZZ_TARGETS]
        tools += ["SelectFuzz"]
        seed_mode = "all"

    else:
        print("Invalid target!")
        exit(1)


    if seed_mode != "all" and seed_mode not in SEED_MODES:
        print("Invalid seed_mode! Choose from %s" % SEED_MODES)
        exit(1)


    ### 1. Run fuzzing
    if action == "run":
        for tool in tools_to_run:
            worklist = generate_fuzzing_worklist(benchmark, iteration, seed_mode)
            outdir = decide_outdir(target, str(timelimit), str(iteration), tool, seed_mode)
            while len(worklist) > 0:
                works = fetch_works(worklist)

                spawn_containers(works)
                run_fuzzing(works, tool, timelimit)
                wait_finish(works, timelimit)
                store_outputs(works, outdir)
                cleanup_containers(works)

                #### Reset timelimit to user input
                timelimit = int(sys.argv[3])

    if "origin" in sys.argv[2]:
        outdir = decide_outdir("origin", "", "", "", "")
    else:
        outdir = decide_outdir(target, str(timelimit), str(iteration), "", seed_mode)

    ### 2. Parse and print results in CSV and TSV format
    print_result(outdir, target, target_list, timelimit, iteration, tools, seed_mode)


if __name__ == "__main__":
    main()
