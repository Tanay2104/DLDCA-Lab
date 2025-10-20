#include <iostream>
#include <cstdint>
#include <chrono>
#include <vector>
#include <array> 
volatile int accum = 0;

volatile int arr[1500];

volatile int m1[1500][1500];
volatile int m2[1500][1500];

int main() {

    srand(42); // seeds the randomness
    // first initialize the arr with random elements
    for (int i=0; i < 1500; i++) {
        arr[i] = rand() % 1500;
        for (int j=0; j < 1500; j++) {
            m1[i][j] = rand() % 100;
            m2[i][j] = rand() % 100;
        }
    }

    // naive time check
    auto preAdd = std::chrono::high_resolution_clock::now();

    accum = 0;


    for (int i=0; i < 1500; i++) {
        for (int j=0; j < 1500; j++) {
            if (arr[j] > 750) {
                // accum gets the dot product between ith column and jth column (say)
                int dotP = 0;
                for (int k=0; k < 1500; k++) {
                    dotP += m1[arr[k]][i] * m2[k][arr[j]];
                }
                accum += dotP;
            }
            else {
                // accum gets -dot product between jth column and ith column (say)
                int dotP = 0;
                for (int k=0; k < 1500; k++) {
                    dotP += m1[k][arr[j]] * m2[arr[k]][i];
                }
                accum -= dotP;
            }
        }
    }   
    auto postAdd = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(postAdd - preAdd).count();
    std::cout << "accum = " << accum << " time taken = " << duration << std::endl;


    preAdd = std::chrono::high_resolution_clock::now();
    accum = 0;
    int local_accum = 0;
    int* m1_T = new int [1500*1500];
    int* m2_T = new int [1500*1500];


    for (int j=0; j < 1500; j++) {
        for (int i=0; i < 1500; i++) {
            m1_T[i*1500 + j] = m1[j][i];
            m2_T[i*1500 + j] = m2[j][i];

        }
    }
    for (int k=0; k < 1500; k++) {
        int arr_k = arr[k];
        int i_sum_m1 = 0, i_sum_m2 = 0;
        for (int i=0; i < 1500; i++) {
            i_sum_m1 += m1_T[arr_k + i*1500];
            i_sum_m2 += m2_T[arr_k + i*1500];
        }
        for (int j = 0; j < 1500; j++) {
            int arr_j = arr[j];
            if (arr_j > 750) {
                local_accum += i_sum_m1 *  m2_T[1500*arr_j + k];
            }
            else {
                local_accum -= i_sum_m2 * m1_T[1500*arr_j + k];
            }
        }
    }
    accum = local_accum;

    delete[] m1_T;
    delete[] m2_T;
    postAdd = std::chrono::high_resolution_clock::now();
    duration = std::chrono::duration_cast<std::chrono::milliseconds>(postAdd - preAdd).count();
    std::cout << "accum = " << accum << " time taken = " << duration << std::endl;

}
