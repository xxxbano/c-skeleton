#ifndef __dbg_h__
#define __dbg_h__

#include <stdio.h>
#include <string.h>
#include <errno.h>

#ifdef NDEBUG
#define debug(M, ...)
#else
// - show file name and line # with a string M
// - __VA_ARGS__ refers back again to the variable arguments in the macro itself
// - example:
// debug("----- RUNNING: %s", argv[0]); =>
// fprintf(stderr, "DEBUG %s:%d: " ----- RUNNING: %s "\n", __FILE__, __LINE__, argv[0])
#define debug(M, ...) fprintf(stderr, "DEBUG %s:%d: " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#endif

// errno: error errnum
// strerror() returns a pointer to the error string describing errno
#define clean_errno() (errno == 0 ? "None" : strerror(errno))

// log 
#define log_err(M, ...) fprintf(stderr, "[ERROR] (%s:%d: errno: %s) " M "\n", __FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
#define log_warn(M, ...) fprintf(stderr, "[WARN] (%s:%d: errno: %s) " M "\n", __FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
#define log_info(M, ...) fprintf(stderr, "[INFO] (%s:%d) " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)

// check
#define check(A, M, ...) if(!(A)) { log_err(M, ##__VA_ARGS__); errno=0; goto error;}
#define check_mem(A) check((A), "Out of memory.")

// put sentinel() at some places never should go
#define sentinel(M, ...) { log_err(M, ##__VA_ARGS__); errno=0; goto error;}

#define check_debug(A, M, ...) if(!(A)) { debug(M, ##__VA_ARGS__); errno=0; goto error;}

#endif
