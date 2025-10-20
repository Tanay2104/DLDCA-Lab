all: mask

mask: mask.cpp
	$(CXX) -O0 -mavx -mfma mask.cpp -o mask

clean:
	rm -f mask