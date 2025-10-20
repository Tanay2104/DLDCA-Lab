#include <iostream>
#include "../common/matrix.hpp"
using namespace std;

int main() {
    uint64_t xdim, ydim;
    cin >> xdim >> ydim;
    matrix* img = new matrix(xdim, ydim);
    matrix* kernel = new matrix(3, 3);
    for (int i=0; i < 3; i++) {
        for (int j=0; j < 3; j++) {
            *(kernel->element(i, j)) = -1.0/9.0;
        }
    }
    *(kernel->element(1,1)) = 16.0/9.0;
    for (uint64_t i=0; i < xdim; i++) {
        for (uint64_t j=0; j < ydim; j++) {
            cin >> *(img->element(i, j));
        }
    }
    matrix* out = convolve(img, kernel);
    for (uint64_t i=0; i < xdim; i++) {
        for (uint64_t j=0; j < ydim; j++) {
            cout << *(out->element(i, j)) << " ";
        }
    }
}