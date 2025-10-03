#include <stdio.h>
int a (int b) {
    return 2*b + 5 - 3;
}

int f (int x, int y) {
    if (x == 0) {
        return a(y);
    }
    else {
        return f(x-1,a(y));
    }
}

int main () {

    int i, n, x;
    x = 0;
    n = 3;
    for (i = 0; i < n; i++) {
        if ((i&1) != 0) {
            x += f(i,n);
        }
        else {
            x += a(x);
        }
    }
    printf("x = %d\n", x);

}