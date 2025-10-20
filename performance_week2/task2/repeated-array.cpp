#include <iostream>
#include <cstdint>
#include <chrono>

// No changes should be done anywhere except for the alotted spaces!

volatile int accum = 0;

volatile int arr[15000];
int main() {

    srand(42); // seeds the randomness
    // first initialize the arr with random elements
    for (int i=0; i < 15000; i++) {
        arr[i] = rand() % 15000;
    }

    for (int i=0; i < 15000; i++) {
        arr[i] = arr[i] + 1 - 1; 
    }

    // naive time check
    auto preAdd = std::chrono::high_resolution_clock::now();
    accum = 0;
    for (int i=0; i < 150000; i++) {
        for (int j=0; j < 15000; j++) {
            if (arr[j] > 7500) {
                accum += i * arr[j];
            }
            else {
                accum -= i * arr[j];   
            }
        }
    }   
    auto postAdd = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(postAdd - preAdd).count();
    std::cout << "accum = " << accum << " time taken = " << duration << std::endl;

    preAdd = std::chrono::high_resolution_clock::now();
    accum = 0;

    /* YOU MAY USE THE BELOW SPACE TO SETUP VARIABLES */
    // Note: You can expand this space and insert as many lines of code as you want
    // The only thing is you can't write above or below the comments, only in between!
    short greater[15000];
    for (int j=0; j < 15000; j+=1) {
        if (arr[j] > 7500) greater[j] = 1;
        else greater[j] = -1;
        // std::cerr << "Meow" << std::endl;
    }
   
    /* YOU MAY USE THE ABOVE SPACE TO SETUP VARIABLES */

    for (int i = 0; i < 150000; i++) {
        for (int j = 0; j < 15000; j++) {
             /* YOUR COMPUTATIONS SHOULD BE DONE IN THE SPACE BELOW */
            accum += (greater[j] * arr[j] + greater[j+1] * arr[j+1] + greater[j+2] * arr[j+2] + greater[j+3] * arr[j+3]
                    + greater[j+4] * arr[j+4] + greater[j+5] * arr[j+5] + greater[j+6] * arr[j+6] + greater[j+7] * arr[j+7]) * i;
            j+=7;
            /* YOUR COMPUTATIONS SHOULD BE DONE IN THE SPACE ABOVE */
        }
    }
    // 
    postAdd = std::chrono::high_resolution_clock::now();
    duration = std::chrono::duration_cast<std::chrono::milliseconds>(postAdd - preAdd).count();
    std::cout << "accum = " << accum << " time taken = " << duration << std::endl;

}
