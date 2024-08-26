from triage import *
from common import SEED_MODES

# (target bin, target cmdline, input src, additional option, triage function)

FUZZ_TARGETS = [
    ("swftophp-4.7-2016-9827", "@@", "file", "", check_swftophp_2016_9827),
    ("lrzip-ed51e14-2018-11496", "-t @@", "file", "", check_lrzip_2018_11496),
    ("cxxfilt-2016-4487", "", "stdin", "", check_cxxfilt_2016_4487),
    ("objcopy-2017-8393", "--compress-debug-sections @@ out", "file", "", check_objcopy_2017_8393),
    ("readelf-2017-16828", "-w @@", "file", "", check_readelf_2017_16828),
    ("xmllint-2017-9047", "--valid @@", "file", "", check_xmllint_2017_9047),
    ("cjpeg-1.5.90-2018-14498", "-outfile /dev/null @@", "file", "", check_cjpeg_2018_14498),
    ("pngimage-2018-13785", "@@", "file", "-t20000", check_pngimage_2018_13785), # timeout option for libpng since some initial seeds get timed out.
    ("tiffcp-2016-10269", "-M @@ /tmp/out", "file", "", check_tiffcp_2016_10269),
    ("sndfile-convert-2018-19758", "@@ /tmp/out.wav", "file", "", check_sndfileconvert_2018_19758),
    ("openssl-2017-3735", "x509 -inform der -in @@ -text", "file", "", check_openssl_2017_3735),
    ("lua-2020-24370", "@@", "file", "", check_lua_2020_24370),
    ("php-2019-11041", "./driver/driver.php @@", "file", "", check_php_2019_11041),
    ("sqlite3-2019-19923", "", "stdin", "", check_sqlite3_2019_19923),
    ("pdfimages-2019-7310", "@@ /dev/null", "file", "", check_pdfimages_2019_7310),
]


SELECTFUZZ_TARGETS = [
    ("swftophp-4.7-2016-9827", "@@", "file", "", check_swftophp_2016_9827),
    ("lrzip-ed51e14-2018-11496", "-t @@", "file", "", check_lrzip_2018_11496),
    ("cxxfilt-2016-4487", "", "stdin", "", check_cxxfilt_2016_4487),
    ("objcopy-2017-8393", "--compress-debug-sections @@ out", "file", "", check_objcopy_2017_8393),
    ("xmllint-2017-9047", "--valid @@", "file", "", check_xmllint_2017_9047),
    ("cjpeg-1.5.90-2018-14498", "-outfile /dev/null @@", "file", "", check_cjpeg_2018_14498),
    ("pngimage-2018-13785", "@@", "file", "-t20000", check_pngimage_2018_13785), # timeout option for libpng since some initial seeds get timed out.
    ("tiffcp-2016-10269", "-M @@ /tmp/out", "file", "", check_tiffcp_2016_10269),
    ("sndfile-convert-2018-19758", "@@ /tmp/out.wav", "file", "", check_sndfileconvert_2018_19758),
    ("lua-2020-24370", "@@", "file", "", check_lua_2020_24370),
    ("sqlite3-2019-19923", "", "stdin", "", check_sqlite3_2019_19923),
    ("pdfimages-2019-7310", "@@ /dev/null", "file", "", check_pdfimages_2019_7310),
]


TEST_TARGETS = [
            ("swftophp-4.7-2016-9827", "@@", "file", "", check_swftophp_2016_9827),
            #            ("lrzip-ed51e14-2018-11496", "-t @@", "file", "", check_lrzip_2018_11496),
            #    ("cjpeg-1.5.90-2018-14498", "-outfile /dev/null @@", "file", "", check_cjpeg_2018_14498),
        #    ("objcopy-2017-8393", "--compress-debug-sections @@ out", "file", "", check_objcopy_2017_8393),
                #    ("openssl-2017-3735", "x509 -inform der -in @@ -text", "file", "", check_openssl_2017_3735),
]


def generate_fuzzing_worklist(benchmark, iteration, seed_mode):
    worklist = []
    if benchmark == "all":
        TARGETS = FUZZ_TARGETS
    elif benchmark == "selectfuzz":
        TARGETS = SELECTFUZZ_TARGETS
    elif benchmark == "test":
        TARGETS = TEST_TARGETS
    else:
        TARGETS = [t for t in FUZZ_TARGETS if t[0] == benchmark]

    for (targ_prog, cmdline, src, additional_option, _) in TARGETS:
        # Check for invalid input sources
        if src not in ["stdin", "file"]:
            print("Invalid input source specified: %s" % src)
            exit(1)

        # Generate iterations for each targets
        # If seed_mode is "all", then run all seed modes
        if seed_mode == "all":
            if "objcopy" in targ_prog: # objcopy only has 8 seeds
                iter_seed_modes = SEED_MODES[:8]
            elif "openssl" in targ_prog: # openssl only has 2 seeds
                iter_seed_modes = SEED_MODES[:2]
            else:
                iter_seed_modes = SEED_MODES

            for mode in iter_seed_modes:
                for i in range(iteration):
                    iter_id = "iter-%d" % i
                    worklist.append((targ_prog, cmdline, src, iter_id, mode, additional_option))

        # Otherwise, run only one seed mode (for specific-target fuzzing)
        else:
            for i in range(iteration):
                iter_id = "iter-%d" % i
                worklist.append((targ_prog, cmdline, src, iter_id, seed_mode, additional_option))


    # Pretty-print all the worklist
    print(f"Worklist:\n" + "\n".join(str(item) for item in worklist))
    # Print all the worklist
#    print("Worklist: %s" % worklist)

    return worklist


def check_targeted_crash(targ, replay_buf):
    for (targ_prog, _, _, _, crash_checker) in FUZZ_TARGETS:
        if targ_prog == targ:
            return crash_checker(replay_buf)
    print("Unknown target: %s" % targ)
    exit(1)
