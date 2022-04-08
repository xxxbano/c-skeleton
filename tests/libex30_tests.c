#include <dlfcn.h>
#include "minunit.h"

typedef int (*lib_function)(const char *data);
// shared object name
char *lib_file = "build/libex29.so";
void *lib = NULL;

// check_function needs to be properly designed
int check_function(const char *func_to_run, const char *data, int expected)
{
	lib_function func = dlsym(lib, func_to_run);
	check(func != NULL, "Did not find %s function in the library %s: %s", func_to_run, lib_file, dlerror());

	int rc = func(data);
	check(rc == expected, "Function %s return %d for data: %s", func_to_run, rc, data);

	return 1;
error:
	return 0;
}

// open 
char *test_dlopen()
{
	// loads the dynamic library file named by the null-terminated string filename
	// returns an opaque 'handle' for dynamic library
	lib = dlopen(lib_file, RTLD_NOW);
	// return message if lib!=NULL failed.
	mu_assert(lib != NULL, "Failed to open the library to test.");
	return NULL;
}

char *test_functions()
{
	// return message if check_function failed.
	mu_assert(check_function("print_a_message", "Hello", 0), "print_a_message failed.");
	mu_assert(check_function("uppercase", "Hello", 0), "uppercase failed.");
	mu_assert(check_function("lowercase", "Hello", 0), "lowercase failed.");
	return NULL;
}

char *test_failures()
{
	// return message if check_function failed.
	mu_assert(check_function("fail_on_purpose", "Hello", 1), "fail_on_purpose should fail.");
	return NULL;
}

char *test_dlclose()
{
	int rc = dlclose(lib);
	// return message if rc==0 failed.
	mu_assert(rc == 0, "Failed to close lib.");
	return NULL;
}

char *all_tests() {
	// define message pointer
	mu_suite_start();

	// test_* return a message pointer to a specific message if test failed, otherwise NULL
	mu_run_test(test_dlopen);
	mu_run_test(test_functions);
	mu_run_test(test_failures);
	mu_run_test(test_dlclose);

	return NULL;
}

// all_tests() return NULL if all tests passed
RUN_TESTS(all_tests);
