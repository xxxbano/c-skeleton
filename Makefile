
#==================================================
# Global configuraiton
#==================================================
# OPTFLGAS
# OPTLIBS
CFLAGS = -Wl,--start-group -g -Wall -Wextra -Isrc -rdynamic -DNDEBUG $(OPTFLGAS)
#CFLAGS = -Wl,--start-group -g -Wall -Wextra -Isrc -rdynamic $(OPTFLGAS)
LIBS = -ldl $(OPTLIBS)
PREFIX ?= /usr/local

#==================================================
# funtion library
#==================================================

# get a list of all the .c files in src directory
SOURCES = $(wildcard src/**/*.c src/*.c)
# change the list of .c files into a list of object files
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))

# get a list of all the test .c files in test directory
TEST_SRC = $(wildcard tests/*_tests.c)
# change the list of test .c files into a list of executables 
TESTS = $(patsubst %.c, %, $(TEST_SRC))

#==================================================
# main program
#==================================================

MAIN_SRC = $(wildcard tests/*_main.c)
MAIN = $(patsubst %.c, %, $(MAIN_SRC))

# archive libraries
# - statically linked when you compile your program
# - if there's any change in library, you need to compile and build code again
TARGET = build/libex29.a 
# .so:shared object
# - if there's any change in .so file, you don't need to recompile your main program
# - make sure that your main program is linked to the new .so file
SO_TARGET = $(patsubst %.a, %.so, $(TARGET))

# The Target Build
# - the default target to make
# - execute targets sequencally
all: build $(TARGET) $(SO_TARGET) tests

# make dev with different CFLAGS
dev: CFLAGS = -g -Wall -Isrc -Wall -Wextra $(OPTFLGAS)
dev: all

# build TARGET
# - OBJECTS will be made automatically for building TARGET
# - ar c: create archieve
# - ar r: insert the files into archive
# - ar s: write an object-file index into the archive
# - ranlib: generates an index to the contents of an archive and stores it in the archive
$(TARGET): CFLAGS += -fPIC
$(TARGET): $(OBJECTS)
	ar rcs $@ $(OBJECTS)
	ranlib $@

# build SO_TARGET
#$(SO_TARGET): $(TARGET) $(OBJECTS)
$(SO_TARGET): $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS)

# create build folders
build:
	@mkdir -p build
	@mkdir -p bin

# The Unit Tests
# - first, create test executables
# - call test script to run all executables
# - .PHONY target is one that is not really the name of a file; rather a name for a recipe to be executed when you make an explicit request.
# - the tests target will not work properly if a file named clean is ever created in this directory
# - so .PHONY is to tell make that tests is a recipe intead of a file
.PHONY: tests
tests: CFLAGS += $(TARGET) $(LIBS)
tests:  $(TESTS)  
	sh ./tests/runtests.sh
#tests: CFLAGS += $(TARGET) $(LIBS)
#tests:
#	$(CC) $(CFLAGS) $(TEST_SRC) -ldl -o $(TESTS)
#	sh ./tests/runtests.sh

# The main function 
# - run: make main
main: CFLAGS += $(TARGET) $(LIBS)
main: $(MAIN)
	@mv $(MAIN) ./bin/
	sh ./tests/runmain.sh
#main:
#	$(CC) $(CFLAGS) $(MAIN_SRC) -ldl -o $(MAIN)
#	sh ./tests/runmain.sh

# - run: make valgrind
# a programming tool for memory debugging, memory leak detection and profiling
valgrind:
	VALGRIND = "valgrind --log-file=/tmp/valgrind-%p.log" 
	$(MAKE)

# The Cleaner
# - run: make clean
clean:
	rm -rf bin build $(OBJECTS) $(TESTS) 
	rm -f tests/tests.log tests/main.log
	find . -name "*.gc" -exec rm {} \;
	rm -rf `find . -name "*.dSYM" -print`

# The Install
install: all
	install -d $(DESTDIR)/$(PREFIX)/lib/
	install $(TARGET) $(DESTDIR)/$(PREFIX)/lib/

# The Checker
BADFUNCS = '[^_.>a-zA-Z0-9](str(n?cat|xfrm|n?dup|str|pbrk|tok|_)|stpn?cpy|a?sn?printf|byte_)'
check:
	@echo Files with potentially dangerous functions.
	@egrep $(BADFUNCS) $(SOURCES) || true
