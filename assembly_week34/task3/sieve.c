#include <stdio.h>
#include <stdlib.h>


unsigned long long int* arr;

int main() {
    unsigned long long int n;
    scanf("%llu",&n);
    arr = (unsigned long long int*)malloc(n * 8);
    for (unsigned long long int i = 0; i < n; i++) {
        arr[i] = 0;
    }
    for (unsigned long long int i = 2; i < n; i++) {
        if (arr[i] == 0) {
            for (unsigned long long int j = i * 2; j < n; j += i) {
                if (arr[j] == 0) {
                    arr[j] = i;
                }
            }
        }
    }
    for (unsigned long long int i = 2; i < n; i++) {
        printf("%llu", arr[i]);
    }
    free(arr); // Even if you don't free the array, your code will most likely still work. 
    // Therefore, freeing the array is optional
    // But we really appreciate it if you do :)
    return 0;
}