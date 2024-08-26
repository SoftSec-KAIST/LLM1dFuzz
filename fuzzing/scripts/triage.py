import re
TOP_SIG = " #0 "

def warn(msg, buf):
    # print("[Warning]: %s" % msg)
    # print("Check the following replay log:")
    # print(buf)
    pass


# Obtain the function where the crash had occurred.
def get_crash_func(buf):
    match = re.search(r"#0 0x[0-9a-f]+ in [\S]+", buf)
    if match is None:
        return ""
    start_idx, end_idx = match.span()
    line = buf[start_idx:end_idx]
    return line.split()[-1]

# Get the direct caller of the function that crashed.
def get_crash_func_caller(buf):
    match = re.search(r"#1 0x[0-9a-f]+ in [\S]+", buf)
    if match is None:
        return ""
    start_idx, end_idx = match.span()
    line = buf[start_idx:end_idx]
    return line.split()[-1]


# Helper function for for-all check.
def check_all(buf, checklist):
    for str_to_check in checklist:
        if str_to_check not in buf:
            return False
    return True


# Helper function for if-any check.
def check_any(buf, checklist):
    for str_to_check in checklist:
        if str_to_check in buf:
            return True
    return False


def check_cxxfilt_2016_4487(buf):
    if get_crash_func(buf) == "register_Btype":
        if "cplus-dem.c:4319" in buf:
            return True
        else:
            warn("Unexpected crash point in register_Btype()", buf)
            return False
    else:
        return False


def check_swftophp_2016_9827(buf):
    if "heap-buffer-overflow" in buf:
        if "outputscript.c:1687:" in buf:
            return True
    return False


def check_lrzip_2018_11496(buf):
    if "heap-use-after-free" in buf:
        if "stream.c:1756" in buf:
            # Not sure about this caller. Conservatively say no.
            if "read_u32" in buf:
                return False
            elif "read_header" in buf:
                return True
            else:
                warn("Unexpected stack trace", buf)
        elif get_crash_func(buf) == "read_stream" :
            warn("Unexpected crash point in read_stream", buf)
    return False


def check_objcopy_2017_8393(buf):
    if "global-buffer-overflow" in buf:
        if "_bfd_elf_get_reloc_section" in buf:
            return True
    return False


def check_readelf_2017_16828(buf):
    if "heap-buffer-overflow" in buf:
        if "display_debug_frames" in buf:
            return True
    return False


def check_xmllint_2017_9047(buf):
    if "stack-buffer" in buf: # Both over- and under-flow.
        if "valid.c:1279:" in buf:
            return True
    return False


def check_cjpeg_2018_14498(buf):
    if "heap-buffer-overflow" in buf:
        if "rdbmp.c:209:" in buf:
            return True
        elif get_crash_func(buf) == "get_8bit_row":
            warn("Unexpected crash point in get_8bit_row", buf)
    return False


def check_pngimage_2018_13785(buf):
    if "FPE" in buf:
        if "pngrutil.c:3172:" in buf:
            return True
        elif get_crash_func(buf) == "png_check_chunk_length":
            warn("Unexpected crash point in png_check_chunk_length", buf)
    else:
        return False


def check_tiffcp_2016_10269(buf):
    if "heap-buffer-overflow" in buf:
        if "tif_dirwrite.c:1842:" in buf:
            return True
    return False


def check_sndfileconvert_2018_19758(buf):
    if "heap-buffer-overflow" in buf:
        if "wav.c:1100:" in buf:
            return True
    return False


def check_openssl_2017_3735(buf):
    if "heap-buffer-overflow" in buf:
        if "v3_addr.c:89:" in buf:
            return True
    return False


def check_lua_2020_24370(buf):
    if "SEGV" in buf:
        if "ldebug.c:241:" in buf:
            return True
    return False


def check_php_2019_11041(buf):
    if "heap-buffer-overflow" in buf:
        if "exif.c:3898:" in buf:
            return True
    return False


def check_sqlite3_2019_19923(buf):
    if "SEGV" in buf:
        if "sqlite3.c:86423:" in buf:
            return True
    return False


def check_pdfimages_2019_7310(buf):
    if "heap-buffer-overflow" in buf:
        if "XRef.cc:1568:" in buf:
            return True
    return False


def check_TODO(buf):
    print("TODO: implement triage logic")
    return False
