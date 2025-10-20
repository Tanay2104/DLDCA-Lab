all: naive optim image-convolve

naive: naive.cpp main.cpp ../common/matrix.hpp
	g++ -O0 -o naive naive.cpp main.cpp

optim: optim.cpp main.cpp ../common/matrix.hpp
	g++ -O0 -mfma -mavx -o optim optim.cpp main.cpp

image-convolve: image-convolve.cpp ../common/matrix.hpp
	g++ -O0 -o image-convolve image-convolve.cpp naive.cpp

clean:
	rm -f naive optim image-convolve 