#include <iostream>
#include <chrono>
#include <cmath>
#include "../common/matrix.hpp"

#define epsilon 0.00001

int main() {

    matrix* A = new matrix(100, 100);
    matrix* B = new matrix(100, 100);
    for (uint64_t i = 0; i < 100; i++) {
        for (uint64_t j = 0; j < 100; j++) {
            *(A->element(i, j)) = (rand() % 100)/100.0;
            *(B->element(i, j)) = (rand() % 100)/100.0;
        }
    }
    matrix* C = new matrix(65,65);
    for (uint64_t i = 0; i < 65; i++) {
        for (uint64_t j = 0; j < 65; j++) {
            *(C->element(i, j)) = (rand() % 100)/100.0;
        }
    }
    auto start = std::chrono::high_resolution_clock::now();
    matrix* At = outer(A,B);
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> duration = end - start;
    for (uint64_t i = 0; i < 100; i++) {
        for (uint64_t j = 0; j < 100; j++) {
            for (uint64_t p = 0; p < 100; p++) {
                for (uint64_t q = 0; q < 100; q++) {
                    if (fabs(*(At->element(i * 100 + p, j * 100 + q)) - (*(A->element(i, j))) * (*(B->element(p, q)))) > epsilon) {
                        std::cout << "Outer Product Error at (" << i << ", " << j << ", " << p << ", " << q << ")\n";
                        exit(1);
                    }
                }
            }
        }
        // std::cout << "\n";
    }
    std::cout << "Outer Product Time: " << duration.count() << " ms\n";

    matrix* nA = new matrix(800, 800);
    matrix* nC = new matrix(129, 129);
    for (uint64_t i = 0; i < 800; i++) {
        for (uint64_t j = 0; j < 800; j++) {
            *(nA->element(i, j)) = (rand() % 100)/100.0;
        }
    }
    for (uint64_t i = 0; i < 129; i++) {
        for (uint64_t j = 0; j < 129; j++) {
            *(nC->element(i, j)) = (rand() % 100)/100.0;
        }
    }

    start = std::chrono::high_resolution_clock::now();
    matrix* D = convolve(nA, nC);
    end = std::chrono::high_resolution_clock::now();
    std::cout << "Convolution Done\n";
    duration = end - start;
    for (uint64_t i = 64; i < 800 - 64; i++) {
        for (uint64_t j = 64; j < 800 - 64; j++) {
            double sum = 0.0;
            for (int k = -64; k <= 64; k++) {
                for (int l = -64; l <= 64; l++) {
                    sum += (*(nA->element(i + k, j + l))) * (*(nC->element(k + 64, l + 64)));
                }
            }
            // std::cout << *(D->element(i, j)) << " " << sum << "\n";
            if (fabs(*(D->element(i, j)) - sum) > epsilon) {
                std::cout << "Convolution Error at (" << i << ", " << j << ") Expected " << sum << " got " << *(D->element(i, j)) << "\n";
                exit(1);
            }
        }
        // std::cout << "\n";
    }
    std::cout << "Convolution Time: " << duration.count() << " ms\n";
    start = std::chrono::high_resolution_clock::now();
    matrix* E = weirdMul(A, B);
    end = std::chrono::high_resolution_clock::now();
    duration = end - start;
    for (uint64_t i = 0; i < 100; i++) {
        for (uint64_t j = 0; j < 100; j++) {
            double val = 0;
            for (uint64_t k = 0; k < 100; k++) {
                if (*(A->element(i,k)) > 0.5) {
                    val += (*(A->element(i, k))) * (*(B->element(k, j)));
                }
                else {
                    val -= (1 - *(A->element(i, k))) * (*(B->element(k, j)));
                }
            }
            if (fabs(*(E->element(i, j)) - val) > epsilon) {
                std::cout << "Weird Multiplication Error at (" << i << ", " << j << ") Expected " << val << " got " << *(E->element(i, j)) <<  "\n";
                exit(1);
            }
        }
        // std::cout << "\n";
    }
    std::cout << "Weird Multiplication Time: " << duration.count() << " ms\n";
    return 0;

}