echo "Running main function:"

#for main in tests/*_main
for main in bin/*_main
do
	if test -f $main
	then
		if [ $main = "bin/ex29_main" ]; then
			./$main build/libex29.so print_a_message hello 2>> tests/main.log
			#./$main build/libex29.so print_a_message hello 
		else 
			$VALGRIND ./$main 2>> tests/main.log
		fi

		#echo $?
		#if $VALGRIND ./$main 2>> tests/main.log
		if [ $? = 0 ]; then
			echo $main PASS
		else
			echo "ERROR in run $main: here's tests/main.log"
			echo "------"
			tail tests/main.log
			exit 1
		fi
	fi
done

echo ""
