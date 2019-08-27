#include <dlfcn.h>
#include "minunit.h"

typedef int (*lib_function1)(const int *data, const int length);
typedef int (*lib_function2)(const int *data, const int n, const int m);
char *lib_file = "build/lib_test.so";
void *lib = NULL;

int data1[] = {0,2,3,8,1,9,4,6,5}; 
int data2[] = {1,2,3,8,0,9,4,6,5}; 
int data3[] = {8,2,3,0,1,9,4,6,5}; 
int data4[] = {4,2,3,8,1,9,0,6,5}; 
int result[] = {0,1,2,3,4,5,6,8,9}; 
int length = 9;
unsigned int i;

int check_function1(const char *func_to_run, const int *data, const int length)
{
	lib_function1 func = dlsym(lib, func_to_run);
	check(func != NULL, "Did not find %s function in the library %s: %s", func_to_run, lib_file, dlerror());

	func(data, length);

	for(i=0;i<sizeof(data)/sizeof(int);i++)
		check(data[i] == result[i], "Function %s return %d for data: %d", func_to_run, data[i], result[i]);

	return 1;
error:
	return 0;
}

int check_function2(const char *func_to_run, const int *data, const int n, const int m)
{
	lib_function2 func = dlsym(lib, func_to_run);
	check(func != NULL, "Did not find %s function in the library %s: %s", func_to_run, lib_file, dlerror());

	func(data, n, m);

	for(i=0;i<sizeof(data)/sizeof(int);i++)
		check(data[i] == result[i], "Function %s return %d for data: %d, index: %d", func_to_run, data[i], result[i], i);

	return 1;
error:
	return 0;
}

char *test_dlopen()
{
	lib = dlopen(lib_file, RTLD_NOW);
	mu_assert(lib != NULL, "Failed to open the library to test.");
	return NULL;
}


char *test_functions()
{
	mu_assert(check_function1("bsort", data1, length), "print_a_message failed.");
	mu_assert(check_function1("bsort", data2, length), "print_a_message failed.");
	mu_assert(check_function2("msort", data3, 0, length-1), "print_a_message failed.");
	mu_assert(check_function2("msort", data4, 0, length-1), "print_a_message failed.");
	return NULL;
}

char *test_dlclose()
{
	int rc = dlclose(lib);
	mu_assert(rc == 0, "Failed to close lib.");
	return NULL;
}

char *all_tests() {
	mu_suite_start();

	mu_run_test(test_dlopen);
	mu_run_test(test_functions);
	mu_run_test(test_dlclose);

	return NULL;
}

RUN_TESTS(all_tests);
