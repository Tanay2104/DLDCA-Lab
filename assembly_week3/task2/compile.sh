nasm -f elf64 print_cmplx.asm -o print_cmplx.o
objcopy --redefine-sym main=print_main print_cmplx.o
nasm -f elf64 polars_to_rect.asm -o polars_to_rect.o
gcc polars_to_rect.o print_cmplx.o -o polars_to_rect -no-pie
rm *.o

