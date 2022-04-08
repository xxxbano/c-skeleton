echo "Running unit tests:"

for i in tests/*_tests
do
	# test file exist
	if test -f $i
	then
		# VALGRIND doesn't seem to work
		# 1>> append from current stdout handler to file
		# 2>> append from current stderr handler to file
		if $VALGRIND ./$i 2>> tests/tests.log
		then
			echo $i PASS
		else
			echo "ERROR in test $i: here's tests/tests.log"
			echo "------"
			tail tests/tests.log
			exit 1
		fi
	fi
done

echo ""
