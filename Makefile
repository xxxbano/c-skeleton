CFLAGS = -Wl,--start-group -g -Wall -Wextra -Isrc -rdynamic -DNDEBUG $(OPTFLGAS)
OPTFLGAS =
LIBS = -ldl $(OPTLIBS)
OPTLIBS =
PREFIX ?= /usr/local

SOURCES = $(wildcard src/**/*.c src/*.c)
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))

TEST_SRC = $(wildcard tests/*_tests.c)
TESTS = $(patsubst %.c, %, $(TEST_SRC))

MAIN_SRC = $(wildcard tests/main.c)
#MAIN = $(patsubst %.c, %, $(MAIN_SRC))
MAIN = bin/main

TARGET = build/libex29.a 
SO_TARGET = $(patsubst %.a, %.so, $(TARGET))

# The Target Build
all: $(TARGET) $(SO_TARGET) tests

dev: CFLAGS = -Wl,--start-group -g -Wall -Isrc -Wall -Wextra $(OPTFLGAS)
dev: all

$(TARGET): CFLAGS += -fPIC
$(TARGET): build $(OBJECTS)
	ar rcs $@ $(OBJECTS)
	ranlib $@

$(SO_TARGET): $(TARGET) $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS)

build:
	@mkdir -p build
	@mkdir -p bin

# The Unit Tests
.PHONY: tests
tests: CFLAGS += $(TARGET) $(LIBS)
#tests:
#	$(CC) $(CFLAGS) $(TEST_SRC) -ldl -o $(TESTS)
#	sh ./tests/runtests.sh
tests:  $(TESTS)  
	sh ./tests/runtests.sh

# The main function
main: CFLAGS += $(TARGET) $(LIBS)
main:
	$(CC) $(CFLAGS) $(MAIN_SRC) -ldl -o $(MAIN)
	sh ./tests/runmain.sh

valgrind:
	VALGRIND = "valgrind --log-file=/tmp/valgrind-%p.log" $(MAKE)

# The Cleaner
clean:
	rm -rf build bin $(OBJECTS) $(TESTS)
	rm -f tests/tests.log
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