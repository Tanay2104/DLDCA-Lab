touch test_fib.txt
> test_fib.txt
for i in {1..30}
do
	echo $i |  ./loops >> test_fib.txt
	echo >> test_fib.txt
done
