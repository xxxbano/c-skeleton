echo "Running main function:"

main="bin/main"

if test -f $main
then
	if $VALGRIND ./$main 2>> tests/tests.log
	then
		echo $main PASS
	else
		echo "ERROR in test $main: here's tests/tests.log"
		echo "------"
		tail tests/tests.log
		exit 1
	fi
fi

echo ""
