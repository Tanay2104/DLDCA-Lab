nasm -f elf64 print_cmplx.asm -o ./print_cmplx.o
objcopy --redefine-sym main=print_main print_cmplx.o
nasm -f elf64 cmplx_arith.asm -o cmplx_arith.o
gcc cmplx_arith.o print_cmplx.o -o cmplx_arith -no-pie
rm *.o