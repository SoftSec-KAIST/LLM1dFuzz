# Error when instrumenting PHP with LTO

- When instrumenting PHP-7.3.6 with AFLpp LTO, below error occurs:

```bash
AUTODICTIONARY: 129 strings found
[+] Instrumented 321539 locations (1402 selects) without collisions (256488 collisions have been avoided) (non-hardened mode).
**ld.lld: error: undefined hidden symbol: php_base64_encode_default
>>> referenced by base64.c:231 (ext/standard/base64.c:231)
>>>               lto.tmp:(resolve_base64_encode)

ld.lld: error: undefined hidden symbol: php_base64_decode_ex_default
>>> referenced by base64.c:246 (ext/standard/base64.c:246)
>>>               lto.tmp:(resolve_base64_decode)

ld.lld: error: undefined hidden symbol: php_addslashes_default
>>> referenced by string.c:3911 (ext/standard/string.c:3911)
>>>               lto.tmp:(resolve_addslashes)

ld.lld: error: undefined hidden symbol: php_stripslashes_default
>>> referenced by string.c:3919 (ext/standard/string.c:3919)
>>>               lto.tmp:(resolve_stripslashes)**
clang-12: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [Makefile:245: sapi/cli/php] Error 1
```

- To resolve this error,

https://sourceforge.net/p/mingw-w64/mailman/mingw-w64-public/thread/778a777e-edff-35b6-a30c-85ccbf536ade%40126.com/

says to put `__attribute__((used))` in front of the undefined hidden functions:

- **php_base64_encode_default**
- **php_base64_decode_ex_default**
- **php_addslashes_default**
- **php_stripslashes_default**

- So, I modified the build script to add `__attribute__((used))`  to the above functions with `sed`

```bash
# php-7.3.6/ext/standard/base64.c: 739, 761
sed -i "739i __attribute__((used))" ext/standard/base64.c # encode_default
sed -i "761i __attribute__((used))" ext/standard/base64.c # decode_ex_default

# php-7.3.6/ext/standard/string.c: 4087, 4246
sed -i "4087i __attribute__((used))" ext/standard/string.c # addslashes_default
sed -i "4246i __attribute__((used))" ext/standard/string.c # stripslashes_default
```

| This might not be a perfect fix, but it is a bug of clang and AFL++.
