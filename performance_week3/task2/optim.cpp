/*

This file contains implementationss for:
1. Outer product of 2 matrices
2. Convolution of 2 matrices
3. Wierd multiplication of a matrix

*/

#include "../common/matrix.hpp"
#include <cmath>
#include <immintrin.h>
#include <iostream>

matrix* outer(matrix *a, matrix *b) {
    auto [r1, c1] = a->size();
    auto [r2, c2] = b->size();
    matrix *res = new matrix(r1 * r2, c1 * c2);
    // compute res
    __m256d q4;
    for (uint64_t i=0; i < r1; ++i) {
        for (uint64_t j=0; j < c1; j++) {
            for (uint64_t p=0; p < r2; p++) {
                for (uint64_t q=0; q < c2/4; q+=1) {
                   q4 = _mm256_loadu_pd(b->element(p, q*4));
                   _mm256_storeu_pd(res->element(i*r2+p, j*c2+q*4),  
                    _mm256_mul_pd(_mm256_set1_pd(*(a->element(i,j))), q4) );
                }
                for (uint64_t q=(c2/4)*4; q < c2; q++) {
                    *(res->element(i * r2 + p, j * c2 + q)) = (*(a->element(i, j))) * (*(b->element(p, q)));
                }
            }
        }
    }
    return res;
}

matrix* convolve(matrix* a, matrix* b) {
    // output matrix dim must be same as a-> dim
    // and a->dim must be greater than b->dim
    auto [r1, c1] = a->size();
    auto [r2, c2] = b->size();
    if (r1 < r2 || c1 < c2) {
        return nullptr; // Dimension mismatch   
    }
    if (r2 % 2 == 0 || c2 % 2 == 0) {
        return nullptr; // Kernel dimensions must be odd
    }
    double* temp = new double[4];
    matrix* res = new matrix(r1, c1);
    __m256d running_sum, a4, b4;
    for (int i = (r2 - 1)/2; i < r1 - (r2 - 1)/2; i++) {
        for (int j = (c2 - 1)/2; j < c1 - (c2 - 1)/2; j++) {
            double sum = 0.0;
            for (int k = -((int64_t)r2 - 1)/2; k <= ((int64_t)r2 - 1)/2; k++) {
                running_sum = _mm256_setzero_pd();
                int l;
                int l_bound = ((int64_t)c2 - 1)/2;
                for (l = -l_bound; l < l_bound - 3; l+=4) {
                    a4 = _mm256_loadu_pd(a->element(i+k, j+l));
                    b4 = _mm256_loadu_pd(b->element(k + (r2 - 1)/2, l + l_bound));
                    running_sum = _mm256_fmadd_pd(a4, b4, running_sum);
                    // sum += (*(a->element(i + k, j + l))) * (*(b->element(k + (r2 - 1)/2, l + (c2 - 1)/2)));
                }
                _mm256_storeu_pd(temp, running_sum);
                sum+=temp[0] + temp[1] + temp[2] + temp[3];
                // int l = ((int64_t)c2 - 1)/2;
                // sum += (*(a->element(i + k, j + l))) * (*(b->element(k + (r2 - 1)/2, l + (c2 - 1)/2)));        
                for (;l <= l_bound; l++) {
                    // std::cout << "l=" << l << std::endl;
                    sum += (*(a->element(i + k, j + l))) * (*(b->element(k + (r2 - 1)/2, l + l_bound)));
                }

            }
            *(res->element(i, j)) = sum;
        }
    }
    delete[] temp;
    // compute res
    return res;
}

matrix* weirdMul(matrix* a, matrix* b) {
    auto [r1, c1] = a->size();
    auto [r2, c2] = b->size();
    if (c1 != r2) {
        return nullptr; // Dimension mismatch
    }
    matrix* res = new matrix(r1, c2);
    // compute res
    matrix* a_cmp  = new matrix(r1, c1);
    matrix* b_T = new matrix(c2, r2);
    for (uint64_t i=0; i < r1; i++) {
        for (uint64_t j=0; j < c1; j++) {
            *(a_cmp->element(i,j)) = -(*(a->element(i, j)) <= 0.5);
            // *(b_T->element(i,j)) = *(b->element(j, i));
        }
    }

    for (uint64_t i=0; i < c2; i++) {
        for (uint64_t j=0; j < r2; j++) {
            // *(a_cmp->element(i,j)) = -(*(a->element(i, j)) <= 0.5);
            *(b_T->element(i,j)) = *(b->element(j, i));
        }
    }
    __m256d a4;
    __m256d b_T4;
    __m256d a_cmp4;
    __m256d running_sum;
    double * temp = new double[4];
    for (uint64_t i = 0; i < r1; i++) {
        for (uint64_t j = 0; j < c2; j++) {
            running_sum = _mm256_setzero_pd();
            uint64_t k;
            for (k = 0; k < c1 - 3; k+=4) {
                a4 = _mm256_loadu_pd(a->element(i, k));
                b_T4 = _mm256_loadu_pd(b_T->element(j, k));
                a_cmp4 = _mm256_loadu_pd(a_cmp->element(i, k));
                running_sum = _mm256_fmadd_pd(a4, b_T4, running_sum);
                running_sum = _mm256_fmadd_pd(a_cmp4, b_T4, running_sum);

            }
            _mm256_storeu_pd(temp, running_sum);
            *(res->element(i, j)) = temp[0] + temp[1] + temp[2] + temp[3];
            for (; k < c1; k++) {
                *(res->element(i, j)) +=  (*(a->element(i, k)))*(*(b->element(k, j))) + (*a_cmp->element(i, k))*(*(b->element(k, j)));
            }
        }
    }

    delete[] temp;
    delete a_cmp;
    return res;
}